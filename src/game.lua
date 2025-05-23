-- Game logic and state management

local deck = require('deck')
local game = {}

-- Card collections
local board = {} -- Cards currently in play

-- Game state
local hintActive = false -- Track if hint mode is active
local hintCards = {} -- Indices of cards in a valid set for hint
local score = 0 -- Track player's score

-- Card images
local cardImages = {}

-- Initialize the game state
function game.initialize()
    -- Load card images
    loadCardImages()
    
    -- Create and shuffle a new deck of Set cards
    deck.create()
    deck.shuffle()
    -- Deal initial cards to the board
    game.dealInitialCards()    -- Other one-off initializations
    love.graphics.setBackgroundColor(0.2, 0.3, 0.4) -- Dark blue
    
    -- Reset hint state
    hintActive = false
    hintCards = {}
    
    -- Reset score
    score = 0
end

-- Load all card images
function loadCardImages()
    cardImages = {
        oval = {
            solid = love.graphics.newImage("images/oval-fill-54x96.png"),
            stripes = love.graphics.newImage("images/oval-stripes-54x96.png"),
            empty = love.graphics.newImage("images/oval-empty-54x96.png")
        },
        diamond = {
            solid = love.graphics.newImage("images/diamond-fill-54x96.png"),
            stripes = love.graphics.newImage("images/diamond-stripes-54x96.png"),
            empty = love.graphics.newImage("images/diamond-empty-54x96.png")
        },
        squiggle = {
            solid = love.graphics.newImage("images/squiggle-fill-54x96.png"),
            stripes = love.graphics.newImage("images/squiggle-stripe-54x96.png"),
            empty = love.graphics.newImage("images/squiggle-empty-54x96.png")
        }
    }
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
    
    -- Reset hint state
    hintActive = false
    hintCards = {}
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
    love.graphics.setFont(love.graphics.newFont(16))    -- Get window dimensions
    local windowWidth = love.graphics.getWidth()
      -- Display score
    local scoreText = "Score: " .. score
    love.graphics.print(scoreText, windowWidth - 150, 20)
    
    -- Display cards remaining
    local cardsRemaining = deck.getCount()
    local infoText = "Cards remaining in deck: " .. cardsRemaining
    love.graphics.print(infoText, windowWidth - 350, 45)
    
    -- Display hint instructions
    love.graphics.print("Press 'h' for a hint", 20, 20)
end

-- Draw the board of cards in a 4x3 pattern
function game.drawBoard()
    -- Get window dimensions to calculate proportions
    local windowWidth, windowHeight = love.graphics.getDimensions()
    -- Calculate card dimensions based on screen size
    local cardWidth = windowWidth * 0.2 
    local cardHeight = windowHeight * 0.2
    -- Calculate margins and starting position
    local marginX = cardWidth * 0.1
    local marginY = cardHeight * 0.1
    local startX = windowWidth * 0.05    -- Adjusted starting position
    local startY = windowHeight * 0.15   -- Adjusted starting position
    -- Draw each card on the board
    for i, card in ipairs(board) do
        -- Calculate position in the grid (4 columns, 3 rows)
        local col = (i - 1) % 4  -- 0, 1, 2, 3
        local row = math.floor((i - 1) / 4)  -- 0, 1, 2
        -- Calculate pixel position
        local x = startX + col * (cardWidth + marginX)
        local y = startY + row * (cardHeight + marginY)
        -- Draw the card
        game.drawCard(card, x, y, cardWidth, cardHeight, i)
    end
end

