-- Game Model - Centralized game state container
local GameModel = {}

-- required modules
local Logger = require('core.Logger')

-- local variables
local gameState = {
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
function GameModel.initializeGame(config)
    -- Initialize board to the expected size with all nil values
    local firstRound = config[1]
    if config then
        Logger.trace("intializing game: " .. firstRound.name)
    else
        Logger.error("Cannot initialize game without config")
        error("Cannot initialize game without config")
    end
    local boardSize = firstRound.boardSize.columns * firstRound.boardSize.rows
    gameState.board = {}
    for i = 1, boardSize do
        gameState.board[i] = nil
    end
    gameState.discardedCards = {}
    gameState.hintCards = {}
    gameState.score = 0
    gameState.bHintIsActive = false
    gameState.bGameEnded = false
    gameState.setsFound = 0
    gameState.currentSetSize = config.setSize
end

function GameModel.getBoardSize()
    return #gameState.board
end

return GameModel
