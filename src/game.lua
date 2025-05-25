-- filepath: c:\source\set\src\game.lua
-- Game logic and state management
local deck = require('deck')
local card = require('card')
local game = {}

-- Game states
local GAME_STATE = {
    MENU = "menu",
    PLAYING = "playing"
}
local currentState = GAME_STATE.MENU

-- UI elements for main menu
local playButton = {
    x = 0,
    y = 0,
    width = 200,
    height = 60,
    text = "Play Game"
}

-- Cards
local board = {} -- Using a 4x3 grid with nil for empty positions
local discardedCards = {} -- never returned to deck until a new game
local hintCards = {} -- Indices of cards in a valid set for hint

-- Game constants
local BOARD_COLUMNS = 4
local BOARD_ROWS = 3
local BOARD_SIZE = BOARD_COLUMNS * BOARD_ROWS

-- Game state
local bHintIsActive = false -- Track if hint mode is active
local score = 0 -- Track player's score
local bGameEnded = false -- Track if the game has ended

-- Helper function to convert 1D index to 2D grid position
function game.indexToGridPos(index)
    local col = (index - 1) % BOARD_COLUMNS -- 0-based
    local row = math.floor((index - 1) / BOARD_COLUMNS) -- 0-based
    return col, row
end

-- Helper function to convert 2D grid position to 1D index
function game.gridPosToIndex(col, row)
    return row * BOARD_COLUMNS + col + 1
end

function game.reset()
    -- Initialize board with all nil values
    board = {}
    for i = 1, BOARD_SIZE do
        board[i] = nil
    end

    discardedCards = {}
    hintCards = {}
    bHintIsActive = false
    score = 0
    bGameEnded = false
end

-- Initialize the game state
function game.initialize()
    game.reset()
    love.graphics.setBackgroundColor(0.34, 0.45, 0.47)
    card.loadImages()

    -- Center the play button
    local windowWidth, windowHeight = love.graphics.getDimensions()
    playButton.x = windowWidth / 2 - playButton.width / 2
    playButton.y = windowHeight / 2 - playButton.height / 2

    -- Start in menu state
    currentState = GAME_STATE.MENU
end

-- Setup game play
function game.setupGamePlay()
    deck.create()
    deck.shuffle()
    game.dealInitialCards()
end

-- Deal the initial cards to the board
function game.dealInitialCards()
    for i = 1, BOARD_SIZE do
        local cardRef = deck.takeCard()
        if cardRef then
            board[i] = cardRef
        end
    end
end

-- Update function, called from love.update
function game.update(dt)
    if currentState == GAME_STATE.PLAYING then
        card.updateAnimations(dt)

        -- Check if the game has ended
        game.checkGameEnd()
    end
end

-- Draw function called from love.draw
function game.draw()
    if currentState == GAME_STATE.MENU then
        game.drawMenu()
    elseif currentState == GAME_STATE.PLAYING then
        game.drawPlaying()
    end
end

function game.drawMenu()
    -- Draw the menu background
    love.graphics.clear(0.34, 0.45, 0.47)

    -- Set the font for the menu title
    love.graphics.setFont(love.graphics.newFont(32))

    -- Draw the title
    love.graphics.setColor(1, 1, 1) -- White
    love.graphics.printf("Welcome to the Set Game!", 0, 100, love.graphics.getWidth(), "center")

    -- Draw the play button
    love.graphics.setColor(0.2, 0.6, 0.2) -- Green
    love.graphics.rectangle("fill", playButton.x, playButton.y, playButton.width, playButton.height, 8, 8)

    -- Set the font for the button text
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.setColor(1, 1, 1) -- White
    love.graphics.printf(playButton.text, playButton.x, playButton.y + 15, playButton.width, "center")
end

function game.drawPlaying()
    game.drawBoard()
    card.drawAnimatingCards()
    game.drawDeckInfo()

    -- Draw game end screen if the game has ended
    -- This is drawn last so it appears on top of everything else
    if bGameEnded then
        game.drawGameEndScreen()
    end
end

-- Draw the game end screen with final score
function game.drawGameEndScreen()
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local circleRadius = math.min(windowWidth, windowHeight) * 0.4 -- 80% diameter = 40% radius
    local centerX, centerY = windowWidth / 2, windowHeight / 2

    -- Draw a big yellow circle
    love.graphics.setColor(1, 1, 0) -- Yellow
    love.graphics.circle("fill", centerX, centerY, circleRadius)

    -- Create a larger font for the score text
    local fontSize = circleRadius / 5 -- Size proportional to circle
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)

    -- Draw the final score text in black
    love.graphics.setColor(0, 0, 0) -- Black
    local scoreText = "Final Score: " .. score

    -- Calculate text dimensions for centering
    local textWidth = font:getWidth(scoreText)
    local textHeight = font:getHeight()

    -- Draw the text once, centered
    love.graphics.print(scoreText, centerX - textWidth / 2, centerY - textHeight / 2)

    -- Reset font to default
    love.graphics.setFont(love.graphics.newFont(16))
