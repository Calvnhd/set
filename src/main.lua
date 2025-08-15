-- Main entry point for Set
local Logger = require('core.Logger')
local EventRegistry = require('config.EventRegistry')
local EventManager = require('core.EventManager')
local SceneManager = require('core.SceneManager')
local InputController = require('controllers.InputController')

---------------
-- functions --
---------------

function love.load()
    Logger.initialize()
    Logger.info("Main", "Game starting up")
    SceneManager.initialize()
    Logger.info("Main", "Game initialization complete")
end

function love.update(dt)
    SceneManager.update(dt)
end

function love.draw()
    SceneManager.draw()
end

function love.keypressed(key)
    InputController.keypressed(key)
end

function love.mousepressed(x, y, button)
    InputController.mousepressed(x, y, button)
end

function love.quit()
    Logger.info("Main", "Game shutting down")
    Logger.shutdown()
end
