-- Progress Manager Service - Handle saving and loading game progress

local EventManager = require('core.eventManager')
local GameModeModel = require('models.gameModeModel')
local GameModel = require('models.gameModel')

local ProgressManager = {}

-- File path for saving progress
local SAVE_FILE = "rogue_progress.json"

-- Current progress state
local currentProgress = {
    currentRound = 1,
    score = 0,
    setsFound = 0,
    completedRounds = {},
    unlocked = true
}

-- Initialize the progress manager
function ProgressManager.initialize()
    ProgressManager.loadProgress()
    EventManager.emit('progressManager:initialized')
end

-- Save current game progress
function ProgressManager.saveProgress()
    if not GameModeModel.bIsRogueMode() then
        return -- Only save progress in rogue mode
    end
    
    currentProgress = {
        currentRound = GameModeModel.getCurrentRoundIndex(),
        score = GameModel.getScore(),
        setsFound = GameModel.getSetsFound(),
        completedRounds = ProgressManager.getCompletedRounds(),
        unlocked = true,
        lastSaved = os.time()
    }
    
    local success = ProgressManager.writeProgressToFile(currentProgress)
    if success then
        EventManager.emit('progressManager:progressSaved', currentProgress)
    else
        EventManager.emit('progressManager:saveFailed')
    end
    
    return success
end

-- Load saved game progress
function ProgressManager.loadProgress()
    local success, progress = ProgressManager.readProgressFromFile()
    if success and progress then
        currentProgress = progress
        EventManager.emit('progressManager:progressLoaded', currentProgress)
        return true
    else
        -- Initialize default progress
        currentProgress = {
            currentRound = 1,
            score = 0,
            setsFound = 0,
            completedRounds = {},
            unlocked = true
        }
        return false
    end
end

-- Apply loaded progress to game state
function ProgressManager.applyProgressToGame()
    if not GameModeModel.bIsRogueMode() then
        return false
    end
    
    GameModeModel.setCurrentRoundIndex(currentProgress.currentRound)
    GameModel.setScore(currentProgress.score or 0)
    GameModel.setSetsFound(currentProgress.setsFound or 0)
    
    EventManager.emit('progressManager:progressApplied', currentProgress)
    return true
end

-- Get completed rounds list
function ProgressManager.getCompletedRounds()
    return currentProgress.completedRounds or {}
end

-- Mark a round as completed
function ProgressManager.markRoundCompleted(roundIndex)
    if not currentProgress.completedRounds then
        currentProgress.completedRounds = {}
    end
    
    -- Add to completed rounds if not already there
    local bAlreadyCompleted = false
    for _, completedRound in ipairs(currentProgress.completedRounds) do
        if completedRound == roundIndex then
            bAlreadyCompleted = true
            break
        end
    end
    
    if not bAlreadyCompleted then
        table.insert(currentProgress.completedRounds, roundIndex)
    end
    
    EventManager.emit('progressManager:roundCompleted', roundIndex)
end

-- Check if a round is completed
function ProgressManager.bIsRoundCompleted(roundIndex)
    if not currentProgress.completedRounds then
        return false
    end
    
    for _, completedRound in ipairs(currentProgress.completedRounds) do
        if completedRound == roundIndex then
            return true
        end
    end
    return false
end

-- Reset progress (for new game)
function ProgressManager.resetProgress()
    currentProgress = {
        currentRound = 1,
        score = 0,
        setsFound = 0,
        completedRounds = {},
        unlocked = true
    }
    
    ProgressManager.deleteProgressFile()
    EventManager.emit('progressManager:progressReset')
end

-- Get current progress summary
function ProgressManager.getProgressSummary()
    return {
        currentRound = currentProgress.currentRound,
        score = currentProgress.score,
        setsFound = currentProgress.setsFound,
        completedRounds = #(currentProgress.completedRounds or {}),
        lastSaved = currentProgress.lastSaved
    }
end

-- Write progress to file (simple format)
function ProgressManager.writeProgressToFile(progress)
    local content = string.format(
        "currentRound=%d\nscore=%d\nsetsFound=%d\nlastSaved=%d\ncompletedRounds=%s",
        progress.currentRound,
        progress.score,
        progress.setsFound,
        progress.lastSaved or os.time(),
        table.concat(progress.completedRounds or {}, ",")
    )
    
    local success, err = pcall(function()
        love.filesystem.write(SAVE_FILE, content)
    end)
    
    if not success then
        print("Failed to write progress file: " .. tostring(err))
        return false
    end
    
    return true
end

-- Read progress from file (simple format)
function ProgressManager.readProgressFromFile()
    if not love.filesystem.getInfo(SAVE_FILE) then
        return false, nil -- File doesn't exist
    end
    
    local success, content = pcall(love.filesystem.read, SAVE_FILE)
    if not success then
        print("Failed to read progress file")
        return false, nil
    end
    
    local progress = {}
    
    -- Parse simple key=value format
    for line in content:gmatch("[^\r\n]+") do
        local key, value = line:match("([^=]+)=(.+)")
        if key and value then
            if key == "currentRound" or key == "score" or key == "setsFound" or key == "lastSaved" then
                progress[key] = tonumber(value) or 0
            elseif key == "completedRounds" then
                progress[key] = {}
                if value ~= "" then
                    for roundStr in value:gmatch("[^,]+") do
                        local roundNum = tonumber(roundStr)
                        if roundNum then
                            table.insert(progress[key], roundNum)
                        end
                    end
                end
            end
        end
    end
    
    return true, progress
end

-- Delete progress file
function ProgressManager.deleteProgressFile()
    if love.filesystem.getInfo(SAVE_FILE) then
        local success = pcall(love.filesystem.remove, SAVE_FILE)
        if success then
            EventManager.emit('progressManager:progressDeleted')
        end
        return success
    end
    return true
end

-- Check if save file exists
function ProgressManager.bHasSavedProgress()
    return love.filesystem.getInfo(SAVE_FILE) ~= nil
end

return ProgressManager
