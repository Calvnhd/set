-- Main entry point for set prototype game

local game = require('game')

-- Love2D callback for initialization
function love.load()
    game.initialize()
end

-- Love2D callback for updating game state
function love.update(dt)
    game.update(dt)
end

-- Love2D callback for drawing
function love.draw()
    game.draw()
end

-- Love2D callback for key press events
function love.keypressed(key)
    game.keypressed(key)
end

-- Love2D callback for mouse press events
function love.mousepressed(x, y, button)
    game.mousepressed(x, y, button)
end

-- Love2D callback for mouse release events
function love.mousereleased(x, y, button)
end