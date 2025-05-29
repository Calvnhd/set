local Logger = require('core.logger')

function love.load()
    -- Initialize logging system first
    Logger.initialize()
    Logger.info("Game starting up")
    -- Set background color
    love.graphics.setBackgroundColor(0.34, 0.45, 0.47)

    Logger.info("Game initialization complete")
end

function love.update(dt)
end

function love.draw()
end

function love.keypressed(key)
    Logger.trace("Key pressed: %s", key)
end

function love.mousepressed(x, y, button)
    Logger.trace("Mouse pressed: (%d, %d) button %d", x, y, button)
end

function love.mousereleased(x, y, button)
end

function love.quit()
    Logger.info("Game shutting down")
    Logger.shutdown()
end
