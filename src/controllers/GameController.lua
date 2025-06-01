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
    if GameModeModel.getMode() == Constants.GAME_MODE.CLASSIC then
        GameController.setUpClassic()
    elseif GameModeModel.getMode() == Constants.GAME_MODE.ROGUE then
        GameController.setUpRogue()
    end
end

function GameController.setUpClassic()
    Logger.info("Setting up CLASSIC game")
    local config = RoundManager.setRoundSequence("classic")
    -- Debug print the config
    Logger.trace("--- BEGIN CONFIG DUMP ---")
    GameController.debugPrintConfig(config[1]) -- Print first round config
    Logger.trace("--- END CONFIG DUMP ---")
    -- Apply configuration
    GameModel.initializeGame(config)
    DeckModel.createFromConfig(config[1])
    DeckModel.shuffle()
    GameController.dealInitialCards()

    -- Check initial board state.  Probably move this into config validation
    -- GameController.checkRoundCompletion()

end

function GameController.setUpRogue()
    Logger.info("Setting up ROGUE game")
end

-- Deal initial cards to the board
function GameController.dealInitialCards()
    local boardSize = GameModel.getBoardSize()
    for i = 1, boardSize do
        local cardRef = DeckModel.takeCard()
        if cardRef then
            GameModel.setCardAtPosition(i, cardRef)
        end
    end
end

-- Add this function to your code
function GameController.debugPrintConfig(config, indent)
    indent = indent or 0
    local indentStr = string.rep("  ", indent)

    if type(config) ~= "table" then
        Logger.trace(indentStr .. tostring(config))
        return
    end

    for k, v in pairs(config) do
        if type(v) == "table" then
            Logger.trace(indentStr .. k .. " = {")
            GameController.debugPrintConfig(v, indent + 1)
            Logger.trace(indentStr .. "}")
        else
            Logger.trace(indentStr .. k .. " = " .. tostring(v))
        end
    end
end

return GameController

