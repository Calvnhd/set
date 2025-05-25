-- Rules Service - Set game rule validation logic extracted from UI

local CardModel = require('models.cardModel')

local RulesService = {}

-- Check if three cards form a valid Set
function RulesService.isValidSet(card1Ref, card2Ref, card3Ref)
    local card1 = CardModel._getInternalData(card1Ref)
    local card2 = CardModel._getInternalData(card2Ref)
    local card3 = CardModel._getInternalData(card3Ref)

    -- Helper function to check if all values are the same or all different
    local function checkAttribute(attr1, attr2, attr3)
        if attr1 == attr2 and attr2 == attr3 then
            -- All three are the same
            return true
        elseif attr1 ~= attr2 and attr2 ~= attr3 and attr1 ~= attr3 then
            -- All three are different
            return true
        else
            -- Some are the same, some are different
            return false
        end
    end
    
    -- Check each attribute (color, shape, number, fill)
    local colorValid = checkAttribute(card1.color, card2.color, card3.color)
    local shapeValid = checkAttribute(card1.shape, card2.shape, card3.shape)
    local numberValid = checkAttribute(card1.number, card2.number, card3.number)
    local fillValid = checkAttribute(card1.fill, card2.fill, card3.fill)
    
    -- It's a valid set only if ALL attributes pass the check
    return colorValid and shapeValid and numberValid and fillValid
end

-- Find a valid set on the board (returns indices of 3 cards or nil if none found)
function RulesService.findValidSet(board)
    -- Count cards on the board to check if we have at least 3
    local cardCount = 0
    local cardIndices = {}
    
    for i = 1, #board do
        if board[i] then
            cardCount = cardCount + 1
            table.insert(cardIndices, i)
        end
    end

    -- Need at least 3 cards to form a set
    if cardCount < 3 then
        return nil
    end

    -- Try all possible combinations of 3 cards
    for i = 1, #cardIndices - 2 do
        for j = i + 1, #cardIndices - 1 do
            for k = j + 1, #cardIndices do
                local idx1, idx2, idx3 = cardIndices[i], cardIndices[j], cardIndices[k]
                if RulesService.isValidSet(board[idx1], board[idx2], board[idx3]) then
                    return {idx1, idx2, idx3}
                end
            end
        end
    end
    
    -- No valid set found
    return nil
end

-- Check if there are any valid sets on the board
function RulesService.hasValidSet(board)
    return RulesService.findValidSet(board) ~= nil
end

-- Validate if cards can form a set (used for selected cards validation)
function RulesService.validateSelectedCards(selectedIndices, board)
    if #selectedIndices ~= 3 then
        return false, "Must select exactly 3 cards"
    end
    
    local card1 = board[selectedIndices[1]]
    local card2 = board[selectedIndices[2]]
    local card3 = board[selectedIndices[3]]
    
    if not card1 or not card2 or not card3 then
        return false, "Invalid card selection"
    end
    
    local bIsValid = RulesService.isValidSet(card1, card2, card3)
    return bIsValid, bIsValid and "Valid set!" or "Not a valid set"
end

return RulesService
