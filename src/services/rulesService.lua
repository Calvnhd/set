-- Rules Service - Set game rule validation logic extracted from UI
local CardModel = require('models.CardModel')

local RulesService = {}

-- Check if cards form a valid Set (variable size)
function RulesService.isValidSetOfSize(cardRefs, setSize)
    if #cardRefs ~= setSize then
        return false
    end

    if setSize < 3 then
        return false -- Minimum set size is 3 for proper Set rules
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
    local colorValid = checkAttributeArray(colors)
    local shapeValid = checkAttributeArray(shapes)
    local numberValid = checkAttributeArray(numbers)
    local fillValid = checkAttributeArray(fills)

    -- It's a valid set only if ALL attributes pass the check
    return colorValid and shapeValid and numberValid and fillValid
end

-- Check if three cards form a valid Set (backward compatibility)
function RulesService.isValidSet(card1Ref, card2Ref, card3Ref)
    return RulesService.isValidSetOfSize({card1Ref, card2Ref, card3Ref}, 3)
end

-- Find a valid set on the board (variable size)
function RulesService.findValidSetOfSize(board, setSize)
    setSize = setSize or 3 -- Default to 3 for backward compatibility

    -- Count cards on the board
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

    -- Generate all combinations of setSize cards
    local function generateCombinations(arr, k)
        local result = {}

        local function combine(start, current)
            if #current == k then
                local combo = {}
                for i, v in ipairs(current) do
                    combo[i] = v
                end
                table.insert(result, combo)
                return
            end

            for i = start, #arr do
                table.insert(current, arr[i])
                combine(i + 1, current)
                table.remove(current)
            end
        end

        combine(1, {})
        return result
    end

    local combinations = generateCombinations(cardIndices, setSize)

    -- Check each combination
    for _, combo in ipairs(combinations) do
        local cardRefs = {}
        for i, idx in ipairs(combo) do
            cardRefs[i] = board[idx]
        end

        if RulesService.isValidSetOfSize(cardRefs, setSize) then
            return combo
        end
    end

    -- No valid set found
    return nil
end

-- Check if there are any valid sets on the board (variable size)
function RulesService.hasValidSetOfSize(board, setSize)
    return RulesService.findValidSetOfSize(board, setSize) ~= nil
end

-- Check if there are any valid sets on the board (backward compatibility)
function RulesService.hasValidSet(board)
    return RulesService.findValidSet(board) ~= nil
end

-- Validate if cards can form a set (variable size)
function RulesService.validateSelectedCardsOfSize(selectedIndices, board, setSize)
    if #selectedIndices ~= setSize then
        return false, "Must select exactly " .. setSize .. " cards"
    end

    local cardRefs = {}
    for i, idx in ipairs(selectedIndices) do
        local card = board[idx]
        if not card then
            return false, "Invalid card selection"
        end
        cardRefs[i] = card
    end

    local bIsValid = RulesService.isValidSetOfSize(cardRefs, setSize)
    return bIsValid, bIsValid and "Valid set!" or "Not a valid set"
end

-- Validate if cards can form a set (backward compatibility)
function RulesService.validateSelectedCards(selectedIndices, board)
    return RulesService.validateSelectedCardsOfSize(selectedIndices, board, 3)
end

return RulesService
