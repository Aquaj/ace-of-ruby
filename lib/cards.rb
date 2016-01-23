# Implements a player's hand of cards, poker-specific.
class Hand < Array
  attr_reader :cards

  def initialize(deck, num = 0)
    @cards = []
    @deck = deck
    add(num)
  end

  def add(card_or_num = 1)
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
    @cards.reduce('[') { |a, e| a + "[ #{e.to_s.rjust(3)} ]" } + ']'
  end
end

# Non poker-specific implementation of a Card.
class Card
  attr_reader :color, :value

  COLORS = %w(clubs spades hearts diamonds).freeze

  def initialize(value, color)
    fail ArgumentError,
         "Invalid card: #{value} of #{color}" if value > 13 ||
                                                 !COLORS.include?(color)
    @value = value
    @color = color
  end

  def ==(other)
    @value == other.value && @color == other.color
  end

  def <=>(other)
    if @value == other.value
      return 0 if @color == other.color
      return -1 if @color == [@color, other.color].sort[0]
      return 1
    end
    return -1 if @value < other.value
    1
  end

  def to_s(unicode = true)
    translations = { '11' => 'J', '12' => 'Q', '13' => 'K' }
    if unicode
      translations.update(clubs: '♣', spades: '♠', hearts: '♥', diamonds: '♦')
    end
    initial = "#{@value} #{@color}"
    translations.each { |pre, post| initial.gsub!(pre.to_s, post) }
    initial
  end
end

# Implements a Deck of cards. Non poker-specific.
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

if __FILE__ == $PROGRAM_NAME
  c = Card.new(12, 'clubs').to_s
  d = Deck.new(true)
  p d.show_next(10)
  h = Hand.new(d, 10)
  p c.to_s
  p d.shuffle.to_s
  p h.to_s
  5.times { p d.pick.to_s }
end
