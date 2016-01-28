# Model : represents a player.
class Player
  attr_reader :hand
  @@names = []

  def initialize(funds, deck, name)
    @hand = []
    @funds = funds
    @status = :playing
    @deck = deck
    name = name.to_sym
    fail ArgumentError,
         'Name already taken. Please pick other.' if @@names.include? name
    @name = name
    @@names << name
  end

  def pick(num = 1)
    num.times { @hand << @deck.pick }
  end

  def reset
    @status = :playing
    @hand = []
  end

  def is_all_in?(bet)
    @funds <= bet
  end

  def bets(bet, pots)
    p pots.map(&:values)
    if Pot.bet_of(self) + bet <= @funds
      p "bet_of #{self.name} < @funds"
      pots.detect { |p| !p.capped? || p.capped? && p[self]<p.max{ |a, b| a[1] <=> b[1] }[1] }.add_bet(self, bet, is_all_in?(bet))
    else
      pots.detect { |p| !p.capped? || p.capped? && p[self]<p.max{ |a, b| a[1] <=> b[1] }[1] }.add_bet(self, @funds - Pot.bet_of(self), is_all_in?(bet))
    end
  end

  def name
    @name.to_s
  end

  def fold(pot)
    @funds -= pot.bet_of self
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

  def wins(amount)
    @funds += amount
  end
end

if __FILE__ == $PROGRAM_NAME
  d = Deck.new(true).shuffle
  p d.show_next(3)
  p1 = Player.new(50, d, 'Yolo', 2)
  Player.new(50, d, 'Yolo', 2)
  p p1.show_hand
end
