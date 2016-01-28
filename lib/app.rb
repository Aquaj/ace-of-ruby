require_relative 'controller'
require_relative 'router'
require 'pry-byebug'

controller = Controller.new
router = Router.new(controller)

router.run
