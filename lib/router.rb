# Router.
class Router
  def initialize(controller)
    @controller = controller
    @running = true
    @first_game = true
  end

  def run
    while @running
      @controller.game
      print "\nDo you want to play another game ? (y/n)\n> "
      answer = gets.chomp
      if answer == 'n'
        stop
      elsif answer != 'y'
        puts 'Please answer (y)es or (n)o.'
      end
    end
  end

  def stop
    @running = false
  end
end
