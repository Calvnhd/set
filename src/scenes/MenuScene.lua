-- Menu Scene - Main menu 
local MenuScene = {}

-- required modules
local EventManager = require('core.EventManager')
local Events = require('config.EventRegistry')
local Logger = require('core.Logger')
local MenuView = require('views.MenuView')
local Constants = require('config.Constants')

---------------
-- functions --
---------------

function MenuScene.enter()
    Logger.trace("Entering main menu scene")
    MenuView.initialize()
end

function MenuScene.exit()
    Logger.trace("Exiting menu scene")
end

-- Love2D callbacks. Called via main -> SceneManager -> current scene
function MenuScene.draw()
    MenuView.draw()
end
-- Input events, delegated by SceneManager
function MenuScene.onKeyPressed(key)
    Logger.trace("Menu scene handling key: %s", key)
    if key == "escape" then
        Logger.info("Escape key pressed. Quitting game")
        love.event.quit()
    end
end
function MenuScene.onMousePressed(x, y, button)
    Logger.trace("Menu scene handling mouse press: (%d, %d) button %d", x, y, button)
    if button == 1 then -- Left mouse button
        if MenuView.isClassicButtonClicked(x, y) then
            Logger.info("Classic mode button clicked")
            EventManager.emit(Events.SCENE.REQUEST_CHANGE, Constants.SCENE.GAME, Constants.GAME_MODE.CLASSIC)
        elseif MenuView.isRogueButtonClicked(x, y) then
            Logger.info("Rogue mode button clicked")
            EventManager.emit(Events.SCENE.REQUEST_CHANGE, Constants.SCENE.GAME, Constants.GAME_MODE.ROGUE)
        end
    end
end

return MenuScene