end

-- Draw text info on cards remaining and current score
function game.drawDeckInfo()
    love.graphics.setColor(1, 1, 1)
    local windowWidth = love.graphics.getWidth()
    -- Create and set a 16pt font for the deck info
    local font = love.graphics.newFont(16)
    love.graphics.setFont(font)
    -- Display score in top right
    local scoreText = "Score: " .. score
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

    -- Draw a white rectangle board background behind the cards
    love.graphics.setColor(1, 1, 1) -- Pure white

    -- Calculate the board rectangle dimensions
    -- Add some padding around the entire board
    local boardPadding = layout.cardWidth * 0.15 -- % of card width for padding

    local boardX = layout.startX - boardPadding
    local boardY = layout.startY - boardPadding
    local boardWidth = BOARD_COLUMNS * layout.cardWidth + (BOARD_COLUMNS - 1) * layout.marginX + 2 * boardPadding
    local boardHeight = BOARD_ROWS * layout.cardHeight + (BOARD_ROWS - 1) * layout.marginY + 2 * boardPadding

    -- Draw the white rectangle background
    love.graphics.rectangle("fill", boardX, boardY, boardWidth, boardHeight, 8, 8) -- Rounded corners

    -- Draw each card on the board
    for i = 1, BOARD_SIZE do
        local cardData = board[i]
        if cardData then -- Only draw non-nil cards
            -- Calculate position in the grid (4 columns, 3 rows)
            local col = (i - 1) % BOARD_COLUMNS -- 0, 1, 2, 3
            local row = math.floor((i - 1) / BOARD_COLUMNS) -- 0, 1, 2
            -- Calculate pixel position
            local x = layout.startX + col * (layout.cardWidth + layout.marginX)
            local y = layout.startY + row * (layout.cardHeight + layout.marginY)
            -- Draw the card
            game.drawCard(cardData, x, y, layout.cardWidth, layout.cardHeight, i)
        end
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
    -- Count cards on the board to check if we have at least 3
    local cardCount = 0
    local cardIndices = {}
    for i = 1, BOARD_SIZE do
        if board[i] then
            cardCount = cardCount + 1
            table.insert(cardIndices, i)
        end
    end

    -- Need at least 3 cards to form a set
    if cardCount < 3 then
        return nil
    end

    -- Try all possible combinations of 3 cards
    for i = 1, #cardIndices - 2 do
        for j = i + 1, #cardIndices - 1 do
            for k = j + 1, #cardIndices do
                local idx1, idx2, idx3 = cardIndices[i], cardIndices[j], cardIndices[k]
                if card.isValidSet(board[idx1], board[idx2], board[idx3]) then
                    return {idx1, idx2, idx3}
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

-- Helper function to clear all card selections
function game.clearCardSelection()
    for i = 1, BOARD_SIZE do
        local cardRef = board[i]
        if cardRef then
            card.setSelected(cardRef, false)
        end
    end
end

-- Handle keyboard input
function game.keypressed(key)
    -- Allow ESC key to quit the game from menu
    if currentState == GAME_STATE.MENU then
        if key == "escape" then
            love.event.quit()
            return
        end
    end

    -- If game has ended, only respond to spacebar to start a new game
    if currentState == GAME_STATE.PLAYING and bGameEnded then
        if key == "space" then
            game.initialize() -- Start a brand new game
            return
        else
            return -- Ignore all other keypresses in game end state
        end
    end

    -- Game playing controls
    if currentState == GAME_STATE.PLAYING then
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
            -- Check if there's any empty position on the board
            local bEmptyPositionExists = false
            for i = 1, BOARD_SIZE do
                if not board[i] then
                    bEmptyPositionExists = true
                    break
                end
            end

            -- Don't draw if there are no empty positions
            if not bEmptyPositionExists then
                return
            end

            local cardData = deck.takeCard()
            if cardData then
                -- Find the first empty position to place the card
                for i = 1, BOARD_SIZE do
                    if not board[i] then
                        -- Simply add the card to the first empty position without animation
                        board[i] = cardData
                        break
                    end
                end
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
        elseif key == "escape" then
            -- Return to main menu
            currentState = GAME_STATE.MENU
        end
    end
