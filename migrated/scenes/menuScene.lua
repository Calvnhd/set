-- Menu Scene - Main menu with play button interaction

local MenuView = require('views.menuView')
local EventManager = require('core.eventManager')

local MenuScene = {}

-- Enter the menu scene
function MenuScene.enter()
    MenuView.initialize()
    -- Subscribe to input events
    EventManager.subscribe('input:keypressed', MenuScene.keypressed)
    EventManager.subscribe('input:mousepressed', MenuScene.mousepressed)
end

-- Exit the menu scene
function MenuScene.exit()
    -- Unsubscribe from events
    EventManager.unsubscribe('input:keypressed', MenuScene.keypressed)
    EventManager.unsubscribe('input:mousepressed', MenuScene.mousepressed)
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
    if key == "escape" then
        love.event.quit()
    end
end

-- Handle mouse press events
function MenuScene.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        if MenuView.isPlayButtonClicked(x, y) then
            EventManager.emit('scene:changeToGame')
        end
    end
end

return MenuScene
