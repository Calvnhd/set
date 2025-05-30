-- Game Scene - Main gameplay scene with full game functionality
local GameScene = {}

-- required modules
local EventManager = require('core.EventManager')
local Events = require('config.EventRegistry')
local Logger = require('core.Logger')
local GameController = require('controllers.GameController')

---------------
-- functions --
---------------

function GameScene.enter(gameMode)
    Logger.info("Entering game scene")
    if not gameMode then
        Logger.error("No gameMode specified")
        error("No gameMode specified")
    end
    Logger.info("Loading gameMode " .. gameMode)
    -- Initialize game controller
    GameController.initialize()
    -- Setup new game with specified mode
    GameController.setUpNewGame(gameMode)
end

function GameScene.exit()
    Logger.info("Entering game scene")
end

return GameScene
