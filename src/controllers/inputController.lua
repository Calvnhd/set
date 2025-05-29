-- Input Controller - Centralized input handling with event emission
local EventManager = require('core.eventManager')
local Events = require('core.events')

local InputController = {}

-- Handle keyboard input
function InputController.keypressed(key)
    EventManager.emit(Events.INPUT.KEY_PRESSED, key)
end

-- Handle mouse press events
function InputController.mousepressed(x, y, button)
    EventManager.emit(Events.INPUT.MOUSE_PRESSED, x, y, button)
end

-- Handle mouse release events
function InputController.mousereleased(x, y, button)
    EventManager.emit(Events.INPUT.MOUSE_RELEASED, x, y, button)
end

-- Handle mouse movement (if needed)
function InputController.mousemoved(x, y, dx, dy)
    EventManager.emit(Events.INPUT.MOUSE_MOVED, x, y, dx, dy)
end

return InputController
