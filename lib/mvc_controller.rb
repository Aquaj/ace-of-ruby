require_relative 'mvc_deck'
require_relative 'mvc_pot'
require_relative 'mvc_player'
require_relative 'mvc_view'
require_relative 'evaluate_poker'

class Controller
  def initialize
    @INIT_STAKE = 50
    @SMALL_BLIND = 1
    @PLAYERS = []
    @PLAYERS_NAMES = []
    @view = View.new
    @NUM_OF_PLAYERS = @view.get_number_of_players
    @deck = Deck.new
    @community_cards = []
    roles(0)

    @NUM_OF_PLAYERS.times do |n|
      name = @view.get_player_name(@PLAYERS_NAMES)
      @PLAYERS_NAMES << name
      stake = @view.get_player_stake(@SMALL_BLIND)
      @PLAYERS << Player.new(stake, @deck, name)
    end

    @pot = Pot.new(@PLAYERS)
  end

  def game
    @deck.shuffle
    @PLAYERS[@small_blinder].bets(@SMALL_BLIND, @pot)
    @PLAYERS[@big_blinder].bets(@SMALL_BLIND * 2, @pot)

    (1..@NUM_OF_PLAYERS).each do |player_index|
      player = @PLAYERS[(@big_blinder + player_index) % @NUM_OF_PLAYERS]
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
    @pot = Pot.new(@PLAYERS)
    @PLAYERS.each { |player| player.reset }
  end

private
  def roles(index)
    @dealer = index % @NUM_OF_PLAYERS
    @small_blinder = (@dealer + 1) % @NUM_OF_PLAYERS
    @big_blinder = (@small_blinder + 1) % @NUM_OF_PLAYERS
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
    still_in_game = @PLAYERS.select { |player| player.in_game? }
    @view.big_reveal(@community_cards, @PLAYERS.select { |p| p.in_game? }.map { |p| [p.name, p.hand] })
    scores = still_in_game.map do |p|
      [p, EvaluatePoker.evaluate(p.hand + @community_cards)]
    end
    winner, score = scores[scores.map { |e| e[1] }.index(scores.map { |e| e[1] }.max)]
    type = score / 13
    card = ((score + 1) % 13 + 1).to_s.gsub("11", "Jack").gsub("12", "Queen").gsub("13", "King").gsub("1", "Ace")
    winner.wins(@pot.whole_pot)
    losers = still_in_game.reject { |p| p == winner }
    losers.each { |p| p.fold(@pot) }
    @view.present_winner(winner.name, type, card)
  end

  def betting_round
    finished = false
    loop do
      answers = []
      (1..@NUM_OF_PLAYERS).each do |player_index|
        player = @PLAYERS[(player_index + @big_blinder) % @NUM_OF_PLAYERS]
        next unless player.in_game?
        to_match = @pot.current_bet

        @view.state_of_the_game(@community_cards, to_match)

        current = @pot.bet_of player
        @view.player_state(player.name, player.hand)
        @view.state_of_game_for_player(@pot.bet_of(player), player.stake)

        answers << fold_call_raise(player, current, to_match)
        next_player_index = (player_index + @big_blinder + 1) % @NUM_OF_PLAYERS
        until @PLAYERS[next_player_index % @NUM_OF_PLAYERS].in_game?
          next_player_index += 1
        end
        if answers.join == 'k' * @PLAYERS.select { |p| p.in_game? }.length
          @view.end_of_part
          finished = true
        else
          @view.wait_for_next(@PLAYERS[next_player_index].name)
        end
      end
      break if finished
    end
  end

  def fold_call_raise(player, current, to_match)
    check = current == to_match
    answer = @view.player_choice(check)
    case answer
    when 'f'
      if @view.folding == "y"
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
