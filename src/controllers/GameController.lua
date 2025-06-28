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
    Logger.trace("GameController", "--- BEGIN CONFIG ROUND DUMP ---")
    GameController.debugPrintConfig(round)
    Logger.trace("GameController", "--- END CONFIG ROUND DUMP ---")
    -- Apply configuration
    GameModel.initializeRound(round)
    DeckModel.createFromConfig(round)
    DeckModel.shuffle()
    GameController.dealFullBoard()
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

function GameController.dealFullBoard()
    Logger.trace("GameController", "dealing cards to fill board")
    local board = GameModel.getBoard()
    local boardSize = GameModel.getBoardSize()
    for i = 1, boardSize do
        -- Only deal to empty positions
        if not board[i] then
            local cardRef = DeckModel.takeCard()
            if cardRef then
                local cardData = CardModel._getInternalData(cardRef)
                GameModel.setCardAtPosition(i, cardRef)
            else
                Logger.warning("GameController", "Deck ran out of cards while dealing to board")
                break
            end
        end
    end
end

function GameController.debugPrintConfig(config, indent)
    indent = indent or 0
    local indentStr = string.rep("  ", indent)

    if type(config) ~= "table" then
        Logger.trace("GameController", indentStr .. tostring(config))
        return
    end

    for k, v in pairs(config) do
        if type(v) == "table" then
            Logger.trace("GameController", indentStr .. k .. " = {")
            GameController.debugPrintConfig(v, indent + 1)
            Logger.trace("GameController", indentStr .. "}")
        else
            Logger.trace("GameController", indentStr .. k .. " = " .. tostring(v))
        end
    end
end

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
        return
    end
    -- space is the default confirm button
    if key == "space" then
        if GameModel.hasGameEnded() then
            Logger.info("GameController", "Game over, man")
            return
        end
        local selectedCards = GameModel.getSelectedCards()
        if #selectedCards == 0 then
            GameController.processNoSelectedCards()
            return
        end
        local setSize = GameModel.getCurrentSetSize()
        if #selectedCards == setSize then
            GameController.processSelectedCards()
            return
        end
        -- reset state
        GameController.clearCardSelection()
        return
    end
    -- Clear card selection on any other key input
    GameController.clearCardSelection()
    if key == "f" then
        GameController.toggleHint()
        return
    end
    -- take a card from the deck and add it to the board 
    if key == "d" then
        GameController.addCardToBoardFromDeck()
        return
    end
end

-- Takes a new card from deck and adds it to the board
function GameController.addCardToBoardFromDeck()
    local emptyPosition = GameModel.findEmptyPosition()
    if not emptyPosition then
        Logger.info("GameController", "No empty positions on board")
        return
    end
    local cardRef = DeckModel.takeCard()
    if cardRef then
        GameModel.setCardAtPosition(emptyPosition, cardRef)
        GameModel.clearHint()
    else
        Logger.info("GameController", "Deck is empty, cannot add more cards")
    end
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
        Logger.trace("GameController", "Result: " .. message)
        if bIsValid then
            -- Remove cards and increment score
            GameController.removeValidSet(selectedCards)
            GameModel.incrementScore()
            GameController.isRoundComplete()
            Logger.error("You've hit a dead end, Calvin")
        else
            -- Animate flash red and decrement score
            -- @TODO GameController.animateInvalidSet(selectedCards)
            GameModel.decrementScore()
        end
    end
end

