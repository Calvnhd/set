-- RoundManager
local RoundManager = {}

-- required modules
local Logger = require('core.Logger')
local RoundDefinitions = require('config.RoundDefinitions')
local ConfigValidator = require('services.ConfigValidator')

-- local variables
local currentRoundSequence = {}
local currentRoundIndex = 1

---------------
-- functions --
---------------

function RoundManager.initialize()
end

function RoundManager.reset()
    currentRoundSequence = {}
    currentRoundIndex = 1
end

-- Set round sequence type (tutorial, classic, intermediate, advanced, challenge)
function RoundManager.setRoundSequence(sequenceType)
    RoundManager.reset()
    Logger.error("Setting new round sequence: " .. sequenceType)
    currentRoundSequence = RoundDefinitions.getSequence(sequenceType)
    -- Validate the round sequence
    local bValid, message = ConfigValidator.validateRoundSequence(currentRoundSequence)
    if not bValid then
        Logger.error("Invalid round configuration: " .. message)
        error("Invalid round configuration: " .. message)
    end
    return currentRoundSequence
end

-- Get the current round configuration
-- function RoundManager.getCurrentRoundSequence()
--     if not currentRoundSequence then
--         Logger.error("Attempted to fetch round sequence while sequence is nil")
--         error("Attempted to fetch round sequence while sequence is nil")
--     end
--     return currentRoundSequence
-- end

-- Start a new round with the given index
function RoundManager.startRound(roundIndex)

end

-- Check if the current round is complete
function RoundManager.IsRoundComplete()

end

-- Advance to the next round
function RoundManager.advanceToNextRound()

end

-- Get the total number of rounds
function RoundManager.getTotalRounds()
end

-- Check if there are more rounds available
function RoundManager.gameHasMoreRounds()
end

-- Get round progress information
function RoundManager.getRoundProgress()

end

return RoundManager
