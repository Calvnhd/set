-- Input Controller - Centralized input handling with event emission

local EventManager = require('core.eventManager')

local InputController = {}

-- Handle keyboard input
function InputController.keypressed(key)
    EventManager.emit('input:keypressed', key)
end

-- Handle mouse press events
function InputController.mousepressed(x, y, button)
    EventManager.emit('input:mousepressed', x, y, button)
end

-- Handle mouse release events
function InputController.mousereleased(x, y, button)
    EventManager.emit('input:mousereleased', x, y, button)
end

-- Handle mouse movement (if needed)
function InputController.mousemoved(x, y, dx, dy)
    EventManager.emit('input:mousemoved', x, y, dx, dy)
end

return InputController
