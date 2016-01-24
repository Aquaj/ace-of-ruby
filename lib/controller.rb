require_relative 'deck'
require_relative 'pot'
require_relative 'player'
require_relative 'view'
require_relative 'evaluate_poker'

# Controller
class Controller
  def initialize
    @small_blind = 1
    @players = []
    @players_names = []
    @view = View.new
    @num_of_players = @view.get_number_of_players
    @deck = Deck.new
    @community_cards = []
    roles(0)

    @num_of_players.times do
      name = @view.get_player_name(@players_names)
      @players_names << name
      stake = @view.get_player_stake(@small_blind)
      @players << Player.new(stake, @deck, name)
    end

    @pot = Pot.new(@players)
  end

  def game
    @deck.shuffle
    @players[@small_blinder].bets(@small_blind, @pot)
    @players[@big_blinder].bets(@small_blind * 2, @pot)

    (1..@num_of_players).each do |player_index|
      player = @players[(@big_blinder + player_index) % @num_of_players]
      player.pick(2)
    end

    preflop
    flop
    turn
    river
    showdown

    roles(@dealer + 1)
    @deck = Deck.new
    @community_cards = []
    @pot = Pot.new(@players)
    @players.each(&:reset)
  end

  private

  def roles(index)
    @dealer = index % @num_of_players
    @small_blinder = (@dealer + 1) % @num_of_players
    @big_blinder = (@small_blinder + 1) % @num_of_players
  end

  def preflop
    betting_round
  end

  def flop
    @deck.pick
    @view.burnt
    @community_cards << @deck.pick

    betting_round
  end

  def turn
    @deck.pick
    @view.burnt
    @community_cards << @deck.pick

    betting_round
  end

  def river
    @deck.pick
    @view.burnt
    @community_cards << @deck.pick

    betting_round
  end

  def showdown
    still_in_game = @players.select(&:in_game)
    @view.big_reveal(@community_cards, still_playing.map { |p| [p.name, p.hand] })
    scores = still_in_game.map do |p|
      [p, EvaluatePoker.evaluate(p.hand + @community_cards)]
    end
    winner, score = scores[scores.map { |e| e[1] }.index(scores.map { |e| e[1] }.max)]
    type = score / 13
    card = ((score + 1) % 13 + 1).to_s.gsub('11', 'Jack').gsub('12', 'Queen').gsub('13', 'King').gsub('1', 'Ace')
    winner.wins(@pot.whole_pot)
    losers = still_in_game.reject { |p| p == winner }
    losers.each { |p| p.fold(@pot) }
    @view.present_winner(winner.name, type, card)
  end

  def betting_round
    finished = false
    loop do
      answers = []
      (1..@num_of_players).each do |player_index|
        player = @players[(player_index + @big_blinder) % @num_of_players]
        next unless player.in_game?
        to_match = @pot.current_bet

        @view.state_of_the_game(@community_cards, to_match)

        current = @pot.bet_of player
        @view.player_state(player.name, player.hand)
        @view.state_of_game_for_player(@pot.bet_of(player), player.stake)

        answers << fold_call_raise(player, current, to_match)
        next_player_index = (player_index + @big_blinder + 1) % @num_of_players
        until @players[next_player_index % @num_of_players].in_game?
          next_player_index += 1
        end
        finished = end_of_turn(answers.join == 'k' * still_playing.length, next_player_index)
      end
      break if finished
    end
  end

  def still_playing
    @players.select(&:in_game?)
  end

  def end_of_turn(end_of_part, index)
    if end_of_part
      @view.end_of_part
    else
      @view.wait_for_next(@players[index].name)
    end
  end

  def fold_call_raise(player, current, to_match)
    check = current == to_match
    answer = @view.player_choice(check)
    case answer
    when 'f'
      if @view.folding == 'y'
        player.fold(@pot)
        @view.folded
      end
    when 'c'
      answer = 'k' if check
      @view.calling(check)
      player.bets(to_match - current, @pot)
    when 'r'
      bet = @view.raising
      player.bets(to_match - current + bet, @pot)
    end
    @view.state_of_game_for_player(@pot.bet_of(player), player.stake)
    answer
  end
end
