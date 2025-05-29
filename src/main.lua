
local InputController = require('controllers.inputController')

-- Love2D callback for key press events
function love.keypressed(key)
    InputController.keypressed(key)
end

-- Love2D callback for mouse press events
function love.mousepressed(x, y, button)
    InputController.mousepressed(x, y, button)
end

-- Love2D callback for mouse release events
function love.mousereleased(x, y, button)
    InputController.mousereleased(x, y, button)
end

