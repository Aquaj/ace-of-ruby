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

    @pots = [Pot.new(@players)]
  end

  def game
    @deck.shuffle
    @players[@small_blinder].bets(@small_blind, @pots)
    @players[@big_blinder].bets(@small_blind * 2, @pots)

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
    @pots = [Pot.new(@players)]
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
    still_in_game = @players.select(&:in_game?)
    @view.big_reveal(@community_cards, still_playing.map { |p| [p.name, p.hand] })
    scores = still_in_game.map do |p|
      [p, EvaluatePoker.evaluate(p.hand + @community_cards)]
    end
    @pots.each do |pot|
      eligible_winners = pot.select { |_k,v| v > 0 }
      binding.pry
      winner, score = scores.select { |f| eligible_winners.include?(f[0]) }[scores.map { |e| e[1] }.index(scores.map { |e| e[1] }.max)]
      type = score / 13
      card = ((score + 1) % 13 + 1).to_s.gsub('11', 'Jack').gsub('12', 'Queen').gsub('13', 'King').gsub('1', 'Ace')
      winner.wins(pot.whole_pot)
      losers = still_in_game.reject { |p| p == winner }
      losers.each { |p| p.fold(pot) }
      if @pots.length > 1
        @view.present_winner(winner.name, type, card, ordinalize(@pots.index(pot)+1))
      else
        @view.present_winner(winner.name, type, card)
      end
    end
  end

  def ordinalize(num)
    if (11..13).include?(num % 100)
      "#{num}th"
    else
      case num % 10
        when 1; "#{num}st"
        when 2; "#{num}nd"
        when 3; "#{num}rd"
        else    "#{num}th"
      end
    end
  end

  def betting_round
    finished = false
    loop do
      answers = []
      (1..@num_of_players).each do |player_index|
        player = @players[(player_index + @big_blinder) % @num_of_players]
        next unless player.in_game?
        to_match = Pot.current_bet

        @view.state_of_the_game(@community_cards, to_match)

        current = Pot.bet_of player
        @view.player_state(player.name, player.hand)
        @view.state_of_game_for_player(Pot.bet_of(player), player.stake)

        answers << fold_call_raise(player, current, to_match)
        next_player_index = (player_index + @big_blinder + 1) % @num_of_players
        until @players[next_player_index % @num_of_players].in_game?
          next_player_index += 1
        end
        p still_playing.map(&:name)
        p answers
        finished = answers.join == 'k' * still_betting.length
        end_of_turn(finished, next_player_index)
      end
      break if finished
    end
  end

  def still_betting
    still_playing.reject { |p| p.is_all_in? Pot.current_bet }
  end

  def still_playing
    @players.select(&:in_game?)
  end

  def end_of_turn(end_of_part, index)
    if end_of_part
      @view.end_of_part(@players[index].name, @community_cards.length == 3)
    else
      @view.wait_for_next(@players[index].name)
    end
  end

  def fold_call_raise(player, current, to_match)
    check = current == to_match
    if player.is_all_in?(current)
      @view.youre_all_in
    else
      answer = @view.player_choice(check)
        case answer
        when 'f'
          if @view.folding == 'y'
            player.fold(@pots)
            @view.folded
          end
        when 'c'
          answer = 'k' if check
          @view.calling(check)
          player.bets(to_match - current, @pots)
        when 'r'
          bet = @view.raising
          player.bets(to_match - current + bet, @pots)
        end
    end
    @pots = Pot.pots
    @view.state_of_game_for_player(Pot.bet_of(player), player.stake)
    answer
  end
end
