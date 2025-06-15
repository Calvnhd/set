-- Game Scene - Main gameplay scene with full game functionality
local RulesService = {}

-- required modules
local CardModel = require('models.CardModel')
local Logger = require('core.Logger')

---------------
-- functions --
---------------

-- Validate if cards can form a set (variable size)
function RulesService.validateSelectedCardsOfSize(selectedIndices, board, setSize)
    -- is the set size correct?
    if #selectedIndices ~= setSize then
        return false, "Must select exactly " .. setSize .. " cards"
    end
    -- get the selected cards
    local cardRefs = {}
    for i, selectedBoardIndex in ipairs(selectedIndices) do
        local card = board[selectedBoardIndex]
        if not card then
            return false, "Invalid card selection"
        end
        cardRefs[i] = card
    end
    -- check if the selected cards form a valid set
    local bIsValid = RulesService.isValidSetOfSize(cardRefs, setSize)
    return bIsValid, bIsValid and "Valid set!" or "Not a valid set"
end

-- Check if cards form a valid Set (variable size)
function RulesService.isValidSetOfSize(cardRefs, setSize)
    -- is the set size correct?
    if #cardRefs ~= setSize then
        return false
    end
    -- Get internal card data
    local cards = {}
    for i, cardRef in ipairs(cardRefs) do
        cards[i] = CardModel._getInternalData(cardRef)
    end
    -- Helper function to check if all values in an array are the same or all different
    local function checkAttributeArray(values)
        local first = values[1]
        local bAllSame = true
        local bAllDifferent = true
        -- Check if all are the same
        for i = 2, #values do
            if values[i] ~= first then
                bAllSame = false
                break
            end
        end
        if bAllSame then
            return true
        end
        -- Check if all are different
        for i = 1, #values - 1 do
            for j = i + 1, #values do
                if values[i] == values[j] then
                    bAllDifferent = false
                    break
                end
            end
            if not bAllDifferent then
                break
            end
        end
        return bAllDifferent
    end
    -- Extract attribute arrays
    local colors = {}
    local shapes = {}
    local numbers = {}
    local fills = {}
    for i, card in ipairs(cards) do
        colors[i] = card.color
        shapes[i] = card.shape
        numbers[i] = card.number
        fills[i] = card.fill
    end
    -- Check each attribute
    local bColorValid = checkAttributeArray(colors)
    local bShapeValid = checkAttributeArray(shapes)
    local bNumberValid = checkAttributeArray(numbers)
    local bFillValid = checkAttributeArray(fills)
    Logger.trace("RulesService", "Valid set attributes? - Color: ".. tostring(bColorValid).." | Shape: "..tostring(bShapeValid).." | Number: "..tostring(bNumberValid).." | Fill: "..tostring(bFillValid))
    -- It's a valid set only if ALL attributes pass the check
    return bColorValid and bShapeValid and bNumberValid and bFillValid
end

-- Find a valid set on the board (variable size)
function RulesService.findValidSetOfSize(board, setSize)
    -- Count cards on the board
    -- Tracking the card indices enables recognition of empty slots
    local cardCount = 0
    local cardIndices = {}
    for i = 1, #board do
        if board[i] then
            cardCount = cardCount + 1
            table.insert(cardIndices, i)
        end
    end
    -- Need at least setSize cards to form a set
    if cardCount < setSize then
        return nil
    end    
    -- Find first valid combination using backtracking with early termination
    local function findFirstValidCombination(arr, k)
        local current = {}
        local function backtrack(start)
            if #current == k then
                -- Test this combination immediately
                local cardRefs = {}
                for i, idx in ipairs(current) do
                    cardRefs[i] = board[idx]
                end
                if RulesService.isValidSetOfSize(cardRefs, k) then
                    -- Found a valid set! Return a copy of current indices
                    local result = {}
                    for i, v in ipairs(current) do
                        result[i] = v
                    end
                    return result
                end
                return nil -- This combination didn't work, continue searching
            end
            for i = start, #arr do
                table.insert(current, arr[i])
                local result = backtrack(i + 1)
                if result then
                    return result -- Propagate the found result up
                end
                table.remove(current)
            end
            return nil
        end
        return backtrack(1)
    end
    
    return findFirstValidCombination(cardIndices, setSize)
end

-- Module return
return RulesService
