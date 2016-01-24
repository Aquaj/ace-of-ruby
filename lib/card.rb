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
