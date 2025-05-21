-- filepath: c:\source\set\src\main.lua
-- Main entry point for Love2D card game

local game = require('game')

-- Love2D callback for initialization
function love.load()
    -- Initialize window settings
    love.window.setTitle("Card Game")
    love.window.setMode(800, 600)
    
    -- Set default font
    love.graphics.setNewFont(14)
    
    -- Initialize game state
    game.initialize()
end

-- Love2D callback for updating game state
function love.update(dt)
    -- Update game state with delta time
    game.update(dt)
end

-- Love2D callback for drawing
function love.draw()
    -- Draw game elements
    game.draw()
end

-- Love2D callback for key press events
function love.keypressed(key)
    -- Handle key press events
    if key == "escape" then
        love.event.quit()
    end
    
    game.keypressed(key)
end

-- Love2D callback for mouse press events
function love.mousepressed(x, y, button)
    -- Handle mouse press events
    game.mousepressed(x, y, button)
end

-- Love2D callback for mouse release events
function love.mousereleased(x, y, button)
    -- Handle mouse release events
    game.mousereleased(x, y, button)
end