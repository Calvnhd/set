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
local BoardView = require('views.BoardView')
local RulesService = require('services.RulesService')

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
        Logger.info("GameController", "Setting up CLASSIC game")
        RoundState.RoundSequence = GameController.fetchRoundSequence("classic")
    elseif gameMode == Constants.GAME_MODE.ROGUE then
        Logger.info("GameController", "Setting up ROGUE game")
        RoundState.RoundSequence = GameController.fetchRoundSequence("rogue")
    else
        Logger.error("GameController", "Specified game mode does not have a matching round definition")
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
    Logger.info("GameController", "Setting new round sequence: " .. sequenceType)
    local sequence = RoundDefinitions.getSequence(sequenceType)
    local bValid, message = ConfigValidator.validateRoundSequence(sequence)
    if not bValid then
        Logger.error("GameController", "Invalid round configuration: " .. message)
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
function GameController.onMousePressed(x, y, button)
    Logger.trace("GameController", "Handling mouse press: (%d, %d) button %d", x, y, button)
    local clickedCardIndex = BoardView.getCardAtPosition(x, y)
    if clickedCardIndex then
        local board = GameModel.getBoard()
        local cardRef = board[clickedCardIndex]
        local selectedCards = GameModel.getSelectedCards()
        local bClickedCardIsSelected = CardModel.isSelected(cardRef)
        -- Get current set size for this game mode
        local currentSetSize = GameModel.getCurrentSetSize()
        -- If we already have the required number of cards selected and trying to select a new one, do nothing
        if #selectedCards == currentSetSize and not bClickedCardIsSelected then
            return
        end
        -- Toggle the card's selection state
        CardModel.toggleSelected(cardRef)
        -- Disable hint mode when a card is selected
        GameModel.clearHint()
    end
end

-- Input handling.  Delegated by SceneManager.
function GameController.onKeyPressed(key)
    Logger.trace("GameController", "Handling key: %s", key)
    -- quit game at any time
    if key == "escape" then
        love.event.quit()
    end
    -- If game has ended, only respond to spacebar to start a new game
    if GameModel.hasGameEnded() then
        if key == "space" then
            GameController.setupNewGame()
            return
        else
            return -- Ignore all other keypresses in game end state
        end
    end
    -- Player finds a set
    if key == "s" then
        local selectedCards = GameModel.getSelectedCards()
        local setSize = GameModel.getCurrentSetSize()
        if #selectedCards == setSize then
            GameController.processSelectedCards()
            return
        end
        Logger.trace("GameController", "Must select %d cards to make a set. Clearing selection.", setSize)
    end
    -- Clear card selection on any other key input
    GameController.clearCardSelection()
end

-- Process selected cards (validate and remove if valid set)
function GameController.processSelectedCards()
    Logger.trace("GameController", "Processing selected cards")
    local selectedCards = GameModel.getSelectedCards()
    local board = GameModel.getBoard()
    local currentSetSize = GameModel.getCurrentSetSize()

    if #selectedCards == currentSetSize then
        local cardRefs = {}
        for i, selectedBoardIndex in ipairs(selectedCards) do
            cardRefs[i] = board[selectedBoardIndex]
        end
        local bIsValid, message = RulesService.validateSelectedCardsOfSize(selectedCards, board, currentSetSize)
        Logger.trace("GameController", "Result: "..message)
        if bIsValid then
            -- Valid set - remove cards and increment score
            -- GameController.removeValidSet(selectedCards)
            -- GameModel.incrementScore()
            -- GameModel.incrementSetsFound()
            -- Check for round completion in both modes
            -- GameController.checkRoundCompletion()
        else
            -- Invalid set - animate flash red and decrement score
            -- GameController.animateInvalidSet(selectedCards)
            -- GameModel.decrementScore()
        end
    end
end

-- Clear all card selections
function GameController.clearCardSelection()
    local board = GameModel.getBoard()
    local boardSize = GameModel.getBoardSize()

    for i = 1, boardSize do
        local cardRef = board[i]
        if cardRef then
            CardModel.setSelected(cardRef, false)
        end
    end
end



-- module return
return GameController 

