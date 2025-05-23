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

-- Track the discarded cards (never returned to deck until a new game)
local discardedCards = {}

-- Animation states for cards
local animatingCards = {}

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
    
    -- Reset score (ensure it's never below 0)
    score = math.max(0, score)
    
    -- Reset discarded cards
    discardedCards = {}
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
    -- Update animations
    updateCardAnimations(dt)
end

-- Update card animations
function updateCardAnimations(dt)
    local animationsCompleted = {}
    
    -- Process each animating card
    for i, anim in ipairs(animatingCards) do
        -- Update the animation timer
        anim.timer = anim.timer + dt
        
        -- Calculate progress (0 to 1)
        local progress = math.min(anim.timer / anim.duration, 1)
        
        -- Update the card's animation properties based on progress
        if anim.type == "burn" then
            -- Calculate which phase we're in based on progress
            local phaseLength = 1 / 4 -- Each phase is 1/4 of the total animation
            anim.phase = math.min(4, math.floor(progress / phaseLength) + 1)
            
            -- Calculate progress within the current phase (0 to 1)
            anim.phaseProgress = (progress - (anim.phase - 1) * phaseLength) / phaseLength
            
            -- Phase-specific updates will be handled in the drawing function
        elseif anim.type == "fadeIn" then
            -- Simple fade in - opacity increases with progress
            anim.opacity = progress
        end
        
        -- Check if animation is complete
        if progress >= 1 then
            table.insert(animationsCompleted, i)
            if anim.onComplete then
                anim.onComplete()
            end
        end
    end
    
    -- Remove completed animations in reverse order to avoid index issues
    table.sort(animationsCompleted, function(a, b) return a > b end)
    for _, index in ipairs(animationsCompleted) do
        table.remove(animatingCards, index)
    end
end

-- Function to animate a card burning (should only be used for cards discarded from x key press)
function game.animateCardBurn(card, x, y, width, height, onComplete)
    local anim = {
        card = card,
        x = x,
        y = y,
        width = width,
        height = height,
        type = "burn",
        duration = 2.0,  -- Animation takes 2 seconds
        timer = 0,
        phase = 1,       -- Start with phase 1
        phaseProgress = 0, -- Progress within the current phase
        opacity = 1,     -- Start fully visible
        onComplete = onComplete
    }
    
    table.insert(animatingCards, anim)
    return anim
end

-- Function to animate a card fading in
function game.animateCardFadeIn(card, x, y, width, height, onComplete)
    local anim = {
        card = card,
        x = x,
        y = y,
        width = width,
        height = height,
        type = "fadeIn",
        duration = 1.0,  -- Animation takes 1 second
        timer = 0,
        opacity = 0,     -- Start invisible
        onComplete = onComplete
    }
    
    table.insert(animatingCards, anim)
    return anim
end

-- Draw function called from love.draw
function game.draw()
    -- Draw the board of cards
    game.drawBoard()
    -- Draw animating cards
    game.drawAnimatingCards()
    -- Display deck information
    game.drawDeckInfo()
end

-- Draw animating cards
function game.drawAnimatingCards()
    for _, anim in ipairs(animatingCards) do
        if anim.type == "burn" then
            -- Draw card with burning effect
            game.drawBurningCard(anim)
        elseif anim.type == "fadeIn" then
            -- Draw card with fade-in effect
            game.drawFadingInCard(anim)
        end
    end
end

-- Draw a card with fade-in effect
function game.drawFadingInCard(anim)
    -- Draw card with opacity based on animation progress
    love.graphics.setColor(1, 1, 1, anim.opacity)
    love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)
    
    -- Draw border with opacity
    love.graphics.setColor(0, 0, 0, anim.opacity)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)
    
    -- Set color for the card symbols
    if anim.card.color == "red" then
        love.graphics.setColor(0.85, 0.15, 0.15, anim.opacity) -- Red tint
    elseif anim.card.color == "green" then
        love.graphics.setColor(0.15, 0.65, 0.25, anim.opacity) -- Green tint
    elseif anim.card.color == "blue" then
        love.graphics.setColor(0.15, 0.35, 0.75, anim.opacity) -- Blue tint
    end
    
    -- Get the image for this shape and fill
    local image = cardImages[anim.card.shape][anim.card.fill]
    if not image then
        return
    end
    
    -- Same drawing logic as in drawCard and drawBurningCard for consistency
    local imgWidth = image:getWidth()
    local imgHeight = image:getHeight()
    local baseScale = 0.8
    local maxShapesWidth = imgWidth * 3
    local spacingWidth = imgWidth * 0.6
    local totalWidthNeeded = maxShapesWidth + spacingWidth
    local scaleForWidth = (anim.width * 0.85) / totalWidthNeeded
    local scaleForHeight = (anim.height * 0.55) / imgHeight
    local scale = math.min(scaleForWidth, scaleForHeight, baseScale)
    local scaledWidth = imgWidth * scale
    local scaledHeight = imgHeight * scale
    
    -- Calculate positions for the symbols
    local positions = {}
    if anim.card.number == 1 then
        positions = {
            {anim.x + anim.width/2, anim.y + anim.height/2}
        }
    elseif anim.card.number == 2 then
        local spacing = scaledWidth * 0.15
        positions = {
            {anim.x + anim.width/2 - spacing - scaledWidth/2, anim.y + anim.height/2},
            {anim.x + anim.width/2 + spacing + scaledWidth/2, anim.y + anim.height/2}
        }
    elseif anim.card.number == 3 then
        local spacing = scaledWidth * 0.15
        positions = {
            {anim.x + anim.width/2 - spacing*2 - scaledWidth, anim.y + anim.height/2},
            {anim.x + anim.width/2, anim.y + anim.height/2},
            {anim.x + anim.width/2 + spacing*2 + scaledWidth, anim.y + anim.height/2}
        }
    end
    
    -- Draw the symbols at each position with the calculated scale
    for _, pos in ipairs(positions) do
        love.graphics.draw(
            image, 
            pos[1] - scaledWidth/2,
            pos[2] - scaledHeight/2,
            0,
            scale, scale
        )
    end
