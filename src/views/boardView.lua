-- Board View - Board layout and card positioning



-- Draw all cards on the board
function BoardView.drawCards()

end

-- Get the card position at a given board index
function BoardView.getCardPosition(index)
    local layout = BoardView.calculateLayout()
    local BOARD_COLUMNS, BOARD_ROWS = GameModel.getBoardDimensions()

    local col = (index - 1) % BOARD_COLUMNS
    local row = math.floor((index - 1) / BOARD_COLUMNS)

    local x = layout.startX + col * (layout.cardWidth + layout.marginX)
    local y = layout.startY + row * (layout.cardHeight + layout.marginY)

    return x, y, layout.cardWidth, layout.cardHeight
end

-- Get the card at a given screen position
function BoardView.getCardAtPosition(x, y)
    local layout = BoardView.calculateLayout()
    local boardSize = GameModel.getBoardSize()
    local board = GameModel.getBoard()
    local BOARD_COLUMNS, BOARD_ROWS = GameModel.getBoardDimensions()

    for i = 1, boardSize do
        if board[i] then
            local col = (i - 1) % BOARD_COLUMNS
            local row = math.floor((i - 1) / BOARD_COLUMNS)

            local cardX = layout.startX + col * (layout.cardWidth + layout.marginX)
            local cardY = layout.startY + row * (layout.cardHeight + layout.marginY)

            if x >= cardX and x <= cardX + layout.cardWidth and y >= cardY and y <= cardY + layout.cardHeight then
                return i
            end
        end
    end

    return nil
end
