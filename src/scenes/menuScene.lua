-- Menu Scene - Main menu with play button interaction

local MenuView = require('views.menuView')
local EventManager = require('core.eventManager')
local Logger = require('core.logger')

local MenuScene = {}

-- Enter the menu scene
function MenuScene.enter()
    Logger.info("Entering menu scene")
    MenuView.initialize()
    -- Subscribe to input events
    EventManager.subscribe('input:keypressed', MenuScene.keypressed)
    EventManager.subscribe('input:mousepressed', MenuScene.mousepressed)
    Logger.trace("Menu scene subscribed to input events")
end

-- Exit the menu scene
function MenuScene.exit()
    Logger.info("Exiting menu scene")
    -- Unsubscribe from events
    EventManager.unsubscribe('input:keypressed', MenuScene.keypressed)
    EventManager.unsubscribe('input:mousepressed', MenuScene.mousepressed)
    Logger.trace("Menu scene unsubscribed from input events")
end

-- Update menu (if needed for animations)
function MenuScene.update(dt)
    -- Menu animations or logic would go here
end

-- Draw the menu
function MenuScene.draw()
    MenuView.draw()
end

-- Handle keyboard input
function MenuScene.keypressed(key)
    Logger.trace("Menu scene handling key: %s", key)
    if key == "escape" then
        Logger.info("Escape key pressed - quitting game")
        love.event.quit()
    end
end

-- Handle mouse press events
function MenuScene.mousepressed(x, y, button)
    Logger.trace("Menu scene handling mouse press: (%d, %d) button %d", x, y, button)
    
    if button == 1 then -- Left mouse button
        if MenuView.isClassicButtonClicked(x, y) then
            Logger.info("Classic mode button clicked")
            EventManager.emit('scene:changeToGame', 'classic')
        elseif MenuView.isRogueButtonClicked(x, y) then
            Logger.info("Rogue mode button clicked")
            EventManager.emit('scene:changeToGame', 'rogue')
        end
    end
end

return MenuScene
