# Class handling the bets of every player.
class Pot < Hash
  def initialize(players)
    players.each { |player| self[player] = 0 }
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

  def add_bet(player, bet)
    self[player] += bet
  end

  def current_bet
    select { |player, _bet| player.in_game? }.max_by { |_player, bet| bet }[1]
  end
end
