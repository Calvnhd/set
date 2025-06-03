-- BoardView
local BoardView = {}

-- required modules
local Logger = require('core.Logger')
local Colors = require('config.ColorRegistry')
local CardView = require('views.CardView')
local GameModel = require('models.GameModel')

---------------
-- functions --
---------------

function BoardView.draw()
    BoardView.drawBackground()
    BoardView.drawCards()
end

function BoardView.drawBackground()
    local layout = BoardView.calculateLayout()
    local boardColumns, boardRows = GameModel.getBoardDimensions()
    love.graphics.setColor(Colors.MAP.BOARD_BACKGROUND)
    local boardPadding = layout.cardWidth * 0.15
    local boardX = layout.startX - boardPadding
    local boardY = layout.startY - boardPadding
    local boardWidth = boardColumns * layout.cardWidth + (boardColumns - 1) * layout.marginX + 2 * boardPadding
    local boardHeight = boardRows * layout.cardHeight + (boardRows - 1) * layout.marginY + 2 * boardPadding
    love.graphics.rectangle("fill", boardX, boardY, boardWidth, boardHeight, 8, 8)
end

function BoardView.drawCards()
    local layout = BoardView.calculateLayout()
    local board = GameModel.getBoard()
    local boardSize = GameModel.getBoardSize()
    local boardColumns, boardRows = GameModel.getBoardDimensions()
    local hintCards = GameModel.getHintCards()
    local bHintIsActive = GameModel.isHintActive()

    -- Helper function to check if a card index is part of the hint
    local function isInHint(index)
        for _, hintIndex in ipairs(hintCards) do
            if hintIndex == index then
                return true
            end
        end
        return false
    end
    -- Draw each card on the board
    for i = 1, boardSize do
        local cardRef = board[i]
        if cardRef then
            local col = (i - 1) % boardColumns
            local row = math.floor((i - 1) / boardColumns)

            local x = layout.startX + col * (layout.cardWidth + layout.marginX)
            local y = layout.startY + row * (layout.cardHeight + layout.marginY)

            local bIsInHint = bHintIsActive and isInHint(i)
            CardView.draw(cardRef, x, y, layout.cardWidth, layout.cardHeight, bIsInHint)
        end
    end
end

-- Calculate card layout dimensions and positions
function BoardView.calculateLayout()
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local cardWidth = windowWidth * 0.2
    local cardHeight = windowHeight * 0.2
    local marginX = cardWidth * 0.1
    local marginY = cardHeight * 0.1
    local startX = windowWidth * 0.05
    local startY = windowHeight * 0.15

    return {
        cardWidth = cardWidth,
        cardHeight = cardHeight,
        marginX = marginX,
        marginY = marginY,
        startX = startX,
        startY = startY,
        windowWidth = windowWidth,
        windowHeight = windowHeight
    }
end

return BoardView
