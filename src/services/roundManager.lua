-- Round Manager Service - Handle round progression and rule management
local EventManager = require('core.eventManager')
local Events = require('core.events')
local GameModeModel = require('models.gameModeModel')
local GameModel = require('models.gameModel')
local DeckModel = require('models.deckModel')
local RulesService = require('services.rulesService')
local ConfigValidator = require('services.configValidator')
local RoundDefinitions = require('config.roundDefinitions')

local RoundManager = {}

-- Round definitions storage




-- Validate the classic configuration
function RoundManager.validateClassicConfig()
    if not RoundDefinitions.classic or #RoundDefinitions.classic == 0 then
        return false, "Classic mode configuration is not defined"
    end

    local config = RoundDefinitions.classic[1]
    local bValid, message = ConfigValidator.validateRoundConfig(config)

    return bValid, message
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

-- Check if the current round is complete
function RoundManager.IsRoundComplete()
    -- Debug: Checking round end condition...
    -- A round is considered complete if:
    -- 1. The deck is empty and there are less than 3 cards on board, or
    -- 2. It is not possible to create a set with the remaining cards

    local board = GameModel.getBoard()
    local boardCards = {}
    local boardCount = 0

    -- Count cards on the board
    for _, cardRef in pairs(board) do
        if cardRef then
            boardCount = boardCount + 1
            table.insert(boardCards, cardRef)
        end
    end -- Condition 1: Deck is empty and less than 3 cards on board
    local bDeckEmpty = DeckModel.isEmpty()
    if bDeckEmpty and boardCount < 3 then
        -- Debug: Round end: less than 3 cards remain
        return true
    end

    -- Condition 2: Check if no valid set is possible with all remaining cards
    local currentSetSize = GameModel.getCurrentSetSize()

    -- First check board cards only
    local bBoardHasSet = RulesService.hasValidSetOfSize(board, currentSetSize)
    if bBoardHasSet then
        -- Board already has a valid set, round is not complete
        return false
    end -- If deck is empty, we've already checked the board
    if bDeckEmpty then
        -- Debug: Round end: Deck is empty and no valid sets remain
        return true
    end

    -- Check if a valid set can be formed with board + deck cards
    local allRemainingCards = {}
    -- Add board cards
    for _, cardRef in pairs(boardCards) do
        table.insert(allRemainingCards, cardRef)
    end
    -- Add deck cards
    local deckCards = DeckModel.getCards()
    for _, cardRef in pairs(deckCards) do
        table.insert(allRemainingCards, cardRef)
    end
    -- Create a virtual board with all remaining cards for checking
    local virtualBoard = {}
    for i, cardRef in ipairs(allRemainingCards) do
        virtualBoard[i] = cardRef
    end
    -- Check if any set is possible with all remaining cards
    local bHasPossibleSet = RulesService.hasValidSetOfSize(virtualBoard, currentSetSize)
    if bHasPossibleSet then
        return false
    else
        -- Debug: Round end: No valid sets remain in combined cards from board and deck
        return true
    end
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
function RoundManager.gameHasMoreRounds()
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

