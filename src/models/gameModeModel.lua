
-- Set the current round configuration (for rogue mode)
function GameModeModel.setCurrentConfig(config)
    currentConfig = config
end

-- Get the current round configuration
function GameModeModel.getCurrentConfig()
    return currentConfig
end

-- Set the current round index
function GameModeModel.setCurrentRoundIndex(roundIndex)
    currentRoundIndex = roundIndex
end

-- Get the current round index
function GameModeModel.getCurrentRoundIndex()
    return currentRoundIndex
end

-- Increment the round index
function GameModeModel.incrementRoundIndex()
    GameModeModel.setCurrentRoundIndex(currentRoundIndex + 1)
end
