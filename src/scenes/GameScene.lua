local GameScene = {}

-- required modules
local EventManager = require('core.EventManager')
local Events = require('config.EventRegistry')
local Logger = require('core.Logger')

---------------
-- functions --
---------------

function GameScene.enter(gameMode)
    Logger.info("Entering game scene")
    if not gameMode then
        Logger.error("No gameMode specified")
        error("No gameMode specified")
        return
    end
    Logger.info("Loading gameMode " .. gameMode)
end

function GameScene.exit()
    Logger.info("Entering game scene")
end

return GameScene
