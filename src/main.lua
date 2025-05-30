-- Main entry point for Set
local Logger = require('core.Logger')
local EventRegistry = require('config.EventRegistry')
local EventManager = require('core.EventManager')
local SceneManager = require('core.SceneManager')

---------------
-- functions --
---------------

function love.load()
    -- Initialize logging system first
    Logger.initialize()
    Logger.info("Game starting up")
    SceneManager.initialize()
    Logger.info("Game initialization complete")
end

function love.update(dt)
    SceneManager.update(dt)
end

function love.draw()
    SceneManager.draw()

end

function love.keypressed(key)
    Logger.trace("Key pressed: %s", key)
    SceneManager.keypressed(key)

end

function love.mousepressed(x, y, button)
    Logger.trace("Mouse pressed: (%d, %d) button %d", x, y, button)
    SceneManager.mousepressed(x, y, button)

end

function love.mousereleased(x, y, button)
    SceneManager.mousereleased(x, y, button)

end

function love.quit()
    Logger.info("Game shutting down")
    Logger.shutdown()
end
