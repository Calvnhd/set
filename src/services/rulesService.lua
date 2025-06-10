

-- Check if three cards form a valid Set (backward compatibility)
function RulesService.isValidSet(card1Ref, card2Ref, card3Ref)
    return RulesService.isValidSetOfSize({card1Ref, card2Ref, card3Ref}, 3)
end



-- Check if there are any valid sets on the board (variable size)
function RulesService.hasValidSetOfSize(board, setSize)
    return RulesService.findValidSetOfSize(board, setSize) ~= nil
end

-- Check if there are any valid sets on the board (backward compatibility)
function RulesService.hasValidSet(board)
    return RulesService.findValidSet(board) ~= nil
end



-- Validate if cards can form a set (backward compatibility)
function RulesService.validateSelectedCards(selectedIndices, board)
    return RulesService.validateSelectedCardsOfSize(selectedIndices, board, 3)
end

return RulesService
