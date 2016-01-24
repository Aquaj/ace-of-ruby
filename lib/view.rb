class View
  # @view.get_number_of_players()
  def get_number_of_players
    answer = 0
    puts "How many people will be playing?"
    until answer.to_i >= 3
      print "> "
      answer = gets.chomp
      puts "Please type in a number using digits." unless answer.match(/\d+/)
      puts "We need at least three players: a dealer, someone betting the small blind, and someone betting the big blind." if answer.match(/\d+/) && (0...3).include?(answer.to_i)
    end
    answer.to_i
  end

  # @view.get_player_name(@PLAYERS_NAMES)
  def get_player_name(list_of_names)
    system `clear`
    puts "Please state a name?"
    print "> "
    name = gets.chomp
    while list_of_names.include? name
      puts "This name is already taken, sorry !"
      print "> "
      name = gets.chomp
    end
    name
  end

  # @view.get_player_stake
  def get_player_stake(small_blind)
    answer = 0
    min_stake = small_blind * 40
    max_stake = small_blind * 200
    puts "How much are you bringing to the table?"
    until (min_stake..max_stake).include? answer.to_i
      print "> "
      answer = gets.chomp
      if !answer.match(/\d+/)
        puts "Please type in a number using digits."
      else
        puts "You can't bring that much in a game." if answer.to_i > max_stake
        puts "You need to bring some more cash to play." if answer.to_i < min_stake
      end
    end
    answer.to_i
  end

  # @view.state_of_the_game(@community_cards)
  def state_of_the_game(community, to_match)
    system `clear`
    if community.length > 0
      puts "There are currently #{community.length} cards on the table :"
      puts "[#{community.reduce("") { |a, e| a + "[ "+e.to_s.rjust(4)+" ]" }}]"
      puts
    else
      puts
      puts
      puts
    end
    puts "You currently have to match $#{to_match}"
  end

  # @view.player_state(player.name, player.hand, @pot.bet_of player, player.stake)
  def player_state(name, hand)
    puts "Hello #{name}."
    puts 'This is your hand :'
    puts "[#{hand.reduce("") { |a, e| a + "[ "+e.to_s.rjust(4)+" ]" }}]"
  end

  # @view.state_of_game_for_player(@pot.bet_of player, player.stake, to_match)
  def state_of_game_for_player(bet, stake)
    puts "Your bet: $#{bet} || $#{stake} in your stake"
  end

  # @view.wait_for_next
  def wait_for_next(name)
    puts "It's now #{name}'s turn. Press Enter when ready."
    gets.chomp
  end

  # @view.player_choice(current, to_match, check)
  def player_choice(is_checking)
    answer = 'z'
    until "crf".include? answer
      puts "Do you wanna "+'(c)' + (is_checking ? 'heck' : 'all')+" the bet, (r)aise or (f)old ?"
      print '> '
      answer = gets.chomp
      answer = 'z' if answer == ""
    end
    answer
  end

  def end_of_part
    puts "Everybody checked! Let's move on."
    gets.chomp
  end

  def burnt
    puts 'The Dealer burnt one card.'
  end

  def big_reveal(community, cards)
    system `clear`
    print "Cards on the table :"
    puts "[#{community.reduce("") { |a, e| a + "[ "+e.to_s.rjust(4)+" ]" }}]"
    cards.each do |name, hand|
      puts "- #{name.capitalize} :"
      puts "\t[#{hand.reduce("") { |a, e| a + "[ "+e.to_s.rjust(4)+" ]" }}]"
    end
    puts
  end

  def present_winner(winner, type, card)
    case type
    when 0
      type = "a highest card of #{card}"
    when 1
      type = "a pair of #{card}s"
    when 2
      type = "two pairs, the highest at #{card}s"
    when 3
      type = "three #{card}s"
    when 4
      type = "a straight to the #{card}"
    when 5
      type = "a flush to the #{card}"
    when 6
      type = "a house to the #{card}s"
    when 7
      type = "four #{card}s"
    when 8
      type = "a straight flush to the #{card}"
    when 9
      type = "a royal flush"
    end
    puts "The winner is #{winner} with #{type} !"
  end

  # @view.folding
  def folding
    answer = "z"
    until "yn".include? answer
      puts "Are you sure you want to fold ? (y/n)"
      print "> "
      answer = gets.chomp
    end
    answer
  end

  def folded
    "You folded."
  end

  # @view.calling(check)
  def calling(is_checking)
    puts  "You "+'c' + (is_checking ? 'hecked' : 'alled')+" the bet."
  end

  # @view.raising
  def raising
    answer = 'z'
    puts 'How much do you wanna raise?'
    until answer.to_i > 0
      print "> "
      answer = gets.chomp
      puts "You need to answer using digits." unless answer.match(/\d+/)
    end
    answer.to_i
  end

end

