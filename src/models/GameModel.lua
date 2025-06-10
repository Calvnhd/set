-- Game Model - Centralized game state container
local GameModel = {}

-- required modules
local Logger = require('core.Logger')
local CardModel = require('models.CardModel')

-- local variables
local gameState = {
    boardColumns = 0,
    boardRows = 0,
    boardSize = 0,
    board = {}, -- Cards on the board
    discardedCards = {}, -- Cards that have been discarded
    hintCards = {}, -- Indices of cards in a valid set for hint
    score = 0,
    bHintIsActive = false,
    bGameEnded = false,
    setsFound = 0, -- Number of valid sets found in current round
    currentSetSize = 3
}

---------------
-- functions --
---------------

-- Initialize/reset game state
function GameModel.initializeRound(roundConfig)
    -- Initialize board to the expected size with all nil values
    gameState.boardColumns = roundConfig.boardSize.columns
    gameState.boardRows = roundConfig.boardSize.rows
    gameState.boardSize = gameState.boardColumns * gameState.boardRows
    gameState.board = {}
    for i = 1, gameState.boardSize do
        gameState.board[i] = nil
    end
    gameState.discardedCards = {}
    gameState.hintCards = {}
    gameState.score = 0
    gameState.bHintIsActive = false
    gameState.bGameEnded = false
    gameState.setsFound = 0
    gameState.currentSetSize = roundConfig.setSize
end

-- State Getters
function GameModel.getBoardSize()
    -- consider using #board if it's guaranteed to be initialized correctly
    return gameState.boardSize
end
function GameModel.getBoardDimensions()
    return gameState.boardColumns, gameState.boardRows
end
function GameModel.getBoard()
    return gameState.board
end
function GameModel.getHintCards()
    return gameState.hintCards
end
function GameModel.isHintActive()
    return gameState.bHintIsActive
end
function GameModel.hasGameEnded()
    return gameState.bGameEnded
end
function GameModel.getCurrentSetSize()
    return gameState.currentSetSize
end
function GameModel.clearHint()
    GameModel.setHint({})
end

-- Board management
function GameModel.setCardAtPosition(index, cardRef)
    if index >= 1 and index <= gameState.boardSize then
        gameState.board[index] = cardRef
    end
end

function GameModel.removeCardAtPosition(index)
    if index >= 1 and index <= gameState.boardSize and gameState.board[index] then
        local cardRef = gameState.board[index]
        gameState.board[index] = nil
        return cardRef
    end
    return nil
end

-- Get all selected cards on the board
function GameModel.getSelectedCards()
    local selected = {}
    local CardModel = require('models.CardModel')
    for i = 1, gameState.boardSize do
        local cardRef = gameState.board[i]
        if cardRef and CardModel.isSelected(cardRef) then
            table.insert(selected, i)
        end
    end
    return selected
end

-- Hint management
function GameModel.setHint(cardIndices)
    gameState.hintCards = cardIndices or {}
    gameState.bHintIsActive = #gameState.hintCards > 0
end

-- Discard pile management
function GameModel.addToDiscardPile(cardRef)
    local cardStr = CardModel.cardAttributesToString(cardRef)
    Logger.trace("GameModel", "Adding card to discard pile:\t" .. cardStr)
    table.insert(gameState.discardedCards, cardRef)
end

return GameModel
