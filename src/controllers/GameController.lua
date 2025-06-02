-- Game Controller - Game logic coordination between models/services/views
local GameController = {}

-- required modules
local Logger = require('core.Logger')
local Constants = require('config.Constants')
local GameModeModel = require('models.GameModeModel')
local GameModel = require('models.GameModel')
local DeckModel = require('models.DeckModel')
local RoundDefinitions = require('config.RoundDefinitions')
local ConfigValidator = require('services.ConfigValidator')

-- Round state
local RoundState = {
    RoundSequence = {},
    currentRoundIndex = 1
}

---------------
-- functions --
---------------

function GameController.initialize()
    Logger.info('Initializing game controller')
end

function GameController.setUpNewGame(gameMode)
    RoundState.RoundSequence = GameController.loadRoundSequenceForMode(gameMode)
    local firstRound = RoundState.RoundSequence[1]
    -- Debug print the config
    Logger.trace("--- BEGIN CONFIG FIRST ROUND DUMP ---")
    GameController.debugPrintConfig(firstRound)
    Logger.trace("--- END CONFIG FIRST ROUND DUMP ---")
    -- Apply configuration
    GameModel.initializeRound(firstRound)
    DeckModel.createFromConfig(firstRound)
    DeckModel.shuffle()
    GameController.dealInitialCards()
    -- Check initial board state.  Probably move this into config validation
    -- GameController.checkRoundCompletion()
end

function GameController.resetRoundState()
    RoundState.RoundSequence = {}
    RoundState.currentRoundIndex = 1
end

function GameController.loadRoundSequenceForMode(gameMode)
    GameController.resetRoundState()
    if gameMode == Constants.GAME_MODE.CLASSIC then
        Logger.info("Setting up CLASSIC game")
        return GameController.fetchRoundSequence("classic")
    elseif gameMode == Constants.GAME_MODE.ROGUE then
        Logger.info("Setting up ROGUE game")
        return GameController.fetchRoundSequence("rogue")
    else
        Logger.error("Specified game mode does not have a matching round definition")
        error("Specified game mode does not have a matching round definition")
    end
end

-- fetches and validates a round config taken from RoundDefinitions
function GameController.fetchRoundSequence(sequenceType)
    Logger.info("Setting new round sequence: " .. sequenceType)
    local sequence = RoundDefinitions.getSequence(sequenceType)
    local bValid, message = ConfigValidator.validateRoundSequence(sequence)
    if not bValid then
        Logger.error("Invalid round configuration: " .. message)
        error("Invalid round configuration: " .. message)
    end
    return sequence
end

function GameController.dealInitialCards()
    local boardSize = GameModel.getBoardSize()
    for i = 1, boardSize do
        local cardRef = DeckModel.takeCard()
        if cardRef then
            GameModel.setCardAtPosition(i, cardRef)
        end
    end
end

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

