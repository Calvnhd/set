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
    -- Deal initial cards to the board
    game.dealInitialCards()
    -- Other one-off initializations
    love.graphics.setBackgroundColor(0.2, 0.3, 0.4) -- Dark blue
end

-- Deal the initial cards to the board
function game.dealInitialCards()
    -- Clear the board first
    board = {}
    -- Draw 12 cards for the initial board
    for i = 1, 12 do
        local card = deck.takeCard()
        if card then
            table.insert(board, card)
        end
    end
end

-- Update function called from love.update
function game.update(dt)
end

-- Draw function called from love.draw
function game.draw()
    -- Draw the board of cards
    game.drawBoard()
    -- Display deck information
    game.drawDeckInfo()
end

-- Draw deck information
function game.drawDeckInfo() 
    -- Set text color to white
    love.graphics.setColor(1, 1, 1)
    -- Set font
    love.graphics.setFont(love.graphics.newFont(16))
    -- Get window dimensions
    local windowWidth = love.graphics.getWidth()
    -- Display cards remaining
    local cardsRemaining = deck.getCount()
    local infoText = "Cards remaining in deck: " .. cardsRemaining
    love.graphics.print(infoText, windowWidth - 250, 20)
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
    if card.selected then
        love.graphics.setColor(0.9, 0.9, 0.7) -- Slight yellow tint for selected cards
    else
        love.graphics.setColor(1, 1, 1) -- White background for normal cards
    end
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

-- Clear a random number of cards from the board
function game.clearRandomCards(numCards)
    -- Make sure we don't try to remove more cards than we have
    numCards = math.min(numCards, #board)
    if numCards <= 0 then
        print("No cards to clear")
        return
    end
    print("Clearing " .. numCards .. " random cards from the board")
    -- Remove the specified number of random cards
    for i = 1, numCards do
        if #board > 0 then
            -- Select a random card to remove
            local randomIndex = math.random(#board)
            table.remove(board, randomIndex)
        end
    end
    print("Board now has " .. #board .. " cards")
end

-- Handle keyboard input
function game.keypressed(key)
    -- Clear a random number of cards from the board
    if key == "c" then
        local numToClear = math.random(1, #board)
        game.clearRandomCards(numToClear)
    -- Draw a card from the deck if there's space on the board
    elseif key == "d" then
        if #board < 12 then
            local card = deck.takeCard()
            if card then
                table.insert(board, card)
                print("Added new card to board, now have " .. #board .. " cards")
            else
                print("No more cards in the deck")
            end
        else
            print("Board is full (12 cards)")
        end
    end
end

-- Handle mouse press events
function game.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        -- Check if any card was clicked
        local clickedCardIndex = game.getCardAtPosition(x, y)
        if clickedCardIndex then
            -- Toggle the card's selection state
            board[clickedCardIndex].selected = not board[clickedCardIndex].selected
            -- Check if we have 3 selected cards, and remove them if so
            local selectedCards = game.getSelectedCards()
            if #selectedCards == 3 then
                game.removeSelectedCards()
            end
        end
    end
end

-- Get the card at a given position (returns the index or nil)
function game.getCardAtPosition(x, y)
    -- Get window dimensions to calculate proportions
    local windowWidth, windowHeight = love.graphics.getDimensions()
    -- Calculate card dimensions based on screen size
    local cardWidth = windowWidth * 0.18
    local cardHeight = windowHeight * 0.22
    -- Calculate margins and starting position
    local marginX = windowWidth * 0.02
    local marginY = windowHeight * 0.03
    local startX = windowWidth * 0.05
    local startY = windowHeight * 0.1
    -- Check each card's position
    for i, card in ipairs(board) do
        -- Calculate position in the grid (4 columns, 3 rows)
        local col = (i - 1) % 4  -- 0, 1, 2, 3
        local row = math.floor((i - 1) / 4)  -- 0, 1, 2
        -- Calculate pixel position of this card
        local cardX = startX + col * (cardWidth + marginX)
        local cardY = startY + row * (cardHeight + marginY)
        -- Check if the point (x,y) is within this card's bounds
        if x >= cardX and x <= cardX + cardWidth and
           y >= cardY and y <= cardY + cardHeight then
            return i -- Return the index of the clicked card
        end
    end
    return nil -- No card was clicked
end

-- Get all selected cards
function game.getSelectedCards()
    local selected = {}
    for i, card in ipairs(board) do
        if card.selected then
            table.insert(selected, i)
        end
    end
    return selected
end

-- Remove selected cards from the board
function game.removeSelectedCards()
    local selectedCards = game.getSelectedCards()
    if #selectedCards == 3 then
        print("Removing 3 selected cards")
        -- Sort in reverse order so we can remove from higher indices first
        -- This prevents issues with indices changing as we remove cards
        table.sort(selectedCards, function(a, b) return a > b end)
        -- Remove the cards
        for _, index in ipairs(selectedCards) do
            table.remove(board, index)
        end
        print("Board now has " .. #board .. " cards")
    end
end

-- Export the game module
return game