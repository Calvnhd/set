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
    Logger.trace("RulesService", "Checking for valid attributes...")
    local bColorValid = checkAttributeArray(colors)
    local bShapeValid = checkAttributeArray(shapes)
    local bNumberValid = checkAttributeArray(numbers)
    local bFillValid = checkAttributeArray(fills)
    Logger.trace("RulesService", "Color: ".. tostring(bColorValid).." | Shape: "..tostring(bShapeValid).." | Number: "..tostring(bNumberValid).." | Fill: "..tostring(bFillValid))
    -- It's a valid set only if ALL attributes pass the check
    return colorValid and shapeValid and numberValid and fillValid
end

-- Module return
return RulesService
