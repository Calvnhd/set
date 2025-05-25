-- Board View - Board layout and card positioning

local CardView = require('views.cardView')
local GameModel = require('models.gameModel')

local BoardView = {}

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

-- Draw the board background
function BoardView.drawBackground()
    local layout = BoardView.calculateLayout()
    local BOARD_COLUMNS, BOARD_ROWS = GameModel.getBoardDimensions()
    
    -- Draw a white rectangle board background
    love.graphics.setColor(1, 1, 1) -- Pure white
    
    local boardPadding = layout.cardWidth * 0.15
    local boardX = layout.startX - boardPadding
    local boardY = layout.startY - boardPadding
    local boardWidth = BOARD_COLUMNS * layout.cardWidth + (BOARD_COLUMNS - 1) * layout.marginX + 2 * boardPadding
    local boardHeight = BOARD_ROWS * layout.cardHeight + (BOARD_ROWS - 1) * layout.marginY + 2 * boardPadding
    
    love.graphics.rectangle("fill", boardX, boardY, boardWidth, boardHeight, 8, 8)
end

-- Draw all cards on the board
function BoardView.drawCards()
    local layout = BoardView.calculateLayout()
    local board = GameModel.getBoard()
    local boardSize = GameModel.getBoardSize()
    local BOARD_COLUMNS, BOARD_ROWS = GameModel.getBoardDimensions()
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
            local col = (i - 1) % BOARD_COLUMNS
            local row = math.floor((i - 1) / BOARD_COLUMNS)
            
            local x = layout.startX + col * (layout.cardWidth + layout.marginX)
            local y = layout.startY + row * (layout.cardHeight + layout.marginY)
            
            local bIsInHint = bHintIsActive and isInHint(i)
            CardView.draw(cardRef, x, y, layout.cardWidth, layout.cardHeight, bIsInHint)
        end
    end
end

-- Draw the complete board (background + cards)
function BoardView.draw()
    BoardView.drawBackground()
    BoardView.drawCards()
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
            
            if x >= cardX and x <= cardX + layout.cardWidth and 
               y >= cardY and y <= cardY + layout.cardHeight then
                return i
            end
        end
    end
    
    return nil
end

return BoardView
