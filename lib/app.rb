require_relative 'controller'
require_relative 'router'

controller = Controller.new
router = Router.new(controller)

router.run
