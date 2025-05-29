-- Developer Tools - Testing and debugging utilities for rogue mode

local GameModeModel = require('models.gameModeModel')
local RoundManager = require('services.roundManager')
local ProgressManager = require('services.progressManager')
local ConfigValidator = require('services.configValidator')
local GameModel = require('models.gameModel')

local DevTools = {}

-- Enable/disable developer mode
local bDevModeEnabled = false

-- Initialize developer tools
function DevTools.initialize()
    if love.filesystem.getInfo("dev_mode.txt") then
        bDevModeEnabled = true
        print("Developer mode enabled")
        DevTools.registerCommands()
    end
end

-- Register console commands (if available)
function DevTools.registerCommands()
    -- This would integrate with a debug console if available
    print("Developer commands registered:")
    print("  /round <index> - Jump to specific round")
    print("  /score <value> - Set current score")
    print("  /complete - Complete current round")
    print("  /reset - Reset progress")
    print("  /validate - Validate all round configurations")
    print("  /info - Show current game state")
end

-- Jump to specific round
function DevTools.jumpToRound(roundIndex)
    if not bDevModeEnabled then return false end
    
    roundIndex = tonumber(roundIndex)
    if not roundIndex or roundIndex < 1 or roundIndex > RoundManager.getTotalRounds() then
        print("Invalid round index: " .. tostring(roundIndex))
        return false
    end
    
    GameModeModel.setCurrentRoundIndex(roundIndex)
    local config = RoundManager.startRound(roundIndex)
    print("Jumped to round " .. roundIndex .. ": " .. (config and config.name or "Unknown"))
    return true
end

-- Set current score
function DevTools.setScore(score)
    if not bDevModeEnabled then return false end
    
    score = tonumber(score)
    if not score then
        print("Invalid score value")
        return false
    end
    
    GameModel.setScore(score)
    print("Score set to: " .. score)
    return true
end

-- Complete current round instantly
function DevTools.completeCurrentRound()
    if not bDevModeEnabled then return false end
    
    local config = RoundManager.getCurrentRoundConfig()
    if not config then
        print("No active round")
        return false
    end
    
    if config.endCondition.type == "score" then
        GameModel.setScore(config.endCondition.target)
        print("Score set to target: " .. config.endCondition.target)
    elseif config.endCondition.type == "sets" then
        GameModel.setSetsFound(config.endCondition.target)
        print("Sets found set to target: " .. config.endCondition.target)
    end
    
    return true
end

-- Reset all progress
function DevTools.resetProgress()
    if not bDevModeEnabled then return false end
    
    ProgressManager.resetProgress()
    GameModeModel.setCurrentRoundIndex(1)
    GameModel.reset()
    print("Progress reset to beginning")
    return true
end

-- Validate all round configurations
function DevTools.validateAllConfigurations()
    if not bDevModeEnabled then return false end
    
    print("Validating round configurations...")
    
    -- This would need access to the round definitions
    -- For now, we'll just validate the current round manager state
    local totalRounds = RoundManager.getTotalRounds()
    print("Total rounds found: " .. totalRounds)
    
    for i = 1, totalRounds do
        local config = RoundManager.getCurrentRoundConfig()
        if config then
            local bValid, message = ConfigValidator.validateRoundConfig(config)
            if bValid then
                print("  Round " .. i .. " (" .. config.id .. "): VALID")
            else
                print("  Round " .. i .. " (" .. config.id .. "): ERROR - " .. message)
            end
        else
            print("  Round " .. i .. ": No configuration found")
        end
    end
    
    return true
end

-- Show current game state information
function DevTools.showGameInfo()
    if not bDevModeEnabled then return false end
    
    print("\n=== GAME STATE INFO ===")
    print("Mode: " .. GameModeModel.getCurrentMode())
    print("Round: " .. GameModeModel.getCurrentRoundIndex() .. "/" .. RoundManager.getTotalRounds())
    print("Score: " .. GameModel.getScore())
    print("Sets Found: " .. GameModel.getSetsFound())
    print("Current Set Size: " .. GameModel.getCurrentSetSize())
    
    local boardCols, boardRows = GameModel.getBoardDimensions()
    print("Board Size: " .. boardCols .. "x" .. boardRows)
    
    local config = RoundManager.getCurrentRoundConfig()
    if config then
        print("Round Name: " .. config.name)
        print("End Condition: " .. config.endCondition.type .. " = " .. config.endCondition.target)
        
        if RoundManager.isRoundComplete(GameModel.getScore(), GameModel.getSetsFound()) then
            print("Round Status: COMPLETE")
        else
            print("Round Status: IN PROGRESS")
        end
    end
    
    local progress = ProgressManager.getProgressSummary()
    print("Completed Rounds: " .. progress.completedRounds)
    print("Has Saved Progress: " .. (ProgressManager.bHasSavedProgress() and "YES" or "NO"))
    print("========================\n")
    
    return true
end

-- Process developer command
function DevTools.processCommand(commandLine)
    if not bDevModeEnabled then return false end
    
    local parts = {}
    for part in commandLine:gmatch("%S+") do
        table.insert(parts, part)
    end
    
    if #parts == 0 then return false end
    
    local command = parts[1]:lower()
    
    if command == "/round" and parts[2] then
        return DevTools.jumpToRound(parts[2])
    elseif command == "/score" and parts[2] then
        return DevTools.setScore(parts[2])
    elseif command == "/complete" then
        return DevTools.completeCurrentRound()
    elseif command == "/reset" then
        return DevTools.resetProgress()
    elseif command == "/validate" then
        return DevTools.validateAllConfigurations()
    elseif command == "/info" then
        return DevTools.showGameInfo()
    else
        print("Unknown command: " .. command)
        return false
    end
end

-- Create test round configuration
function DevTools.createTestRound(name)
    if not bDevModeEnabled then return nil end
    
    name = name or "Test Round"
    
    local testRound = {
        id = "test_" .. tostring(math.random(1000, 9999)),
        name = name,
        attributes = {
            number = {1, 2},
            color = {"red", "green"},
            shape = {"diamond"},
            fill = {"empty", "solid"}
        },
        setSize = 2,
        boardSize = {columns = 2, rows = 2},
        scoring = {
            validSet = 1,
            invalidSet = -1,
            noSetCorrect = 1,
            noSetIncorrect = -1
        },
        endCondition = {
            type = "score",
            target = 3
        }
    }
    
    local bValid, message = ConfigValidator.validateRoundConfig(testRound)
    if bValid then
        print("Test round created: " .. testRound.id)
        return testRound
    else
        print("Test round validation failed: " .. message)
        return nil
    end
end

-- Benchmark round validation performance
function DevTools.benchmarkValidation()
    if not bDevModeEnabled then return false end
    
    local testRound = DevTools.createTestRound("Benchmark Test")
    if not testRound then return false end
    
    local startTime = love.timer.getTime()
    local iterations = 1000
    
    for i = 1, iterations do
        ConfigValidator.validateRoundConfig(testRound)
    end
    
    local endTime = love.timer.getTime()
    local totalTime = endTime - startTime
    local avgTime = totalTime / iterations
    
    print(string.format("Validation benchmark: %d iterations in %.3fs (%.6fs per validation)",
          iterations, totalTime, avgTime))
    
    return true
end

-- Check if developer mode is enabled
function DevTools.bIsEnabled()
    return bDevModeEnabled
end

-- Enable developer mode programmatically
function DevTools.enable()
    bDevModeEnabled = true
    DevTools.registerCommands()
end

-- Disable developer mode
function DevTools.disable()
    bDevModeEnabled = false
    print("Developer mode disabled")
end

return DevTools
