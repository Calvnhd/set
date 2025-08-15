-- Input Controller - Centralized input handling with event emission
local InputController = {}

-- required modules
local EventManager = require('core.EventManager')
local Events = require('config.EventRegistry')
local Logger = require('core.Logger')

---------------
-- functions --
---------------

-- Handle keyboard input
function InputController.keypressed(key)
    Logger.trace("InputController", "Key pressed: %s", key)
    EventManager.emit(Events.INPUT.KEY_PRESSED, key)
end

-- Handle mouse press events
function InputController.mousepressed(x, y, button)
    Logger.trace("InputController", "Mouse pressed: (%d, %d) button %d", x, y, button)
    EventManager.emit(Events.INPUT.MOUSE_PRESSED, x, y, button)
end

return InputController