-- Game Controller - Game logic coordination between models/services/views
local GameController = {}

-- required modules
local Logger = require('core.Logger')
local Constants = require('config.Constants')
local GameModeModel = require('models.gameModeModel')

---------------
-- functions --
---------------

function GameController.initialize()
    Logger.info('Initializing game controller')
end

function GameController.setUpNewGame(gameMode)
    GameModeModel.setMode(gameMode)
    if GameModeModel.getMode() == Constants.GAME_MODE.CLASSIC then
        GameController.setUpClassic()
    elseif GameModeModel.getMode() == Constants.GAME_MODE.ROGUE then
        GameController.setUpRogue()
    end
end

function GameController.setUpClassic()
    Logger.info("Setting up CLASSIC game")
end

function GameController.setUpRogue()
    Logger.info("Setting up ROGUE game")
end

return GameController

