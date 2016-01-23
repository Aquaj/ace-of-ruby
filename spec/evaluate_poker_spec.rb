require 'evaluate_poker'
require 'cards'

def init_from_values(values, suit)
  init_hands(values.map { |value| [value, suit] })
end

def init_from_colors(value, colors)
  init_hands(colors.map { |color| [value, color] })
end

def init_hands(array_of_values)
  array_of_values.map { |v| Card.new(v[0], v[1]) }
end

def hand_random_values(num_of_cards)
  hand = []
  until hand.length == num_of_cards
    r = (1..13).to_a.sample
    (hand << r) unless hand.include? r
  end
  hand
end

def hand_random_colors(num_of_colors)
  %w(spades hearts diamonds clubs).sample(num_of_colors)
end

def random_value
  hand_random_values(1)[0]
end

def random_color
  hand_random_colors(1)[0]
end

describe 'valuatePoker' do
  describe '#evaluate' do
    it 'should return an accurate score for any hand' do
      expect(
        EvaluatePoker.evaluate(
          init_from_values([1, 10, 11, 12, 13].shuffle, random_color), []))
        .to eq(129)
      expect(
        EvaluatePoker.evaluate(
          init_from_values(
            [1, 2, 3, 4, 5], random_color), []))
        .to eq(107)
      expect(
        EvaluatePoker.evaluate(init_from_colors(
          7, hand_random_colors(4)) +
        init_hands([[6, random_color]]), []))
        .to eq(96)
      expect(
        EvaluatePoker.evaluate(init_from_colors(
          7, hand_random_colors(3)) +
        init_hands([[6, random_color], [8, random_color]]), []))
        .to eq(44)
    end
  end
  describe '#check_if_royal_flush' do
    it 'should return true if a hand is a Royal Flush' do
      expect(
        EvaluatePoker.check_if_royal_flush(
          init_from_values([1, 10, 11, 12, 13].shuffle, random_color)))
        .not_to be(false)
    end
    it 'should return false if values are not going up to the ace' do
      r = random_value % 9
      expect(
        EvaluatePoker.check_if_royal_flush(
          init_from_values([r, r + 1, r + 2, r + 3, r + 4], random_color)))
        .to eq(false)
    end
    it 'should return false if values are not sequential' do
      expect(
        EvaluatePoker.check_if_royal_flush(
          init_from_values([10, 11, 12, random_value % 13, 1], random_color)))
        .to eq(false)
    end
    it 'should return false if values are not of the same suit' do
      r = hand_random_colors(2)
      expect(
        EvaluatePoker.check_if_royal_flush(
          init_from_values([10, 12, 13, 11], r[0]) +
          init_hands([[1, r[1]]])))
        .to eq(false)
    end
  end
  describe '#check_if_straight_flush' do
    it 'should check if a hand is a Straight Flush' do
      r = random_value % 9
      expect(
        EvaluatePoker.check_if_straight_flush(
          init_from_values([r, r + 1, r + 2, r + 3, r + 4].shuffle,
                           random_color)))
        .not_to be(false)
    end
    it 'should return false if values are not sequential' do
      r = random_value % 6 + 2
      expect(
        EvaluatePoker.check_if_straight_flush(
          init_from_values([r - 1, r + 1, r + 2, r + 3, r + 4], random_color)))
        .to eq(false)
    end
    it 'should return false if values are not of the same suit' do
      r = random_value % 9
      rc = hand_random_colors(2)
      expect(
        EvaluatePoker.check_if_straight_flush(
          init_from_values([r, r + 1, r + 2, r + 3], rc[0]) +
          init_hands([[r + 4, rc[1]]])))
        .to eq(false)
    end
    describe 'Aces' do
      it 'should handle aces as Lowest value' do
        expect(
          EvaluatePoker.check_if_straight_flush(
            init_from_values([1, 2, 3, 4, 5].shuffle, random_color)))
          .not_to be(false)
      end
      it 'should handle aces as Highest value' do
        expect(
          EvaluatePoker.check_if_straight_flush(
            init_from_values([10, 11, 12, 13, 1].shuffle, random_color)))
          .not_to be(false)
      end
    end
  end
  describe '#check_if_four' do
    it 'should return true if a hand is a Four of a Kind' do
      r = random_value % 13
      expect(
        EvaluatePoker.check_if_four(
          init_from_colors(r, hand_random_colors(4)) +
          init_hands([[r + 1, random_color]]))).not_to be(false)
    end
    it 'should return false if a hand does not include a Four of a Kind' do
      expect(
        EvaluatePoker.check_if_four(
          init_hands([[9, random_color],
                      [7, random_color],
                      [3, random_color],
                      [5, random_color],
                      [11, random_color]])))
        .to eq(false)
    end
  end
  describe '#check_if_house' do
    it 'should return true if a hand is a Full House' do
      r = random_value % 13
      expect(
        EvaluatePoker.check_if_house(
          init_from_colors(r, hand_random_colors(3)) +
          init_from_colors(r + 1, hand_random_colors(2))))
        .not_to be(false)
    end
    it 'should return false if a hand does not include a Full House' do
      hand = hand_random_values(5)
      col = hand_random_colors(4)
      expect(
        EvaluatePoker.check_if_house(
          init_from_values(hand[0..1], col[0]) +
          init_hands([[hand[2], col[1]],
                      [hand[3], col[2]],
                      [hand[4], col[3]]])))
        .to eq(false)
    end
  end
  describe '#check_if_flush' do
    it 'should return true if a hand is a Flush' do
      expect(
        EvaluatePoker.check_if_flush(
          init_from_values(hand_random_values(5), random_color)))
        .not_to be(false)
    end
    it 'should return false if a hand does not include a Flush' do
      colors = hand_random_colors(2)
      hand = hand_random_values(5)
      expect(
        EvaluatePoker.check_if_flush(
          init_from_values(hand[0...4], colors[0]) +
          init_from_values([hand[4]], colors[1])))
        .to eq(false)
    end
  end
  describe '#check_if_straight' do
    it 'should return true if a hand is a Straight' do
      r = random_value % 9
      expect(
        EvaluatePoker.check_if_straight(
          init_hands([r, r + 1, r + 2, r + 3, r + 4]
            .map { |v| [v, random_color] })))
        .not_to be(false)
    end
    it 'should return false if a hand does not include a Straight' do
      r = random_value % 8 + 1
      expect(
        EvaluatePoker.check_if_straight(
          init_hands([r - 1, r + 1, r + 2, r + 3, r + 4]
            .map { |v| [v, random_color] })))
        .to eq(false)
    end
  end
  describe '#check_if_three' do
    it 'should return true if a hand is a Three of a Kind' do
      r = hand_random_values(3)
      expect(
        EvaluatePoker.check_if_three(
          init_from_colors(r[0], hand_random_colors(3)) +
          init_from_values([r[1], r[2]], random_color)))
        .not_to be(false)
    end
    it 'should return false if a hand does not include a Three of a Kind' do
      r = hand_random_values(4)
      expect(
        EvaluatePoker.check_if_three(
          init_from_colors(r[0], hand_random_colors(2)) +
          init_from_values([r[1], r[2], r[3]], random_color)))
        .to eq(false)
    end
  end
  describe '#check_if_pairs' do
    it 'should return true if a hand is Two Pairs' do
      r = hand_random_values(3)
      expect(
        EvaluatePoker.check_if_pairs(
          init_from_colors(r[0], hand_random_colors(2)) +
          init_from_colors(r[1], hand_random_colors(2)) +
          init_hands([[r[2], random_color]])))
        .not_to be(false)
    end
    it 'should return false if a hand does not include Two Pairs' do
      r = hand_random_values(4)
      expect(
        EvaluatePoker.check_if_pairs(
          init_from_colors(r[0], hand_random_colors(2)) +
            init_from_values([r[1], r[2], r[3]], random_color)))
        .to eq(false)
    end
  end
  describe '#check_if_pair' do
    it 'should return true if a hand is a Pair' do
      r = hand_random_values(4)
      expect(
        EvaluatePoker.check_if_pair(
          init_from_colors(r[0], hand_random_colors(2)) +
            init_from_values([r[1], r[2], r[3]], random_color)))
        .not_to be(false)
    end
    it 'should return false if a hand does not include a Pair' do
      expect(
        EvaluatePoker.check_if_pair(
          init_hands(
            hand_random_values(5)
              .map { |v| [v, random_color] })))
        .to eq(false)
    end
  end

  describe '#get_high_card' do
    it 'should return the highest card of the hand' do
      r = random_color
      expect(
        EvaluatePoker.get_high_card(
          init_hands(
            [[3, random_color],
             [6, random_color],
             [8, random_color],
             [9, random_color],
             [10, r]]).shuffle))
        .to eq(Card.new(10, r))
    end
    it 'should handle Aces as the highest card outside of straights' do
      r = random_color
      expect(
        EvaluatePoker.get_high_card(
          init_hands(
            [[1, r],
             [6, random_color],
             [7, random_color],
             [10, random_color],
             [12, random_color]])))
        .to eq(Card.new(1, r))
    end
  end
end
