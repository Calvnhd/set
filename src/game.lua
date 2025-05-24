-- Game logic and state management
local deck = require('deck')
local card = require('card')
local game = {}

-- Cards
local board = {} -- cards currently in play
local discardedCards = {} -- never returned to deck until a new game
local hintCards = {} -- Indices of cards in a valid set for hint

-- Game state
local bHintIsActive = false -- Track if hint mode is active
local score = 0 -- Track player's score

function game.reset()
    board = {}
    discardedCards = {}
    hintCards = {}
    bHintIsActive = false
    score = 0
end

-- Initialize the game state
function game.initialize()
    game.reset()
    love.graphics.setBackgroundColor(0.2, 0.3, 0.4) -- Dark blue
    card.loadImages()
    deck.create()
    deck.shuffle()
    game.dealInitialCards()

end

-- Deal the initial cards to the board
function game.dealInitialCards()
    for i = 1, 12 do
        local cardRef = deck.takeCard()
        if cardRef then
            table.insert(board, cardRef)
        end
    end
end

-- Update function, called from love.update
function game.update(dt)
    card.updateAnimations(dt)
end

-- Draw function called from love.draw
function game.draw()
    game.drawBoard()
    card.drawAnimatingCards()
    game.drawDeckInfo()
end

-- Draw text info on cards remaining and current score
function game.drawDeckInfo()
    love.graphics.setColor(1, 1, 1)
    local windowWidth = love.graphics.getWidth()
    -- Display score in top right
    local scoreText = "Score: " .. score
    local font = love.graphics.newFont(16)
    love.graphics.print(scoreText, windowWidth - 250, 20)
    -- Display cards remaining - positioned below the score, first letters aligned
    local cardsRemaining = deck.getCount()
    local infoText = "Cards remaining in deck: " .. cardsRemaining
    love.graphics.print(infoText, windowWidth - 250, 45)
end

-- Calculate card layout dimensions and positions
function game.calculateCardLayout()
    -- Get window dimensions to calculate proportions
    local windowWidth, windowHeight = love.graphics.getDimensions()
    -- Calculate card dimensions based on screen size
    local cardWidth = windowWidth * 0.2
    local cardHeight = windowHeight * 0.2
    -- Calculate margins and starting position
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

-- Draw the board of cards in a 4x3 pattern
function game.drawBoard()
    -- Get the card layout dimensions
    local layout = game.calculateCardLayout()
    -- Draw each card on the board
    for i, cardData in ipairs(board) do
        -- Calculate position in the grid (4 columns, 3 rows)
        local col = (i - 1) % 4 -- 0, 1, 2, 3
        local row = math.floor((i - 1) / 4) -- 0, 1, 2
        -- Calculate pixel position
        local x = layout.startX + col * (layout.cardWidth + layout.marginX)
        local y = layout.startY + row * (layout.cardHeight + layout.marginY)
        -- Draw the card
        game.drawCard(cardData, x, y, layout.cardWidth, layout.cardHeight, i)
    end
end

-- Draw a single card (wrapper for card module function)
function game.drawCard(cardRef, x, y, width, height, index)
    local bIsInHint = bHintIsActive and isInHint(index)
    card.draw(cardRef, x, y, width, height, bIsInHint)
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
                if card.isValidSet(board[i], board[j], board[k]) then
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
    if bHintIsActive then
        bHintIsActive = false
        hintCards = {}
        return
    end
    -- Try to find a valid set
    local set = game.findValidSet()
    if set then
        bHintIsActive = true
        hintCards = set
    end
end

-- Handle keyboard input
function game.keypressed(key)
    if key == "s" then
        local selectedCards = game.getSelectedCards()
        if #selectedCards == 3 then
            game.removeSelectedCards()
            return
        end
    end
    -- Clear card selection on any other key input
    game.clearCardSelection()
    if key == "d" then
        -- Draw a card from the deck if there's space on the board    
        if #board >= 12 then
            return
        end        local cardData = deck.takeCard()
        if cardData then
            -- Simply add the card to the board without animation
            table.insert(board, cardData)
            -- No animation needed, the card will appear in the next draw cycle
        end
        -- Reset hint state when board changes
        bHintIsActive = false
        hintCards = {}
    elseif key == "h" then
        -- Toggle hint mode
        game.toggleHint()
    elseif key == "x" then
        -- Check if there's no set on the board
        game.checkNoSetOnBoard()
    end
end

-- Helper function to clear all card selections
function game.clearCardSelection()
    for _, cardRef in ipairs(board) do
        card.setSelected(cardRef, false)
    end
end

-- Handle mouse press events
function game.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        -- Check if any card was clicked
        local clickedCardIndex = game.getCardAtPosition(x, y)
        if clickedCardIndex then
            local selectedCards = game.getSelectedCards()
            local clickedCardIsSelected = card.isSelected(board[clickedCardIndex])
            -- If we already have 3 cards selected and trying to select a new one, do nothing
            if #selectedCards == 3 and not clickedCardIsSelected then
                return
            end
            -- Toggle the card's selection state
            card.toggleSelected(board[clickedCardIndex])
            -- Disable hint mode when a card is selected
            bHintIsActive = false
            hintCards = {}
        end
    end
end

-- Get the card at a given position (returns the index or nil)
function game.getCardAtPosition(x, y)
    -- Get layout dimensions
    local layout = game.calculateCardLayout()
    -- Check each card's position
    for i, _ in ipairs(board) do
        -- Calculate position in the grid (4 columns, 3 rows)
        local col = (i - 1) % 4 -- 0, 1, 2, 3
        local row = math.floor((i - 1) / 4) -- 0, 1, 2
        -- Calculate pixel position of this card
        local cardX = layout.startX + col * (layout.cardWidth + layout.marginX)
        local cardY = layout.startY + row * (layout.cardHeight + layout.marginY)
        -- Check if the point (x,y) is within this card's bounds
        if x >= cardX and x <= cardX + layout.cardWidth and y >= cardY and y <= cardY + layout.cardHeight then
            return i -- Return the index of the clicked card
        end
    end
    return nil -- No card was clicked