-- Draw a single card
function game.drawCard(card, x, y, width, height, index)
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
    elseif hintActive and isInHint(index) then
        love.graphics.setColor(0, 0.8, 0.8) -- Cyan highlight for hint cards
        love.graphics.setLineWidth(4)
    else
        love.graphics.setColor(0, 0, 0) -- Black border for normal cards
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle("line", x, y, width, height, 8, 8)
      -- Set color based on card color for tinting the white images
    if card.color == "red" then
        love.graphics.setColor(0.85, 0.15, 0.15) -- Slightly deeper red
    elseif card.color == "green" then
        love.graphics.setColor(0.15, 0.65, 0.25) -- Softer, more natural green
    elseif card.color == "blue" then
        love.graphics.setColor(0.15, 0.35, 0.75) -- Brighter, royal blue
    end
    
    -- Get the image for this shape and fill
    local image = cardImages[card.shape][card.fill]
    if not image then
        print("Warning: Missing image for " .. card.shape .. "-" .. card.fill)
        return
    end
      -- Calculate image dimensions
    local imgWidth = image:getWidth()
    local imgHeight = image:getHeight()
    
    -- Calculate a consistent scale for all shapes regardless of card number
    -- First, determine the worst-case scenario (3 shapes on a card)
    local baseScale = 0.8  -- Default scale factor
    
    -- Calculate the maximum width needed for 3 shapes plus spacing
    local maxShapesWidth = imgWidth * 3  -- Width of three shapes
    local spacingWidth = imgWidth * 0.6  -- Total spacing between 3 shapes
    local totalWidthNeeded = maxShapesWidth + spacingWidth
    
    -- Calculate the scale that would make 3 shapes fit on any card
    local scaleForWidth = (width * 0.85) / totalWidthNeeded  -- 85% of card width
    
    -- Ensure the height also fits (55% of card height)
    local scaleForHeight = (height * 0.55) / imgHeight
    
    -- Take the smaller scale to ensure both width and height fit
    local scale = math.min(scaleForWidth, scaleForHeight, baseScale)
    
    -- Calculate scaled dimensions
    local scaledWidth = imgWidth * scale
    local scaledHeight = imgHeight * scale
      -- Calculate positions for the symbols based on card.number and scaled size
    local positions = {}
    if card.number == 1 then
        -- Single symbol centered
        positions = {
            {x + width/2, y + height/2}
        }
    elseif card.number == 2 then
        -- Two symbols side by side
        local spacing = scaledWidth * 0.15 -- Spacing between symbols
        positions = {
            {x + width/2 - spacing - scaledWidth/2, y + height/2},
            {x + width/2 + spacing + scaledWidth/2, y + height/2}
        }
    elseif card.number == 3 then
        -- Reduced spacing for three symbols to ensure they fit
        local spacing = scaledWidth * 0.15 -- Reduced spacing between symbols
        positions = {
            {x + width/2 - spacing*2 - scaledWidth, y + height/2},
            {x + width/2, y + height/2},
            {x + width/2 + spacing*2 + scaledWidth, y + height/2}
        }
    end
    
    -- Draw the symbols at each position with the calculated scale
    for _, pos in ipairs(positions) do
        -- Center the image at the position
        love.graphics.draw(
            image, 
            pos[1] - scaledWidth/2,  -- Center horizontally
            pos[2] - scaledHeight/2, -- Center vertically
            0,                       -- Rotation (none)
            scale, scale             -- Apply the calculated scale
        )
    end
end

-- Helper function to check if a card index is part of the hint
function isInHint(index)
    for _, hintIndex in ipairs(hintCards) do
        if hintIndex == index then
            return true
        end
    end
    return false
end

-- Find a valid set on the board (returns indices of 3 cards or nil if none found)
function game.findValidSet()
    -- Need at least 3 cards to form a set
    if #board < 3 then
        return nil
    end
    
    -- Try all possible combinations of 3 cards
    for i = 1, #board - 2 do
        for j = i + 1, #board - 1 do
            for k = j + 1, #board do
                if game.isValidSet(board[i], board[j], board[k]) then
                    return {i, j, k}
                end
            end
        end
    end
    
    -- No valid set found
    return nil
end

-- Toggle hint mode
function game.toggleHint()
    -- If hint is already active, turn it off
    if hintActive then
        hintActive = false
        hintCards = {}
        return
    end
    
    -- Try to find a valid set
    local set = game.findValidSet()
    if set then
        hintActive = true
        hintCards = set
        print("Hint active: showing a valid set")
    else
        print("No valid sets found on the board!")
    end
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
    
    -- Reset hint state when board changes
    hintActive = false
    hintCards = {}
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
        -- Reset hint state when board changes
        hintActive = false
        hintCards = {}
    -- Toggle hint mode
    elseif key == "h" then
        game.toggleHint()
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
            
            -- Disable hint mode when a card is selected
            hintActive = false
            hintCards = {}
        end
    end
end

-- Get the card at a given position (returns the index or nil)
function game.getCardAtPosition(x, y)
    -- Get window dimensions to calculate proportions
    local windowWidth, windowHeight = love.graphics.getDimensions()
    -- Calculate card dimensions based on screen size
    local cardWidth = windowWidth * 0.23  -- Match the card width from drawBoard
    local cardHeight = windowHeight * 0.29 -- Match the card height from drawBoard
    -- Calculate margins and starting position
    local marginX = windowWidth * 0.012  -- Match the margin from drawBoard
    local marginY = windowHeight * 0.015  -- Match the margin from drawBoard
    local startX = windowWidth * 0.03    -- Match the start position from drawBoard
    local startY = windowHeight * 0.06   -- Match the start position from drawBoard
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

-- Check if three cards form a valid Set
function game.isValidSet(card1, card2, card3)
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

-- Remove selected cards from the board
function game.removeSelectedCards()
    local selectedCards = game.getSelectedCards()
    if #selectedCards == 3 then
        -- Get the actual card objects
        local card1 = board[selectedCards[1]]
        local card2 = board[selectedCards[2]]
        local card3 = board[selectedCards[3]]
          -- Check if they form a valid Set
        if game.isValidSet(card1, card2, card3) then
            print("Found a valid Set! Removing cards.")
            -- Sort in reverse order so we can remove from higher indices first
            -- This prevents issues with indices changing as we remove cards
            table.sort(selectedCards, function(a, b) return a > b end)
            -- Remove the cards
            for _, index in ipairs(selectedCards) do
                table.remove(board, index)
            end
            -- Increment score when a valid set is found
            score = score + 1
            print("Board now has " .. #board .. " cards")
            
            -- Reset hint state when board changes
            hintActive = false
            hintCards = {}
        else
            print("Not a valid Set! Deselecting cards.")
            -- Deselect all cards
            for _, index in ipairs(selectedCards) do
                board[index].selected = false
            end
        end
    end
end

-- Export the game module
return game