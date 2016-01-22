require_relative "cards"

class Player

  PLAYER_NAMES = []

  def initialize(funds, deck, name, first_cards=0)
    @hand = Hand.new(deck, first_cards)
    @funds = funds
    @status = :playing
    name = name.to_sym
    fail ArgumentError, "Name already taken. Please pick another." if PLAYER_NAMES.include? name
    @name = name
    PLAYER_NAMES << name
  end

  def pick(num=1)
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
end

if __FILE__ == $0
  d = Deck.new(thirty_two=true).shuffle
  p d.show_next(3)
  p1 = Player.new(50, d, "Yolo", 2)
  p2 = Player.new(50, d, "Yolo", 2)
  p p1.show_hand
end
