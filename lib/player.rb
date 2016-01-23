require_relative 'cards'

# Represents a Player, not poker-specific.
class Player
  attr_reader :hand
  @@names = []

  def initialize(funds, deck, name, first_cards = 0)
    @hand = Hand.new(deck, first_cards)
    @funds = funds
    @status = :playing
    name = name.to_sym
    fail ArgumentError,
         'Name already taken. Please pick other.' if @@names.include? name
    @name = name
    @@names << name
  end

  def pick(num = 1)
    @hand.add(num)
  end

  def show_hand
    @hand.to_s
  end

  def bets(bet, pot) # TODO: Implement fund limits.
    @funds -= bet
    pot.add_bet(self, bet)
  end

  def name
    @name.to_s
  end

  def fold
    @status = :out
  end

  def in_game?
    @status == :playing
  end

  def stake
    @funds
  end

  def score
    @hand.score
  end
end

if __FILE__ == $PROGRAM_NAME
  d = Deck.new(true).shuffle
  p d.show_next(3)
  p1 = Player.new(50, d, 'Yolo', 2)
  Player.new(50, d, 'Yolo', 2)
  p p1.show_hand
end
