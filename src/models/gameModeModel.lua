-- Game Mode Model - Track current game mode and configuration
local GameModeModel = {}

-- required modules
local EventManager = require('core.EventManager')
local Events = require('config.EventRegistry')
local Constants = require('config.Constants')
local Logger = require('core.Logger')

-- local variables
local state = {
    currentMode = nil,
    currentConfig = nil,
    currentRoundIndex = 1
}

---------------
-- functions --
---------------

function GameModeModel.setMode(newMode)
    GameModeModel.resetState()
    if GameModeModel.checkModeExists(newMode) then
        state.currentMode = newMode
    else
        Logger.error("Error with newMode.  Setting mode to CLASSIC by default.")
        state = Constants.GAME_MODE.CLASSIC
    end
end

function GameModeModel.getMode()
    if state.currentMode then
        return state.currentMode
    else
        Logger.warning("Game mode is currently nil. Returning CLASSIC by default")
        return Constants.GAME_MODE.CLASSIC
    end
end

function GameModeModel.checkModeExists(mode)
    if not mode then
        Logger.error("mode is nil")
        return false
    end
    for _, validMode in pairs(Constants.GAME_MODE) do
        if mode == validMode then
            return true
        end
    end
    Logger.error("mode does not exist")
    return false
end

function GameModeModel.resetState()
    state.currentMode = nil
    state.currentConfig = nil
    state.currentRoundIndex = 1
end

return GameModeModel
