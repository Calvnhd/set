-- Game Model - Centralized game state container

local EventManager = require('core.eventManager')

local GameModel = {}

-- Game constants
local BOARD_COLUMNS = 4
local BOARD_ROWS = 3
local BOARD_SIZE = BOARD_COLUMNS * BOARD_ROWS

-- Game state
local gameState = {
    board = {},  -- Cards on the board
    discardedCards = {},  -- Cards that have been discarded
    hintCards = {},  -- Indices of cards in a valid set for hint
    score = 0,
    bHintIsActive = false,
    bGameEnded = false
}

-- Initialize/reset game state
function GameModel.reset()
    -- Initialize board with all nil values
    gameState.board = {}
    for i = 1, BOARD_SIZE do
        gameState.board[i] = nil
    end
    
    gameState.discardedCards = {}
    gameState.hintCards = {}
    gameState.score = 0
    gameState.bHintIsActive = false
    gameState.bGameEnded = false
    
    EventManager.emit('game:reset')
end

-- Board management
function GameModel.setCardAtPosition(index, cardRef)
    if index >= 1 and index <= BOARD_SIZE then
        gameState.board[index] = cardRef
        EventManager.emit('board:cardPlaced', index, cardRef)
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
        EventManager.emit('board:cardRemoved', index, cardRef)
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
    EventManager.emit('game:cardDiscarded', cardRef)
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
    gameState.score = math.max(0, newScore)  -- Ensure score doesn't go below 0
    EventManager.emit('score:changed', gameState.score, oldScore)
end

function GameModel.incrementScore()
    GameModel.setScore(gameState.score + 1)
end

function GameModel.decrementScore()
    GameModel.setScore(gameState.score - 1)
end

-- Hint management
function GameModel.setHint(cardIndices)
    gameState.hintCards = cardIndices or {}
    gameState.bHintIsActive = #gameState.hintCards > 0
    EventManager.emit('hint:changed', gameState.hintCards, gameState.bHintIsActive)
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
        EventManager.emit('game:ended', gameState.score)
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
