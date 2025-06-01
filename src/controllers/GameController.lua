-- Game Controller - Game logic coordination between models/services/views
local GameController = {}

-- required modules
local Logger = require('core.Logger')
local Constants = require('config.Constants')
local GameModeModel = require('models.GameModeModel')
local RoundManager = require('services.RoundManager')
local GameModel = require('models.GameModel')
local DeckModel = require('models.DeckModel')

---------------
-- functions --
---------------

function GameController.initialize()
    Logger.info('Initializing game controller')
end

function GameController.setUpNewGame(gameMode)
    GameModeModel.setMode(gameMode)
    GameModel.reset()
    if GameModeModel.getMode() == Constants.GAME_MODE.CLASSIC then
        GameController.setUpClassic()
    elseif GameModeModel.getMode() == Constants.GAME_MODE.ROGUE then
        GameController.setUpRogue()
    end
end

function GameController.setUpClassic()
    Logger.info("Setting up CLASSIC game")
    local config = RoundManager.setRoundSequence("classic")

    -- Apply configuration
    GameModel.initializeGame(config)
    DeckModel.createFromConfig(config)
    DeckModel.shuffle()
    GameController.dealInitialCards()
    -- Check initial board state.  Probably move this into config validation
    GameController.checkRoundCompletion()

end

function GameController.setUpRogue()
    Logger.info("Setting up ROGUE game")
end

return GameController

