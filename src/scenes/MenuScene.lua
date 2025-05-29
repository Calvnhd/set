-- Menu Scene - Main menu 
local MenuScene = {}

-- required modules
local EventManager = require('core.EventManager')
local Events = require('core.EventRegistry')
local Logger = require('core.Logger')
local MenuView = require('views.MenuView')


---------------
-- functions --
---------------

function MenuScene.enter()
    Logger.trace("Entering main menu scene")
end

function MenuScene.exit()
    Logger.trace("Exiting menu scene")
end

-- Love2D callbacks called via main -> SceneManager -> current scene
function MenuScene.draw()
end
function MenuScene.keypressed(key)
    Logger.trace("Menu scene handling key: %s", key)
    if key == "escape" then
        Logger.info("Escape key pressed. Quitting game")
        love.event.quit()
    end
end
function MenuScene.mousepressed(x, y, button)
    Logger.trace("Menu scene handling mouse press: (%d, %d) button %d", x, y, button)
end

-- Update menu (if needed for animations)
-- function MenuScene.update(dt)
-- end

return MenuScene
