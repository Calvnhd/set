-- Game logic and state management

local deck = require('deck')
local game = {}

-- Card collections
local board = {} -- Cards currently in play

-- Initialize the game state
function game.initialize()
    -- Create and shuffle a new deck of Set cards
    deck.create()
    deck.shuffle()
    -- Print the entire deck to console for testing
    deck.print()
    -- Deal initial cards to the board
    game.dealInitialCards()
end

-- Deal the initial cards to the board
function game.dealInitialCards()
    -- Clear the board first
    board = {}
    
    -- Draw 12 cards for the initial board
    for i = 1, 12 do
        local card = deck.drawCard()
        if card then
            table.insert(board, card)
        end
    end
    
    print("Dealt " .. #board .. " cards to the board")
end

-- Update function called from love.update
function game.update(dt)
end

-- Draw function called from love.draw
function game.draw()
    -- Set the background color
    love.graphics.setBackgroundColor(0.2, 0.3, 0.4) -- Dark blue background
    
    -- Draw the board of cards in a 4x3 pattern
    game.drawBoard()
end

-- Draw the board of cards in a 4x3 pattern
function game.drawBoard()
    -- Get window dimensions to calculate proportions
    local windowWidth, windowHeight = love.graphics.getDimensions()
    
    -- Calculate card dimensions based on screen size
    local cardWidth = windowWidth * 0.18  -- Approximately 18% of screen width
    local cardHeight = windowHeight * 0.22 -- Approximately 22% of screen height
    
    -- Calculate margins and starting position
    local marginX = windowWidth * 0.02   -- 2% of screen width
    local marginY = windowHeight * 0.03  -- 3% of screen height
    local startX = windowWidth * 0.05    -- 5% from left edge
    local startY = windowHeight * 0.1    -- 10% from top
    
    -- Draw each card on the board
    for i, card in ipairs(board) do
        -- Calculate position in the grid (4 columns, 3 rows)
        local col = (i - 1) % 4  -- 0, 1, 2, 3
        local row = math.floor((i - 1) / 4)  -- 0, 1, 2
        
        -- Calculate pixel position
        local x = startX + col * (cardWidth + marginX)
        local y = startY + row * (cardHeight + marginY)
        
        -- Draw the card
        game.drawCard(card, x, y, cardWidth, cardHeight)
    end
end

-- Draw a single card
function game.drawCard(card, x, y, width, height)
    -- Draw card background
    love.graphics.setColor(1, 1, 1) -- White background
    love.graphics.rectangle("fill", x, y, width, height, 8, 8) -- Rounded corners
    
    -- Draw border
    if card.selected then
        love.graphics.setColor(1, 1, 0) -- Yellow highlight for selected cards
        love.graphics.setLineWidth(4)
    else
        love.graphics.setColor(0, 0, 0) -- Black border for normal cards
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle("line", x, y, width, height, 8, 8)
    
    -- Set text color based on card color
    if card.color == "red" then
        love.graphics.setColor(0.8, 0.2, 0.2)
    elseif card.color == "green" then
        love.graphics.setColor(0.2, 0.8, 0.2)
    elseif card.color == "blue" then
        love.graphics.setColor(0.2, 0.2, 0.8)
    end
    
    -- Draw card attributes as text
    love.graphics.setFont(love.graphics.newFont(14))
    local label = string.format("%s %s\n%d %s", 
        card.color, card.shape, card.number, card.fill)
    love.graphics.printf(label, x + 10, y + height/2 - 30, width - 20, "center")
end

-- Handle keyboard input
function game.keypressed(key)
end

-- Handle mouse press events
function game.mousepressed(x, y, button)
end

-- Handle mouse release events
function game.mousereleased(x, y, button)
end

-- Export the game module
return game