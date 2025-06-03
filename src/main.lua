-- Main entry point for refactored Set game
local SceneManager = require('core.sceneManager')
local EventManager = require('core.eventManager')
local Events = require('core.events')
local MenuScene = require('scenes.menuScene')
local GameScene = require('scenes.gameScene')
local InputController = require('controllers.inputController')
local Logger = require('core.logger')

-- Love2D callback for initialization
function love.load()
    -- Initialize logging system first
    Logger.initialize()
    Logger.info("Game starting up")
    -- Set background color
    love.graphics.setBackgroundColor(0.34, 0.45, 0.47)
    -- Register scenes
    SceneManager.registerScene('menu', MenuScene)
    SceneManager.registerScene('game', GameScene)
    -- Subscribe to scene change events
    EventManager.subscribe(Events.SCENE.CHANGE_TO_GAME, function(gameMode)
        Logger.info("Scene change requested: %s mode", gameMode)
        SceneManager.changeScene('game', gameMode)
    end)
    EventManager.subscribe(Events.SCENE.CHANGE_TO_MENU, function()
        Logger.info("Scene change requested: menu")
        SceneManager.changeScene('menu')
    end)
    -- Start with menu scene
    SceneManager.changeScene('menu')
    Logger.info("Game initialization complete")
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
    Logger.trace("Key pressed: %s", key)
    InputController.keypressed(key)
    SceneManager.keypressed(key)
end

-- Love2D callback for mouse press events
function love.mousepressed(x, y, button)
    Logger.trace("Mouse pressed: (%d, %d) button %d", x, y, button)
    InputController.mousepressed(x, y, button)
    SceneManager.mousepressed(x, y, button)
end

-- Love2D callback for mouse release events
function love.mousereleased(x, y, button)
    InputController.mousereleased(x, y, button)
    SceneManager.mousereleased(x, y, button)
end

-- Love2D callback for game exit
function love.quit()
    Logger.info("Game shutting down")
    Logger.shutdown()
end
