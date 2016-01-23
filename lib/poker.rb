require_relative 'player'
require_relative 'cards'
require_relative 'pot'
require_relative 'evaluate_poker'

include EvaluatePoker

def get_input(sentence)
  puts sentence
  print '> '
  gets.chomp
end

def financials(player)
  "Your bet: #{POT.bet_of player}$ || #{player.stake}$ in your stake"
end

def call_or_check(current)
  '(c)' + (checking?(current) ? 'all' : 'heck')
end

def checking?(current)
  POT.current_bet > current
end

def burn(from_deck)
  from_deck.pick
  'The Dealer burnt one card.'
end

def community_cards(flop_hand)
  "The community cards are : \n#{flop_hand}"
end

def betting_round(starting_player, community, show_community = true)
  loop do # TURN
    nobody_bet = true
    (1..PLAYERS_NUM).each do |player_index|
      player = PLAYERS[(starting_player + player_index) % PLAYERS_NUM]
      next unless player.in_game?

      (puts community_cards(community) + "\n") if show_community
      nobody_bet = !lets_bet(player) && nobody_bet

      gets.chomp
      system 'clear'
    end
    break if POT.everyone_at_bet? && nobody_bet
  end
end

def lets_bet(player)
  to_match = POT.current_bet
  current = POT.bet_of player
  puts "Hello #{player.name}."
  puts 'This is your hand :'
  puts player.show_hand
  puts financials(player)
  puts "You currently have to match #{to_match}$"

  they_chose = false
  until they_chose
    answer = get_input("Do you wanna #{call_or_check current} the bet, " \
     '(r)aise or (f)old ?')
    case answer
    when 'f'
      player.fold
      they_chose = true
      betted = false
    when 'c'
      bet = current
      player.bets(to_match - bet, POT)
      puts financials(player)
      they_chose = true
      betted = checking? current
    when 'r'
      bet = (get_input 'How much do you wanna raise?').to_i
      player.bets(to_match - current + bet, POT)
      puts financials(player)
      they_chose = true
      betted = true
    end
  end
  betted
end

INIT_STAKE = 50
SMALL_BLIND = 1

PLAYERS_NUM = get_input('How many players are involed?').to_i
fail ArgumentError, 'We need some players !' if PLAYERS_NUM <= 0
puts

d = Deck.new
PLAYERS = Array
          .new(PLAYERS_NUM) { |e| Player.new(INIT_STAKE, d, "Player #{e + 1}") }

POT = Pot.new(PLAYERS)

d.shuffle
dealer = 0 # index
small_blinder = dealer + 1
big_blinder = small_blinder + 1

PLAYERS[small_blinder].bets(SMALL_BLIND, POT)
PLAYERS[big_blinder].bets(SMALL_BLIND * 2, POT)

(big_blinder + 1..big_blinder + PLAYERS_NUM).each do |player_index|
  player = PLAYERS[player_index % PLAYERS_NUM]
  player.pick(2)
end

betting_round(big_blinder, false, false) # PRE-FLOP

puts burn(d)
community = Hand.new(d, 3)

betting_round(dealer, community) # FLOP

puts burn(d)
community.add(1)

betting_round(dealer, community) # TURN

puts burn(d)
community.add(1)

betting_round(dealer, community) # RIVER

betting_round(dealer, community) # SHOWDOWN

puts "Community cards : #{community.to_s}"
puts
scores = PLAYERS.select { |player| player.in_game? }.map do |p|
  puts "#{p.name} : #{p.show_hand}"
  [p, EvaluatePoker.evaluate(p.hand.cards, community.cards)]
end

winner = scores.map { |e| e[0] }[scores.map { |e| e[1] }.index(scores.map { |e| e[1] }.max)]

puts
puts "The winner is #{winner.name}."
