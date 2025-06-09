-- Game Controller - Game logic coordination between models/services/views
local GameController = {}

-- required modules
local Logger = require('core.Logger')
local Constants = require('config.Constants')
local GameModel = require('models.GameModel')
local CardModel = require('models.CardModel')
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
    Logger.info("GameController", "Initializing game controller")
end

function GameController.setUpNewGame(gameMode)
    GameController.resetRoundState()
    if gameMode == Constants.GAME_MODE.CLASSIC then
        Logger.info("GameController",  "Setting up CLASSIC game")
        RoundState.RoundSequence = GameController.fetchRoundSequence("classic")
    elseif gameMode == Constants.GAME_MODE.ROGUE then
        Logger.info("GameController",  "Setting up ROGUE game")
        RoundState.RoundSequence = GameController.fetchRoundSequence("rogue")
    else
        Logger.error("GameController",  "Specified game mode does not have a matching round definition")
        error("Specified game mode does not have a matching round definition")
    end
    GameController.initializeCurrentRound()
end

function GameController.initializeCurrentRound()
    local round = RoundState.RoundSequence[RoundState.currentRoundIndex]
    -- Debug print the config
    -- Logger.trace("GameController", "--- BEGIN CONFIG ROUND DUMP ---")
    -- GameController.debugPrintConfig(round)
    -- Logger.trace("GameController", "--- END CONFIG ROUND DUMP ---")
    -- Apply configuration
    GameModel.initializeRound(round)
    DeckModel.createFromConfig(round)
    DeckModel.shuffle()
    GameController.dealInitialCards()
    -- Check initial board state.  Probably move this into config validation
    -- GameController.checkRoundCompletion()
end

function GameController.resetRoundState()
    RoundState.RoundSequence = {}
    RoundState.currentRoundIndex = 1
end

-- fetches and validates a round config taken from RoundDefinitions
function GameController.fetchRoundSequence(sequenceType)
    Logger.info("GameController",  "Setting new round sequence: " .. sequenceType)
    local sequence = RoundDefinitions.getSequence(sequenceType)
    local bValid, message = ConfigValidator.validateRoundSequence(sequence)
    if not bValid then
        Logger.error("GameController",  "Invalid round configuration: " .. message)
        error("Invalid round configuration: " .. message)
    end
    return sequence
end

function GameController.dealInitialCards()
    Logger.trace("GameController", "dealing initial cards")
    local boardSize = GameModel.getBoardSize()
    for i = 1, boardSize do
        local cardRef = DeckModel.takeCard()
        if cardRef then
            local cardData = CardModel._getInternalData(cardRef)
            GameModel.setCardAtPosition(i, cardRef)
        end
    end
end

-- function GameController.debugPrintConfig(config, indent)
--     indent = indent or 0
--     local indentStr = string.rep("  ", indent)
-- 
--     if type(config) ~= "table" then
--         Logger.trace("GameController", indentStr .. tostring(config))
--         return
--     end
-- 
--     for k, v in pairs(config) do
--         if type(v) == "table" then
--             Logger.trace("GameController", indentStr .. k .. " = {")
--             GameController.debugPrintConfig(v, indent + 1)
--             Logger.trace("GameController", indentStr .. "}")
--         else
--             Logger.trace("GameController", indentStr .. k .. " = " .. tostring(v))
--         end
--     end
-- end

return GameController

