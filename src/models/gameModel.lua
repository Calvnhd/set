-- Game Model - Centralized game state container
local EventManager = require('core.eventManager')
local Events = require('core.events')

local GameModel = {}

-- Game constants (can be overridden for rogue mode)
local BOARD_COLUMNS = 4
local BOARD_ROWS = 3
local BOARD_SIZE = BOARD_COLUMNS * BOARD_ROWS

-- Game state
local gameState = {
    board = {}, -- Cards on the board
    discardedCards = {}, -- Cards that have been discarded
    hintCards = {}, -- Indices of cards in a valid set for hint
    score = 0,
    bHintIsActive = false,
    bGameEnded = false,
    -- Round-based state
    setsFound = 0, -- Number of valid sets found in current round
    currentSetSize = 3 -- Current required set size
}

-- Initialize/reset game state
function GameModel.reset()
    -- Initialize board with all nil values (size may change in rogue mode)
    gameState.board = {}
    for i = 1, BOARD_SIZE do
        gameState.board[i] = nil
    end

    gameState.discardedCards = {}
    gameState.hintCards = {}
    gameState.score = 0
    gameState.bHintIsActive = false
    gameState.bGameEnded = false
    gameState.setsFound = 0
    gameState.currentSetSize = 3

    EventManager.emit(Events.GAME.RESET)
end

-- Configure board dimensions (for rogue mode)
function GameModel.configureBoardSize(columns, rows)
    BOARD_COLUMNS = columns
    BOARD_ROWS = rows
    BOARD_SIZE = BOARD_COLUMNS * BOARD_ROWS

    -- Resize board array if needed
    local newBoard = {}
    for i = 1, BOARD_SIZE do
        newBoard[i] = gameState.board[i] or nil
    end
    gameState.board = newBoard
    EventManager.emit(Events.BOARD.SIZE_CHANGED, BOARD_COLUMNS, BOARD_ROWS, BOARD_SIZE)
end

-- Set the current required set size
function GameModel.setCurrentSetSize(setSize)
    gameState.currentSetSize = setSize
    EventManager.emit(Events.GAME.SET_SIZE_CHANGED, setSize)
end

-- Get the current required set size
function GameModel.getCurrentSetSize()
    return gameState.currentSetSize
end

-- Board management
function GameModel.setCardAtPosition(index, cardRef)
    if index >= 1 and index <= BOARD_SIZE then
        gameState.board[index] = cardRef
        EventManager.emit(Events.BOARD.CARD_PLACED, index, cardRef)
    end
end

function GameModel.getCardAtPosition(index)
    if index >= 1 and index <= BOARD_SIZE then
        return gameState.board[index]
    end
    return nil
end

function GameModel.removeCardAtPosition(index)
    if index >= 1 and index <= BOARD_SIZE and gameState.board[index] then
        local cardRef = gameState.board[index]
        gameState.board[index] = nil
        EventManager.emit(Events.BOARD.CARD_REMOVED, index, cardRef)
        return cardRef
    end
    return nil
end

function GameModel.getBoard()
    return gameState.board
end

function GameModel.getBoardSize()
    return BOARD_SIZE
end

function GameModel.getBoardDimensions()
    return BOARD_COLUMNS, BOARD_ROWS
end

-- Discard pile management
function GameModel.addToDiscardPile(cardRef)
    table.insert(gameState.discardedCards, cardRef)
    EventManager.emit(Events.GAME.CARD_DISCARDED, cardRef)
end

function GameModel.getDiscardedCards()
    return gameState.discardedCards
end

-- Score management
function GameModel.getScore()
    return gameState.score
end

function GameModel.setScore(newScore)
    local oldScore = gameState.score
    gameState.score = math.max(0, newScore) -- Ensure score doesn't go below 0
    EventManager.emit(Events.SCORE.CHANGED, gameState.score, oldScore)
end

function GameModel.incrementScore()
    GameModel.setScore(gameState.score + 1)
end

function GameModel.decrementScore()
    GameModel.setScore(gameState.score - 1)
end

-- Sets found management (for round progression)
function GameModel.getSetsFound()
    return gameState.setsFound
end

function GameModel.incrementSetsFound()
    gameState.setsFound = gameState.setsFound + 1
    EventManager.emit(Events.GAME.SETS_FOUND_CHANGED, gameState.setsFound)
end

function GameModel.setSetsFound(count)
    gameState.setsFound = count or 0
    EventManager.emit(Events.GAME.SETS_FOUND_CHANGED, gameState.setsFound)
end

function GameModel.resetSetsFound()
    gameState.setsFound = 0
    EventManager.emit(Events.GAME.SETS_FOUND_RESET)
end

-- Hint management
function GameModel.setHint(cardIndices)
    gameState.hintCards = cardIndices or {}
    gameState.bHintIsActive = #gameState.hintCards > 0
    EventManager.emit(Events.HINT.CHANGED, gameState.hintCards, gameState.bHintIsActive)
end

function GameModel.getHintCards()
    return gameState.hintCards
end

function GameModel.isHintActive()
    return gameState.bHintIsActive
end

function GameModel.clearHint()
    GameModel.setHint({})
end

-- Game end state
function GameModel.setGameEnded(bEnded)
    gameState.bGameEnded = bEnded
    if bEnded then
        EventManager.emit(Events.GAME.ENDED, gameState.score)
    end
end

function GameModel.hasGameEnded()
    return gameState.bGameEnded
end

-- Helper functions for coordinate conversion
function GameModel.indexToGridPos(index)
    local col = (index - 1) % BOARD_COLUMNS
    local row = math.floor((index - 1) / BOARD_COLUMNS)
    return col, row
end

function GameModel.gridPosToIndex(col, row)
    return row * BOARD_COLUMNS + col + 1
end

-- Find first empty position on board
function GameModel.findEmptyPosition()
    for i = 1, BOARD_SIZE do
        if not gameState.board[i] then
            return i
        end
    end
    return nil
end

-- Count non-empty positions
function GameModel.countCardsOnBoard()
    local count = 0
    for i = 1, BOARD_SIZE do
        if gameState.board[i] then
            count = count + 1
        end
    end
    return count
end

-- Get all selected cards on the board
function GameModel.getSelectedCards()
    local selected = {}
    local CardModel = require('models.cardModel')

    for i = 1, BOARD_SIZE do
        local cardRef = gameState.board[i]
        if cardRef and CardModel.isSelected(cardRef) then
            table.insert(selected, i)
        end
    end
    return selected
end

return GameModel