end

-- Get all selected cards
function game.getSelectedCards()
    local selected = {}
    for i, cardRef in ipairs(board) do
        if card.isSelected(cardRef) then
            table.insert(selected, i)
        end
    end
    return selected
end

-- Check if three cards form a valid Set (delegate to card module)
function game.isValidSet(card1Ref, card2Ref, card3Ref)
    return card.isValidSet(card1Ref, card2Ref, card3Ref)
end

-- Remove selected cards from the board
function game.removeSelectedCards()
    local selectedCards = game.getSelectedCards()
    if #selectedCards == 3 then -- Get the actual card objects
        local cardRef1 = board[selectedCards[1]]
        local cardRef2 = board[selectedCards[2]]
        local cardRef3 = board[selectedCards[3]] -- Check if they form a valid Set
        if card.isValidSet(cardRef1, cardRef2, cardRef3) then
            -- Sort in reverse order so indices remain valid during removal
            table.sort(selectedCards, function(a, b)
                return a > b
            end)
            -- Remove the cards immediately (no animation for regular card removal)
            for _, idx in ipairs(selectedCards) do
                table.remove(board, idx)
            end            -- Increment score when a valid set is found
            score = score + 1
        else
            -- Get layout dimensions for animations
            local layout = game.calculateCardLayout()

            -- Animate incorrect set cards flashing red
            local animationsCompleted = 0
            for _, index in ipairs(selectedCards) do
                local cardRef = board[index]

                -- Calculate position in the grid for animation
                local col = (index - 1) % 4
                local row = math.floor((index - 1) / 4)
                local x = layout.startX + col * (layout.cardWidth + layout.marginX)
                local y = layout.startY + row * (layout.cardHeight + layout.marginY)

                -- Create flash red animation
                card.animateFlashRed(cardRef, x, y, layout.cardWidth, layout.cardHeight, function()
                    animationsCompleted = animationsCompleted + 1
                    if animationsCompleted == #selectedCards then
                        -- Deselect all cards after animation completes
                        for _, idx in ipairs(selectedCards) do
                            card.setSelected(board[idx], false)
                        end
                    end
                end)
            end
            -- Decrement score for incorrect attempt
            if score > 0 then
                score = score - 1
            end
        end
    end
end

-- Check if there's no set on the board
function game.checkNoSetOnBoard()
    local validSet = game.findValidSet()
    if validSet then -- There is a set but player claimed there wasn't (incorrect)
        -- Get layout dimensions for animations
        local layout = game.calculateCardLayout()

        -- Save card references and positions before modifying the board
        local cardsToAnimate = {}
        for _, index in ipairs(validSet) do
            local cardRef = board[index]
            local col = (index - 1) % 4
            local row = math.floor((index - 1) / 4)
            local x = layout.startX + col * (layout.cardWidth + layout.marginX)
            local y = layout.startY + row * (layout.cardHeight + layout.marginY)
            
            -- Store the card and its position for animation
            table.insert(cardsToAnimate, {
                cardRef = cardRef,
                x = x,
                y = y,
                index = index
            })
            
            -- Add card to discard pile
            table.insert(discardedCards, cardRef)
        end
        
        -- Sort indices in reverse to properly remove cards from board without affecting other indices
        table.sort(validSet, function(a, b) 
            return a > b 
        end)
        
        -- Remove cards from the board immediately before starting animations
        for _, index in ipairs(validSet) do
            table.remove(board, index)
        end
        
        -- Now start the animations with saved references (cards no longer on board)
        local animationsStarted = 0
        local totalAnimations = #cardsToAnimate
        
        for _, cardInfo in ipairs(cardsToAnimate) do
            -- Create burn animation using the saved card reference and position
            card.animateBurn(cardInfo.cardRef, cardInfo.x, cardInfo.y, layout.cardWidth, layout.cardHeight, function()
                animationsStarted = animationsStarted + 1
                
                -- When all animations are complete, update game state
                if animationsStarted == totalAnimations then
                    -- Reduce score by 1, but ensure it doesn't go below 0
                    if score > 0 then
                        score = score - 1
                    end

                    -- Disable hint mode when board changes
                    bHintIsActive = false
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
        table.sort(cardsToRemove, function(a, b)
            return a > b
        end)

        -- Remove selected cards from the board and save them
        for _, index in ipairs(cardsToRemove) do
            local removedCard = table.remove(board, index)
            table.insert(removedCards, removedCard)
        end -- Return these cards to the deck
        for _, cardRef in ipairs(removedCards) do -- Reset the card's selection state before returning to deck
            card.setSelected(cardRef, false)
            table.insert(deck.getCards(), cardRef)
        end
        -- Shuffle the deck to ensure cards don't come back immediately
        deck.shuffle() -- Get layout dimensions for animations
        local layout = game.calculateCardLayout()        -- Refill the board from the deck without animation
        while #board < 12 and deck.getCount() > 0 do
            local cardRef = deck.takeCard()
            if cardRef then
                -- Simply add the card to the board without animation
                table.insert(board, cardRef)
            end
        end

        -- Increase score by 1
        score = score + 1
        -- Disable hint mode when board changes
        bHintIsActive = false
        hintCards = {}
    end
end

-- Export the game module
return game
