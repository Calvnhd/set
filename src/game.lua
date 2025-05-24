-- Game logic and state management
local deck = require('deck')
local card = require('card')
local game = {}

-- Cards
local board = {} -- cards currently in play
local discardedCards = {} -- never returned to deck until a new game
local hintCards = {} -- Indices of cards in a valid set for hint

-- Game state
local hintActive = false -- Track if hint mode is active
local score = 0 -- Track player's score

-- Initialize the game state
function game.initialize()
    card.loadImages()
    deck.create()
    deck.shuffle()
    game.dealInitialCards()
    love.graphics.setBackgroundColor(0.2, 0.3, 0.4) -- Dark blue
    hintActive = false
    hintCards = {}
    score = 0
    discardedCards = {}
end

-- Deal the initial cards to the board
function game.dealInitialCards()
    board = {}
    hintActive = false
    hintCards = {}
    for i = 1, 12 do
        local card = deck.takeCard()
        if card then
            table.insert(board, card)
        end
    end
end

-- Update function called from love.update
function game.update(dt)
    -- Update animations
    card.updateAnimations(dt)
end

-- Draw function called from love.draw
function game.draw()
    game.drawBoard()
    card.drawAnimatingCards()
    game.drawDeckInfo()
end

-- Draw deck information
function game.drawDeckInfo()
    -- Set text color to white
    love.graphics.setColor(1, 1, 1)
    -- Set font
    love.graphics.setFont(love.graphics.newFont(16)) -- Get window dimensions
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
    local startX = windowWidth * 0.05 -- Adjusted starting position
    local startY = windowHeight * 0.15 -- Adjusted starting position
    -- Draw each card on the board
    for i, cardData in ipairs(board) do
        -- Calculate position in the grid (4 columns, 3 rows)
        local col = (i - 1) % 4 -- 0, 1, 2, 3
        local row = math.floor((i - 1) / 4) -- 0, 1, 2
        -- Calculate pixel position
        local x = startX + col * (cardWidth + marginX)
        local y = startY + row * (cardHeight + marginY)
        -- Draw the card
        game.drawCard(cardData, x, y, cardWidth, cardHeight, i)
    end
end

-- Draw a single card (wrapper for card module function)
function game.drawCard(cardData, x, y, width, height, index)
    local bIsInHint = hintActive and isInHint(index)
    card.draw(cardData, x, y, width, height, cardData.selected, bIsInHint)
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
        -- Draw a card from the deck if there's space on the board    elseif key == "d" then
        if #board < 12 then
            local cardData = deck.takeCard()
            if cardData then
                -- Get window dimensions to calculate proportions for animations
                local windowWidth, windowHeight = love.graphics.getDimensions()
                local cardWidth = windowWidth * 0.2
                local cardHeight = windowHeight * 0.2
                local marginX = cardWidth * 0.1
                local marginY = cardHeight * 0.1
                local startX = windowWidth * 0.05
                local startY = windowHeight * 0.15

                -- Add the card to the board
                table.insert(board, cardData)

                -- Calculate position in the grid for animation
                local newIndex = #board
                local col = (newIndex - 1) % 4
                local row = math.floor((newIndex - 1) / 4)
                local x = startX + col * (cardWidth + marginX)
                local y = startY + row * (cardHeight + marginY)

                -- Create fade-in animation using card module
                card.animateFadeIn(cardData, x, y, cardWidth, cardHeight)

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
    local cardWidth = windowWidth * 0.23 -- Match the card width from drawBoard
    local cardHeight = windowHeight * 0.29 -- Match the card height from drawBoard
    -- Calculate margins and starting position
    local marginX = windowWidth * 0.012 -- Match the margin from drawBoard
    local marginY = windowHeight * 0.015 -- Match the margin from drawBoard
    local startX = windowWidth * 0.03 -- Match the start position from drawBoard
    local startY = windowHeight * 0.06 -- Match the start position from drawBoard
    -- Check each card's position
    for i, card in ipairs(board) do
        -- Calculate position in the grid (4 columns, 3 rows)
        local col = (i - 1) % 4 -- 0, 1, 2, 3
        local row = math.floor((i - 1) / 4) -- 0, 1, 2
        -- Calculate pixel position of this card
        local cardX = startX + col * (cardWidth + marginX)
        local cardY = startY + row * (cardHeight + marginY)
        -- Check if the point (x,y) is within this card's bounds
        if x >= cardX and x <= cardX + cardWidth and y >= cardY and y <= cardY + cardHeight then
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
            table.sort(selectedCards, function(a, b)
                return a > b
            end)

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
                        local y = startY + row * (cardHeight + marginY)                        -- Create fade-in animation
                        card.animateFadeIn(newCard, x, y, cardWidth, cardHeight)
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
        local totalAnimations = #animatingCardsIndices            -- Start burning animation for each card in the set
        for _, index in ipairs(animatingCardsIndices) do
            local cardData = board[index]

            -- Calculate position in the grid for animation
            local col = (index - 1) % 4
            local row = math.floor((index - 1) / 4)
            local x = startX + col * (cardWidth + marginX)
            local y = startY + row * (cardHeight + marginY)

            -- Create burn animation
            card.animateBurn(cardData, x, y, cardWidth, cardHeight, function()
                animationsStarted = animationsStarted + 1

                -- When all animations are complete, finish the discard process
                if animationsStarted == totalAnimations then
                    -- Move cards to the discard pile
                    for _, setIndex in ipairs(validSet) do
                        table.insert(discardedCards, board[setIndex])
                    end
                    -- Remove the set cards from the board in reverse order
                    -- to avoid index shifting problems
                    table.sort(validSet, function(a, b)
                        return a > b
                    end)
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
        table.sort(cardsToRemove, function(a, b)
            return a > b
        end)

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
                local y = startY + row * (cardHeight + marginY)                -- Create fade-in animation
                card.animateFadeIn(card, x, y, cardWidth, cardHeight)
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
