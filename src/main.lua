-- Main entry point for refactored Set game

local SceneManager = require('core.sceneManager')
local InputController = require('controllers.inputController')
local MenuScene = require('scenes.menuScene')
local GameScene = require('scenes.gameScene')
local EventManager = require('core.eventManager')

-- Love2D callback for initialization
function love.load()
    -- Set background color
    love.graphics.setBackgroundColor(0.34, 0.45, 0.47)
    
    -- Register scenes
    SceneManager.registerScene('menu', MenuScene)
    SceneManager.registerScene('game', GameScene)
      -- Subscribe to scene change events
    EventManager.subscribe('scene:changeToGame', function(gameMode)
        SceneManager.changeScene('game', gameMode)
    end)
    
    EventManager.subscribe('scene:changeToMenu', function()
        SceneManager.changeScene('menu')
    end)
    
    -- Start with menu scene
    SceneManager.changeScene('menu')
end

-- Love2D callback for updating game state
function love.update(dt)
    SceneManager.update(dt)
end

-- Love2D callback for drawing
function love.draw()
    SceneManager.draw()
end

-- Love2D callback for key press events
function love.keypressed(key)
    InputController.keypressed(key)
    SceneManager.keypressed(key)
end

-- Love2D callback for mouse press events
function love.mousepressed(x, y, button)
    InputController.mousepressed(x, y, button)
    SceneManager.mousepressed(x, y, button)
end

-- Love2D callback for mouse release events
function love.mousereleased(x, y, button)
    InputController.mousereleased(x, y, button)
    SceneManager.mousereleased(x, y, button)
end
