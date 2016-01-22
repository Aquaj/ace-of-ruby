class Hand < Array

  attr_reader :cards

  def initialize(deck, num=0)
    @cards = []
    @deck = deck
    self.add(num)
  end

  def add(card_or_num=1)
    if card_or_num.is_a? Fixnum
      card_or_num.times { @cards << @deck.pick } # Num -> Add n cards
    else
      @cards << card_or_num # Card -> Add that specific card
    end
  end

  def includes?(card)
    @cards.includes? card
  end

  def to_s
    return @cards.reduce("[") { |a, e| a+"["+(" " * (1 - e.to_s.length/4))+e.to_s+" ]" } + "]"
  end

end

class Card

  attr_reader :color, :value

  COLORS = ["clubs","spades","hearts","diamonds"]

  def initialize(value, color)
    fail ArgumentError, "Invalid card: #{value} of #{color}" if value > 13 || !COLORS.include?(color)
    @value = value
    @color = color
  end

  def ==(other)
    @value == other.value && @color == other.color
  end

  def <=>(other)
    if @value == other.value
      if @color == other.color
        return 0
      elsif @color == [@color, other.color].sort[0]
        return -1
      else
        return 1
      end
    elsif @value < other.value
      return -1
    else
      return 1
    end
  end

  def to_s(unicode=true)
    translations = {
                    "11" => "J",
                    "12" => "Q",
                    "13" => "K"
                  }
    if unicode
    translations.update({
                        "clubs" => "♣",
                        "spades" => "♠",
                        "hearts" => "♥",
                        "diamonds" => "♦"
                        })
    end
    initial = "#{@value} #{@color}"
    translations.each { |pre,post| initial.gsub!(pre, post) }
    return initial
  end
end

class Deck

  attr_accessor :cards

  def initialize(thirty_two=false)
    @cards = []
    if thirty_two
      Card::COLORS.each { |c| (7..13).each { |v| @cards << Card.new(v,c)}; @cards << Card.new(1,c) }
    else
      Card::COLORS.each { |c| (1..13).each { |v| @cards << Card.new(v,c)} }
    end
  end

  def shuffle
    cards.shuffle!
    return self
  end

  def pick
    if cards.length == 0
      fail IndexError, "The deck is empty !"
    end
    cards.pop
  end

  def show_next(num=1)
    return cards[-num..-1].reverse.reduce("") { |a, e| a+"["+(" " * (1 - e.to_s.length/4))+e.to_s+" ]" }
  end

  def to_s(unicode=true)
    return cards.map { |c| c.to_s(unicode=unicode)}
  end
end

if __FILE__ == $0
  c = Card.new(12,"clubs").to_s
  d = Deck.new(thirty_two=true)
  p d.show_next(10)
  h = Hand.new(d, 10)
  p c.to_s
  p d.shuffle.to_s
  p h.to_s
  5.times { p d.pick.to_s }
end
