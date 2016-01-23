# Module in charge of calculating scores for each hand.
module EvaluatePoker
  def self.evaluate(hand, community_cards)
    table = table_of_all_checks(hand + community_cards)
    digit = (table.rindex { |e| e.is_a? Card } + 1)
    digit*13 + (table[digit-1].value + 11) % 13
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
    return false if cards
      .sort
      .map(&:value) != [1, 10, 11, 12, 13]
    return get_high_card(cards)
  end

  def self.check_if_straight_flush(cards)
    return false unless cards.all? { |c| c.color == cards[0].color }
    check_if_straight(cards)
  end

  def self.check_if_four(cards)
    fours = cards
      .group_by(&:value)
      .select { |_k, v| v.length == 4 }
      .values
    return false if fours.length == 0
    return get_high_card(fours[0])
  end

  def self.check_if_house(cards)
    return false if !check_if_pair(cards) || !check_if_three(cards)
    return get_high_card(cards)
  end

  def self.check_if_flush(cards)
    flush = cards
      .group_by(&:color)
      .select { |_k, v| v.length == 5 }
      .values
    return false if flush.length == 0
    return get_high_card(flush[0])
  end

  def self.check_if_straight(cards)
    return false if !(cards
      .map(&:value)
      .sort
      .each_cons(2)
      .reduce(true) { |a, e| a && (e[0] + 1 == e[1]) } ||
      cards
        .map { |e| ((e.value + 11) % 13 + 1) }
        .sort
        .each_cons(2)
        .reduce(true) { |a, e| a && (e[0] + 1 == e[1]) })
    return get_high_card(cards, false)
  end

  def self.check_if_three(cards)
    threes = cards
      .group_by(&:value)
      .select { |_k, v| v.length == 3 }
      .values
    return false if threes.length == 0
    return get_high_card(threes[0])
  end

  def self.check_if_pairs(cards)
    pairs = cards
      .group_by(&:value)
      .select { |_k, v| v.length == 2 }
      .values
    return false if pairs.length != 2
    return get_high_card(pairs.reduce(&:+))
  end

  def self.check_if_pair(cards)
    pair = cards
      .group_by(&:value)
      .select { |_k, v| v.length == 2 }
      .values
    return false if pair.length == 0
    return get_high_card(pair[0])
  end

  def self.get_high_card(cards, count_ace = true, tmp = false)
    return cards.select { |v| v.value == 1 }[0] if (count_ace && cards.map(&:value).include?(1))
    cards.max
  end
end