end

-- Draw a card with burning effect
function game.drawBurningCard(anim)
    -- Different drawing logic depending on which phase we're in
    local phase = anim.phase
    local progress = anim.phaseProgress
    
    if phase == 1 then
        -- Phase 1: Background fades to medium red, shapes fade to black
        
        -- Draw card background with increasing red tint
        local redAmount = 0.6 * progress -- Medium red
        love.graphics.setColor(1, 1 - redAmount, 1 - redAmount, 1)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)
        
        -- Draw border with slight red tint
        love.graphics.setColor(1, 0.3, 0.3, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)
        
        -- Set color for the shapes - fade toward black
        local blackAmount = progress
        if anim.card.color == "red" then
            love.graphics.setColor(0.85 * (1 - blackAmount), 0.15 * (1 - blackAmount), 0.15 * (1 - blackAmount), 1)
        elseif anim.card.color == "green" then
            love.graphics.setColor(0.15 * (1 - blackAmount), 0.65 * (1 - blackAmount), 0.25 * (1 - blackAmount), 1)
        elseif anim.card.color == "blue" then
            love.graphics.setColor(0.15 * (1 - blackAmount), 0.35 * (1 - blackAmount), 0.75 * (1 - blackAmount), 1)
        end
        
    elseif phase == 2 then
        -- Phase 2: Card fades to bright orange/red (shapes no longer visible)
        local brightRed = 1
        local brightGreen = 0.3 + (0.4 * (1 - progress)) -- Fades from orange-red to red
        local brightBlue = 0.1 * (1 - progress) -- Almost no blue at the end
        
        -- Draw card background with bright orange/red
        love.graphics.setColor(brightRed, brightGreen, brightBlue, 1)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)
        
        -- Draw border slightly brighter
        love.graphics.setColor(1, 0.5 * (1 - progress), 0.2 * (1 - progress), 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)
        
        -- Draw shapes with the same color (they become invisible against background)
        love.graphics.setColor(brightRed, brightGreen, brightBlue, 1)
        
    elseif phase == 3 then
        -- Phase 3: Card fades to deep dark blackish red
        local darkRed = 0.6 - (0.5 * progress) -- From medium red to very dark red
        local darkGreen = 0.05 * (1 - progress)
        local darkBlue = 0.05 * (1 - progress)
        
        -- Draw card background with darkening red
        love.graphics.setColor(darkRed, darkGreen, darkBlue, 1)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)
        
        -- Draw border with matching dark red
        love.graphics.setColor(darkRed + 0.2, darkGreen, darkBlue, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)
        
        -- Shapes use the same color as the background (invisible)
        love.graphics.setColor(darkRed, darkGreen, darkBlue, 1)
        
    elseif phase == 4 then
        -- Phase 4: Card fades from opaque to transparent
        local opacity = 1 - progress
        
        -- Draw card with dark red and fading opacity
        local darkRed = 0.1
        local darkGreen = 0
        local darkBlue = 0
        
        -- Draw card background with fading opacity
        love.graphics.setColor(darkRed, darkGreen, darkBlue, opacity)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)
        
        -- Draw border with fading opacity
        love.graphics.setColor(darkRed + 0.2, darkGreen, darkBlue, opacity)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)
        
        -- No need to draw shapes at this point
        return
    end
    
    -- Only draw shapes for phases 1-3 (phase 4 returns early)
    -- Get the image for this shape and fill
    local image = cardImages[anim.card.shape][anim.card.fill]
    if not image then
        return
    end
    
    -- Calculate image dimensions and scaling (similar to drawCard logic)
    local imgWidth = image:getWidth()
    local imgHeight = image:getHeight()
    local baseScale = 0.8
    local maxShapesWidth = imgWidth * 3
    local spacingWidth = imgWidth * 0.6
    local totalWidthNeeded = maxShapesWidth + spacingWidth
    local scaleForWidth = (anim.width * 0.85) / totalWidthNeeded
    local scaleForHeight = (anim.height * 0.55) / imgHeight
    local scale = math.min(scaleForWidth, scaleForHeight, baseScale)
    local scaledWidth = imgWidth * scale
    local scaledHeight = imgHeight * scale
    
    -- Calculate positions for the symbols based on card.number and scaled size
    local positions = {}
    if anim.card.number == 1 then
        positions = {
            {anim.x + anim.width/2, anim.y + anim.height/2}
        }
    elseif anim.card.number == 2 then
        local spacing = scaledWidth * 0.15
        positions = {
            {anim.x + anim.width/2 - spacing - scaledWidth/2, anim.y + anim.height/2},
            {anim.x + anim.width/2 + spacing + scaledWidth/2, anim.y + anim.height/2}
        }
    elseif anim.card.number == 3 then
        local spacing = scaledWidth * 0.15
        positions = {
            {anim.x + anim.width/2 - spacing*2 - scaledWidth, anim.y + anim.height/2},
            {anim.x + anim.width/2, anim.y + anim.height/2},
            {anim.x + anim.width/2 + spacing*2 + scaledWidth, anim.y + anim.height/2}
        }
    end
    
    -- Draw the symbols at each position with the calculated scale
    for _, pos in ipairs(positions) do
        love.graphics.draw(
            image, 
            pos[1] - scaledWidth/2,
            pos[2] - scaledHeight/2,
            0,
            scale, scale
        )
    end
