module EvaluatePoker

  def self.evaluate(hand, community_cards)
    royal_flush = check_if_royal_flush(hand + community_cards)
    straight_flush = check_if_straight_flush(hand + community_cards)
    four_of_a_kind = check_if_four(hand + community_cards)
    full_house = check_if_house(hand + community_cards)
    flush = check_if_flush(hand + community_cards)
    straight = check_if_straight(hand + community_cards)
    three_of_kind = check_if_three(hand + community_cards)
    two_pair = check_if_pairs(hand + community_cards)
    pair = check_if_pair(hand + community_cards)
    high_card = get_high_card(hand + community_cards)
  end

  def self.check_if_royal_flush(cards)
    return false if !cards.all? { |c| c.color == cards[0].color }
    cards
      .sort
      .map(&:value) == [1, 10, 11, 12, 13]
  end

  def self.check_if_straight_flush(cards)
    return false if !cards.all? { |c| c.color == cards[0].color }
    check_if_straight(cards)
  end

  def self.check_if_four(cards)
    return cards
            .group_by(&:value)
            .any? { |_k, v| v.length == 4 }
  end

  def self.check_if_house(cards)
    return check_if_pair(cards) &&
           check_if_three(cards)
  end

  def self.check_if_flush(cards)
    return cards
      .group_by(&:color)
      .any? { |_k, v| v.length == 5 }
  end

  def self.check_if_straight(cards)
    return cards
            .map(&:value)
            .sort
            .each_cons(2)
            .reduce(true) { |a, e| a &&= (e[0]+1 == e[1]) } ||
          cards
            .map(&:value)
            .map { |e| ((e+11)%13+1) }
            .sort
            .each_cons(2)
            .reduce(true) { |a, e| a &&= (e[0]+1 == e[1]) }
  end

  def self.check_if_three(cards)
    return cards
      .group_by(&:value)
      .any? { |_k, v| v.length == 3 }
  end

  def self.check_if_pairs(cards)
    return cards
      .group_by(&:value)
      .select { |_k, v| v.length == 2 }
      .length == 2
  end

  def self.check_if_pair(cards)
    return cards
      .group_by(&:value)
      .select { |_k, v| v.length == 2 }
      .length == 1
  end

  def self.get_high_card(cards)
    if cards.map(&:value).include? 1
      return cards.select { |v| v.value == 1 }[0]
    else
      return cards.max
    end
  end
end
