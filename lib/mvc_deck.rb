require_relative 'mvc_cards'
# Implements a Deck.
class Deck
  attr_accessor :cards

  def initialize(thirty_two = false)
    @cards = []
    if thirty_two
      Card::COLORS.each do |c|
        (7..13).each { |v| @cards << Card.new(v, c) }
        @cards << Card.new(1, c)
      end
    else
      Card::COLORS.each { |c| (1..13).each { |v| @cards << Card.new(v, c) } }
    end
  end

  def shuffle
    cards.shuffle!
    self
  end

  def pick
    fail IndexError, 'The deck is empty !' if cards.length == 0
    cards.pop
  end

  def show_next(num = 1)
    cards[-num..-1]
      .reverse.reduce('') { |a, e| a + "[ #{e.to_s.rjust(2)} ]" }
  end

  def to_s(unicode = true)
    cards.map { |c| c.to_s(unicode = unicode) }
  end
end