end

-- Draw deck information
function game.drawDeckInfo()
    -- Set text color to white
    love.graphics.setColor(1, 1, 1)
    -- Set font
    love.graphics.setFont(love.graphics.newFont(16))    -- Get window dimensions
    local windowWidth = love.graphics.getWidth()
      -- Display score - positioned in top right
    local scoreText = "Score: " .. score
    love.graphics.print(scoreText, windowWidth - 250, 20)
    
    -- Display cards remaining - positioned below the score, first letters aligned
    local cardsRemaining = deck.getCount()
    local infoText = "Cards remaining in deck: " .. cardsRemaining
    love.graphics.print(infoText, windowWidth - 250, 45)
    
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
                -- Get window dimensions to calculate proportions for animations
                local windowWidth, windowHeight = love.graphics.getDimensions()
                local cardWidth = windowWidth * 0.2 
                local cardHeight = windowHeight * 0.2
                local marginX = cardWidth * 0.1
                local marginY = cardHeight * 0.1
                local startX = windowWidth * 0.05
                local startY = windowHeight * 0.15
                
                -- Add the card to the board
                table.insert(board, card)
                
                -- Calculate position in the grid for animation
                local newIndex = #board
                local col = (newIndex - 1) % 4
                local row = math.floor((newIndex - 1) / 4)
                local x = startX + col * (cardWidth + marginX)
                local y = startY + row * (cardHeight + marginY)
                
                -- Create fade-in animation
                game.animateCardFadeIn(card, x, y, cardWidth, cardHeight)
                
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
    -- Check if there's no set on the board
    elseif key == "x" then
        game.checkNoSetOnBoard()
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
            
            -- Sort in reverse order so indices remain valid during removal
            table.sort(selectedCards, function(a, b) return a > b end)
            
            -- Remove the cards immediately (no animation for regular card removal)
            for _, idx in ipairs(selectedCards) do
                table.remove(board, idx)
            end
            
            -- Increment score when a valid set is found
            score = score + 1
            print("Board now has " .. #board .. " cards")
            
            -- Reset hint state when board changes
            hintActive = false
            hintCards = {}
            
            -- If there are cards in the deck, add new cards to replace the removed ones
            local cardsToAdd = math.min(3, deck.getCount())
            if cardsToAdd > 0 and #board < 12 then
                -- Get window dimensions to calculate proportions for animations
                local windowWidth, windowHeight = love.graphics.getDimensions()
                local cardWidth = windowWidth * 0.2 
                local cardHeight = windowHeight * 0.2
                local marginX = cardWidth * 0.1
                local marginY = cardHeight * 0.1
                local startX = windowWidth * 0.05
                local startY = windowHeight * 0.15
                
                -- Add new cards from the deck with fade-in animation
                for i = 1, cardsToAdd do
                    local newCard = deck.takeCard()
                    if newCard then
                        -- Add the card to the board
                        table.insert(board, newCard)
                        
                        -- Calculate position in the grid for animation
                        local newIndex = #board
                        local col = (newIndex - 1) % 4
                        local row = math.floor((newIndex - 1) / 4)
                        local x = startX + col * (cardWidth + marginX)
                        local y = startY + row * (cardHeight + marginY)
                        
                        -- Create fade-in animation
                        game.animateCardFadeIn(newCard, x, y, cardWidth, cardHeight)
                    end
                end
            end
        else
            print("Not a valid Set! Deselecting cards.")
            -- Deselect all cards
            for _, index in ipairs(selectedCards) do
                board[index].selected = false
            end
        end
    end
end

-- Check if there's no set on the board (when player presses 'x')
function game.checkNoSetOnBoard()
    local validSet = game.findValidSet()
    
    if validSet then
        -- There is a set but player claimed there wasn't (incorrect)
        print("Set found! Player was incorrect.")
        
        -- Get window dimensions to calculate proportions for animations
        local windowWidth, windowHeight = love.graphics.getDimensions()
        local cardWidth = windowWidth * 0.2 
        local cardHeight = windowHeight * 0.2
        local marginX = cardWidth * 0.1
        local marginY = cardHeight * 0.1
        local startX = windowWidth * 0.05
        local startY = windowHeight * 0.15
        
        -- Prepare cards for animation
        local animatingCardsIndices = validSet
        local animationsStarted = 0
        local totalAnimations = #animatingCardsIndices
        
        -- Start burning animation for each card in the set
        for _, index in ipairs(animatingCardsIndices) do
            local card = board[index]
            
            -- Calculate position in the grid for animation
            local col = (index - 1) % 4
            local row = math.floor((index - 1) / 4)
            local x = startX + col * (cardWidth + marginX)
            local y = startY + row * (cardHeight + marginY)
            
            -- Create burn animation
            game.animateCardBurn(card, x, y, cardWidth, cardHeight, function()
                animationsStarted = animationsStarted + 1
                
                -- When all animations are complete, finish the discard process
                if animationsStarted == totalAnimations then
                    -- Move cards to the discard pile
                    for _, setIndex in ipairs(validSet) do
                        table.insert(discardedCards, board[setIndex])
                    end
                      -- Remove the set cards from the board in reverse order
                    -- to avoid index shifting problems
                    table.sort(validSet, function(a, b) return a > b end)
                    for _, setIndex in ipairs(validSet) do
                        table.remove(board, setIndex)
                    end
                    
                    -- Reduce score by 1, but ensure it doesn't go below 0
                    if score > 0 then
                        score = score - 1
                        print("Player loses a point. New score: " .. score)
                    else
                        print("Score already at 0, no points deducted.")
                    end
                    
                    -- Disable hint mode when board changes
                    hintActive = false
                    hintCards = {}
                end
            end)
        end
    else
        -- There is no set and player was correct
        print("No set found! Player was correct.")
        
        -- Select half of the cards to be removed
        local cardsToRemove = {}
        local removedCards = {}
        local numToRemove = math.floor(#board / 2)
        
        -- Create a copy of board indices to shuffle
        local indices = {}
        for i = 1, #board do
            table.insert(indices, i)
        end
        
        -- Shuffle the indices
        for i = #indices, 2, -1 do
            local j = math.random(i)
            indices[i], indices[j] = indices[j], indices[i]
        end
        
        -- Select the first half of the shuffled indices
        for i = 1, numToRemove do
            table.insert(cardsToRemove, indices[i])
        end
        
        -- Sort in reverse order to avoid index shifting when removing
        table.sort(cardsToRemove, function(a, b) return a > b end)
        
        -- Remove selected cards from the board and save them
        for _, index in ipairs(cardsToRemove) do
            local removedCard = table.remove(board, index)
            table.insert(removedCards, removedCard)
        end
        
        -- Return these cards to the deck
        for _, card in ipairs(removedCards) do
            -- Reset the card's selection state before returning to deck
            card.selected = false
            table.insert(deck.getCards(), card)
        end
          -- Shuffle the deck to ensure cards don't come back immediately
        deck.shuffle()
        
        -- Get window dimensions to calculate proportions for animations
        local windowWidth, windowHeight = love.graphics.getDimensions()
        local cardWidth = windowWidth * 0.2 
        local cardHeight = windowHeight * 0.2
        local marginX = cardWidth * 0.1
        local marginY = cardHeight * 0.1
        local startX = windowWidth * 0.05
        local startY = windowHeight * 0.15
        
        -- Refill the board from the deck with fade-in animation
        while #board < 12 and deck.getCount() > 0 do
            local card = deck.takeCard()
            if card then
                -- Add the card to the board
                table.insert(board, card)
                
                -- Calculate position in the grid for animation
                local newIndex = #board
                local col = (newIndex - 1) % 4
                local row = math.floor((newIndex - 1) / 4)
                local x = startX + col * (cardWidth + marginX)
                local y = startY + row * (cardHeight + marginY)
                
                -- Create fade-in animation
                game.animateCardFadeIn(card, x, y, cardWidth, cardHeight)
            end
        end
        
        -- Increase score by 1
        score = score + 1
        print("Player gains a point. New score: " .. score)
        
        -- Disable hint mode when board changes
        hintActive = false
        hintCards = {}
    end
end

-- Export the game module
return game