end

-- Handle mouse press events
function game.mousepressed(x, y, button)
    -- If in menu state, check for button clicks
    if currentState == GAME_STATE.MENU then
        if button == 1 then -- Left mouse button
            -- Check if play button was clicked
            if x >= playButton.x and x <= playButton.x + playButton.width and
               y >= playButton.y and y <= playButton.y + playButton.height then
                -- Switch to play state
                currentState = GAME_STATE.PLAYING
                game.setupGamePlay()
                return
            end
        end
        return
    end

    -- Ignore mouse events if the game has ended
    if bGameEnded then
        return
    end
    
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
    for i = 1, BOARD_SIZE do
        if board[i] then -- Only check positions where there's a card
            -- Calculate position in the grid
            local col = (i - 1) % BOARD_COLUMNS -- 0, 1, 2, 3
            local row = math.floor((i - 1) / BOARD_COLUMNS) -- 0, 1, 2
            -- Calculate pixel position of this card
            local cardX = layout.startX + col * (layout.cardWidth + layout.marginX)
            local cardY = layout.startY + row * (layout.cardHeight + layout.marginY)
            -- Check if the point (x,y) is within this card's bounds
            if x >= cardX and x <= cardX + layout.cardWidth and y >= cardY and y <= cardY + layout.cardHeight then
                return i -- Return the index of the clicked card
            end
        end
    end
    return nil -- No card was clicked
end

-- Get all selected cards
function game.getSelectedCards()
    local selected = {}
    for i = 1, BOARD_SIZE do
        local cardRef = board[i]
        if cardRef and card.isSelected(cardRef) then
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
                board[idx] = nil
            end            
            -- Increment score when a valid set is found
            score = score + 1
            
            -- Check if the game has ended after removing cards
            game.checkGameEnd()
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
            board[index] = nil
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
                    
                    -- Check if the game has ended after animation completes
                    game.checkGameEnd()
                end
            end)
        end
    else
        -- There is no set and player was correct
        print("No set found! Player was correct.")        
        -- Select half of the cards to be removed
        local cardsToRemove = {}
        local removedCards = {}
        
        -- Count how many cards are on the board
        local nonEmptyPositions = {}
        for i = 1, BOARD_SIZE do
            if board[i] then
                table.insert(nonEmptyPositions, i)
            end
        end
        
        local numToRemove = math.floor(#nonEmptyPositions / 2)
        
        -- Shuffle the indices of non-empty positions
        for i = #nonEmptyPositions, 2, -1 do
            local j = math.random(i)
            nonEmptyPositions[i], nonEmptyPositions[j] = nonEmptyPositions[j], nonEmptyPositions[i]
        end
        
        -- Select the first half of the shuffled indices to remove
        for i = 1, numToRemove do
            table.insert(cardsToRemove, nonEmptyPositions[i])
        end
        
        -- Remove selected cards from the board and save them
        for _, index in ipairs(cardsToRemove) do
            local removedCard = board[index]
            board[index] = nil -- Clear the position
            table.insert(removedCards, removedCard)
        end 
        
        -- Return these cards to the deck
        for _, cardRef in ipairs(removedCards) do 
            -- Reset the card's selection state before returning to deck
            card.setSelected(cardRef, false)
            table.insert(deck.getCards(), cardRef)
        end
        
        -- Shuffle the deck to ensure cards don't come back immediately
        deck.shuffle()
        
        -- Get layout dimensions for animations
        local layout = game.calculateCardLayout()
        
        -- Refill empty positions on the board from the deck without animation
        for i = 1, BOARD_SIZE do
            if not board[i] and deck.getCount() > 0 then
                local cardRef = deck.takeCard()
                if cardRef then
                    -- Simply add the card to the empty position without animation
                    board[i] = cardRef
                end
            end
        end        
        -- Increase score by 1
        score = score + 1
        -- Disable hint mode when board changes
        bHintIsActive = false
        hintCards = {}
        
        -- Check if the game has ended after board changes
        game.checkGameEnd()
    end
end

-- Check if the game has ended (deck is empty and no more valid sets)
function game.checkGameEnd()
    -- Only check if the game hasn't ended already
    if not bGameEnded then
        -- Game ends when deck is empty and there are no valid sets on the board
        if deck.getCount() == 0 and not game.findValidSet() then
            bGameEnded = true
        end
    end
    
    return bGameEnded
end

-- Export the game module
return game
