-- Game Mode Model - Track current game mode and configuration
local EventManager = require('core.eventManager')
local Events = require('core.events')

local GameModeModel = {}

-- Game mode constants
local GAME_MODES = {
    CLASSIC = "classic",
    ROGUE = "rogue"
}

-- Current game mode state
local currentMode = GAME_MODES.CLASSIC
local currentConfig = nil
local currentRoundIndex = 1

-- Initialize the game mode model
function GameModeModel.initialize()
    currentMode = GAME_MODES.CLASSIC
    currentConfig = nil
    currentRoundIndex = 1

    EventManager.emit(Events.GAME_MODE.INITIALIZED, currentMode)
end

-- Set the current game mode
function GameModeModel.setMode(mode)
    if mode == GAME_MODES.CLASSIC or mode == GAME_MODES.ROGUE then
        local previousMode = currentMode
        currentMode = mode
        -- Reset configuration when changing modes
        currentConfig = nil
        currentRoundIndex = 1

        EventManager.emit(Events.GAME_MODE.CHANGED, currentMode, previousMode)
    else
        error("Invalid game mode: " .. tostring(mode))
    end
end

-- Get the current game mode
function GameModeModel.getCurrentMode()
    return currentMode
end

-- Check if currently in classic mode
function GameModeModel.bIsClassicMode()
    return currentMode == GAME_MODES.CLASSIC
end

-- Check if currently in rogue mode
function GameModeModel.bIsRogueMode()
    return currentMode == GAME_MODES.ROGUE
end

-- Set the current round configuration (for rogue mode)
function GameModeModel.setCurrentConfig(config)
    currentConfig = config
    EventManager.emit(Events.GAME_MODE.CONFIG_CHANGED, config)
end

-- Get the current round configuration
function GameModeModel.getCurrentConfig()
    return currentConfig
end

-- Set the current round index
function GameModeModel.setCurrentRoundIndex(roundIndex)
    local previousIndex = currentRoundIndex
    currentRoundIndex = roundIndex
    EventManager.emit(Events.GAME_MODE.ROUND_INDEX_CHANGED, currentRoundIndex, previousIndex)
end

-- Get the current round index
function GameModeModel.getCurrentRoundIndex()
    return currentRoundIndex
end

-- Increment the round index
function GameModeModel.incrementRoundIndex()
    GameModeModel.setCurrentRoundIndex(currentRoundIndex + 1)
end

-- Get game mode constants for external use
function GameModeModel.getGameModes()
    return GAME_MODES
end

return GameModeModel