function GameController.processNoSelectedCards()
    GameController.isRoundComplete()
    local selectedCards = GameModel.getSelectedCards()
    local board = GameModel.getBoard()
    local currentSetSize = GameModel.getCurrentSetSize()
    if #selectedCards ~= 0 then
        Logger.error("GameController", "Why are you calling processNoSelectedCards when there are cards selected?")
        error("Why are you calling processNoSelectedCards when there are cards selected?")
    end
    Logger.trace("GameController", "No selected cards")
    local emptySlot = GameModel.findEmptyPosition()
    if emptySlot ~= nil then
        Logger.info("GameController", "The board is not full.  Deal a new card instead.")
        GameController.dealFullBoard()
        return
    end
    -- Player calls 'No Set'
    -- Check if there are any valid sets remaining on the board
    local validSetIndices = RulesService.findValidSetOfSize(board, currentSetSize)
    if validSetIndices then
        Logger.info("GameController", "Player loss - found valid set on board")
        -- Remove the valid set and decrement score
        GameController.removeValidSet(validSetIndices)
        GameModel.decrementScore()
    else
        Logger.info("GameController", "Player win - no valid sets on board")
        GameModel.incrementScore()
        -- do some kinda shuffling
        GameController.reDealBoard()
    end
end

function GameController.reDealBoard()
    Logger.trace("GameController", "Re-dealing board")
    local board = GameModel.getBoard()
    local boardSize = GameModel.getBoardSize()
    -- Remove all cards from board and return them to deck
    for i = 1, boardSize do
        local cardRef = board[i]
        if cardRef then
            -- Clear selection state before returning to deck
            CardModel.setSelected(cardRef, false)
            -- Remove from board and return to deck
            GameModel.removeCardAtPosition(i)
            DeckModel.returnCard(cardRef)
        end
    end
    -- Shuffle the deck to randomize card order
    DeckModel.shuffle()
    GameController.dealFullBoard()
    -- Clear any active hints since the board has changed
    GameModel.clearHint()
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

-- Remove a valid set of cards
function GameController.removeValidSet(selectedIndices)
    Logger.trace("GameController", "Removing valid set")
    local board = GameModel.getBoard()
    -- Sort in reverse order so indices remain valid during removal
    table.sort(selectedIndices, function(a, b)
        return a > b
    end)
    -- Remove the cards from board and add to discard pile
    for _, idx in ipairs(selectedIndices) do
        local cardRef = GameModel.removeCardAtPosition(idx)
        if cardRef then
            GameModel.addToDiscardPile(cardRef)
        end
    end
end

-- Toggle hint mode
function GameController.toggleHint()
    if GameModel.isHintActive() then
        GameModel.clearHint()
        return
    end
    local board = GameModel.getBoard()
    local currentSetSize = GameModel.getCurrentSetSize()
    local validSet = RulesService.findValidSetOfSize(board, currentSetSize)
    if validSet then
        GameModel.setHint(validSet)
    end
end

-- Check if the current round is complete
function GameController.isRoundComplete()
    local board = GameModel.getBoard()
    local currentSetSize = GameModel.getCurrentSetSize()

    -- Check if there are any valid sets remaining on the board
    local bValidSetOnBoard = RulesService.findValidSetOfSize(board, currentSetSize)
    if bValidSetOnBoard then
        Logger.info("GameController", "Valid sets possible with remaining board cards")
        return false
    end

    local allAvailableCards = {}
    -- Add board cards to available cards
    for i = 1, #board do
        if board[i] then
            table.insert(allAvailableCards, board[i])
        end
    end
    if not DeckModel.isEmpty() then
        -- There are cards in deck, combine with board to check for possible sets
        local deckCards = DeckModel.getRemainingCards()
        -- Add remaining deck cards to available cards
        for i = 1, #deckCards do
            table.insert(allAvailableCards, deckCards[i])
        end
    end
    -- Check if any valid set exists in the combined pool
    -- @TODO
    Logger.warning("GameController",
        "Confirm: I don't think findValidSetOfSize works with a full deck. Just board.  Cos of indices checking")
    local bCanFormValidSet = RulesService.findValidSetOfSize(allAvailableCards, currentSetSize)

    if bCanFormValidSet then
        Logger.info("GameController", "Valid sets possible with remaining deck cards")
        return false
    else
        Logger.info("GameController", "Round complete - no valid sets possible with remaining cards")
        return true
    end
end

-- module return
return GameController

