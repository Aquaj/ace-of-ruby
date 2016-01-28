# Class handling the bets of every player.
class Pot < Hash

  @@pots = []

  def initialize(players)
    players.each { |player| self[player] = 0 }
    @@pots.insert << self
    @capped = nil
  end

  def bet_of(player)
    if player.in_game?
      self[player]
    else
      0
    end
  end

  def whole_pot
    values.reduce(0) { |a, e| a + e }
  end

  def everyone_at_bet?
    select { |player, _bet| player.in_game? }
      .map { |_player, bet| bet }
      .to_a
      .uniq
      .length == 1
  end

  def capped?
    !@capped.nil?
  end

  def cap(player)
    @capped = player
  end

  def split_pot(player, all_in)     # ALMOST THERE JUST FIGURE OUT WHY WE GOT THAT EMPTY POT AT @@POTS[1]. OTHERWISE GOLDEN.
    binding.pry
    all_in_play = false
    if self == @@pots[-1]
      p2 = Pot.new(self.keys)
    else
      p2 = @@pots[@@pots.index(self)+1]
    end
    if @capped
      if (self[player] == self.values.max)
        min = @capped
        max = player
        p_cap = min
        p2_cap = max if all_in
      else
        min = player
        max = @capped
        p_cap = min
        p2_cap = max
      end
      self.each do |play, bet|
        if play == player
          all_in_play = all_in
        end
        if play == @capped
          all_in_play = true
        end
        p2.add_bet(play, [bet - self[min], 0].max, all_in_play)
        p2.cap(p2_cap) if p2_cap
        self[play] = [self[min], self[play]].min
        cap(p_cap)
      end
    else
      min = self[player]
      self.each do |play, bet|
        if play == player
          all_in_play = all_in
        end
        p2.add_bet(play, [bet - self[min], 0].max, all_in_play)
        self[play] = [min, self[play]].min
      end
      cap(min)
    end
    return p2
  end

  def add_bet(player, bet, all_in)
    self[player] += bet
    if @capped && self[player] > self[@capped]
        split_pot(player, all_in)
    elsif all_in && self.any? { |_k,v| v > self[player] }
        split_pot(player, all_in)
    elsif all_in
        self.cap(player)
    end
  end

  def current_bet
    select { |player, _bet| player.in_game? }.max_by { |_player, bet| bet }[1]
  end

  def self.current_bet
    @@pots[0].keys.map { |p| bet_of(p) }.max
  end

  def self.bet_of(player)
    @@pots.reduce(0) { |bet, pot| bet + pot[player].to_i }
  end

  def self.pots
    @@pots
  end
end
