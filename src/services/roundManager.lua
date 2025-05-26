-- Round Manager Service - Handle round progression and rule management

local EventManager = require('core.eventManager')
local Events = require('core.events')
local GameModeModel = require('models.gameModeModel')
local ConfigValidator = require('services.configValidator')

local RoundManager = {}

-- Round definitions storage
local roundDefinitions = {}
local currentRoundSequence = {}

-- Initialize the round manager
function RoundManager.initialize()
    -- Load round definitions
    RoundManager.loadRoundDefinitions()
    EventManager.emit(Events.ROUND_MANAGER.INITIALIZED)
end

-- Load round definitions from configuration
function RoundManager.loadRoundDefinitions()
    -- For now, we'll use the configuration from the spec
    -- This will be moved to external config files later
    currentRoundSequence = {        {
            id = "tutorial_1",
            name = "Getting Started",
            attributes = {
                number = {1, 2},
                color = {"green", "blue"},
                shape = {"diamond"},
                fill = {"empty", "solid"}
            },
            setSize = 3,
            boardSize = {columns = 3, rows = 3},
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
        },
        {
            id = "tutorial_2",
            name = "Add Red Color",
            attributes = {
                number = {1, 2},
                color = {"green", "blue", "red"},
                shape = {"diamond"},
                fill = {"empty", "solid"}
            },
            setSize = 3,
            boardSize = {columns = 3, rows = 3},
            scoring = {
                validSet = 1,
                invalidSet = -1,
                noSetCorrect = 1,
                noSetIncorrect = -1
            },
            endCondition = {
                type = "score",
                target = 5
            }
        },
        {
            id = "tutorial_3",
            name = "Add Oval Shape",
            attributes = {
                number = {1, 2},
                color = {"green", "blue", "red"},
                shape = {"diamond", "oval"},
                fill = {"empty", "solid"}
            },
            setSize = 3,
            boardSize = {columns = 3, rows = 3},
            scoring = {
                validSet = 1,
                invalidSet = -1,
                noSetCorrect = 1,
                noSetIncorrect = -1
            },
            endCondition = {
                type = "score",
                target = 7
            }
        },        {
            id = "tutorial_4",
            name = "Add Stripes Fill",
            attributes = {
                number = {1, 2},
                color = {"green", "blue", "red"},
                shape = {"diamond", "oval"},
                fill = {"empty", "solid", "stripes"}
            },
            setSize = 3,
            boardSize = {columns = 3, rows = 3},
            scoring = {
                validSet = 1,
                invalidSet = -1,
                noSetCorrect = 1,
                noSetIncorrect = -1
            },
            endCondition = {
                type = "score",
                target = 10
            }
        },        {
            id = "tutorial_5",
            name = "Add Number Three",
            attributes = {
                number = {1, 2, 3},
                color = {"green", "blue", "red"},
                shape = {"diamond", "oval"},
                fill = {"empty", "solid", "stripes"}
            },
            setSize = 3,
            boardSize = {columns = 4, rows = 3},
            scoring = {
                validSet = 2,
                invalidSet = -1,
                noSetCorrect = 1,
                noSetIncorrect = -1
            },
            endCondition = {
                type = "score",
                target = 15
            }
        }
    }
    
    -- Validate the round sequence
    local bValid, message = ConfigValidator.validateRoundSequence(currentRoundSequence)
    if not bValid then
        error("Invalid round configuration: " .. message)
    end
    
    roundDefinitions = currentRoundSequence
    EventManager.emit(Events.ROUND_MANAGER.DEFINITIONS_LOADED, #roundDefinitions)
end

-- Get the current round configuration
function RoundManager.getCurrentRoundConfig()
    local roundIndex = GameModeModel.getCurrentRoundIndex()
    if roundIndex > 0 and roundIndex <= #currentRoundSequence then
        return currentRoundSequence[roundIndex]
    end
    return nil
end

-- Start a new round with the given index
function RoundManager.startRound(roundIndex)
    if roundIndex < 1 or roundIndex > #currentRoundSequence then
        error("Invalid round index: " .. tostring(roundIndex))
    end
    
    local config = currentRoundSequence[roundIndex]
    GameModeModel.setCurrentRoundIndex(roundIndex)
    GameModeModel.setCurrentConfig(config)
    
    EventManager.emit(Events.ROUND_MANAGER.ROUND_STARTED, config, roundIndex)
    return config
end

-- Check if the current round's end condition is met
function RoundManager.bIsRoundComplete(currentScore, setsFound)
    local config = RoundManager.getCurrentRoundConfig()
    if not config or not config.endCondition then
        return false
    end
    
    local endCondition = config.endCondition
    
    if endCondition.type == "score" then
        return currentScore >= endCondition.target
    elseif endCondition.type == "sets" then
        return setsFound >= endCondition.target
    end
    
    return false
end

-- Advance to the next round
function RoundManager.advanceToNextRound()
    local currentIndex = GameModeModel.getCurrentRoundIndex()
    local nextIndex = currentIndex + 1
    
    if nextIndex <= #currentRoundSequence then
        return RoundManager.startRound(nextIndex)
    else
        -- All rounds completed
        EventManager.emit(Events.ROUND_MANAGER.ALL_ROUNDS_COMPLETE)
        return nil
    end
end

-- Get the total number of rounds
function RoundManager.getTotalRounds()
    return #currentRoundSequence
end

-- Check if there are more rounds available
function RoundManager.bHasMoreRounds()
    local currentIndex = GameModeModel.getCurrentRoundIndex()
    return currentIndex < #currentRoundSequence
end

-- Get round progress information
function RoundManager.getRoundProgress()
    local currentIndex = GameModeModel.getCurrentRoundIndex()
    local totalRounds = #currentRoundSequence
    local config = RoundManager.getCurrentRoundConfig()
    
    return {
        currentRound = currentIndex,
        totalRounds = totalRounds,
        roundName = config and config.name or "Unknown",
        progress = currentIndex / totalRounds
    }
end

-- Reset to the first round
function RoundManager.reset()
    GameModeModel.setCurrentRoundIndex(1)
    GameModeModel.setCurrentConfig(nil)
    EventManager.emit(Events.ROUND_MANAGER.RESET)
end

return RoundManager
