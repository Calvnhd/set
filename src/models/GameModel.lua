-- Game Model - Centralized game state container
local GameModel = {}

-- required modules

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
    local boardSize = config.boardSize.columns * config.boardSize.rows
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

return GameModel
