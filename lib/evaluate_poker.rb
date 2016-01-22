# Module in charge of calculating scores for each hand.
module EvaluatePoker
  def self.evaluate(hand, community_cards)
    # FIXME: 1..5 straight(/flush) beats 2..6
    # FIXME: Highest card can be one not in
    digit = (table_of_all_checks(hand + community_cards).rindex(true) + 1) * 13
    digit + (get_high_card(hand + community_cards).value + 11) % 13
  end

  def self.table_of_all_checks(cards)
    [check_if_pair(cards),
     check_if_pairs(cards),
     check_if_three(cards),
     check_if_straight(cards),
     check_if_flush(cards),
     check_if_house(cards),
     check_if_four(cards),
     check_if_straight_flush(cards),
     check_if_royal_flush(cards)]
  end

  def self.check_if_royal_flush(cards)
    return false unless cards.all? { |c| c.color == cards[0].color }
    cards
      .sort
      .map(&:value) == [1, 10, 11, 12, 13]
  end

  def self.check_if_straight_flush(cards)
    return false unless cards.all? { |c| c.color == cards[0].color }
    check_if_straight(cards)
  end

  def self.check_if_four(cards)
    cards
      .group_by(&:value)
      .any? { |_k, v| v.length == 4 }
  end

  def self.check_if_house(cards)
    check_if_pair(cards) &&
      check_if_three(cards)
  end

  def self.check_if_flush(cards)
    cards
      .group_by(&:color)
      .any? { |_k, v| v.length == 5 }
  end

  def self.check_if_straight(cards)
    cards
      .map(&:value)
      .sort
      .each_cons(2)
      .reduce(true) { |a, e| a && (e[0] + 1 == e[1]) } ||
      cards
        .map { |e| ((e.value + 11) % 13 + 1) }
        .sort
        .each_cons(2)
        .reduce(true) { |a, e| a && (e[0] + 1 == e[1]) }
  end

  def self.check_if_three(cards)
    cards
      .group_by(&:value)
      .any? { |_k, v| v.length == 3 }
  end

  def self.check_if_pairs(cards)
    cards
      .group_by(&:value)
      .count { |_k, v| v.length == 2 } == 2
  end

  def self.check_if_pair(cards)
    cards
      .group_by(&:value)
      .count { |_k, v| v.length == 2 } == 1
  end

  def self.get_high_card(cards)
    return cards.select { |v| v.value == 1 }[0] if cards.map(&:value).include? 1
    cards.max
  end
end
