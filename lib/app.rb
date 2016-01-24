require_relative 'mvc_controller'
require_relative 'mvc_router'

controller = Controller.new
router = Router.new(controller)

router.run
