
local EventManager = require('core.eventManager')
local Events = require('core.events')
local DeckModel = require('models.deckModel')
local CardModel = require('models.cardModel')
local RulesService = require('services.rulesService')
local ProgressManager = require('services.progressManager')
local AnimationService = require('services.animationService')
local BoardView = require('views.boardView')
local Events = require('core.events')


-- Initialize the game controller
function GameController.initialize()
    -- Subscribe to events
    EventManager.subscribe(Events.INPUT.KEY_PRESSED, GameController.handleKeypress)
    EventManager.subscribe(Events.INPUT.MOUSE_PRESSED, GameController.handleMousePress)
    EventManager.subscribe(Events.ANIMATION.COMPLETED, GameController.handleAnimationCompleted)
    EventManager.subscribe(Events.ROUND_MANAGER.ROUND_STARTED, GameController.handleRoundStarted)
    EventManager.subscribe(Events.ROUND_MANAGER.ALL_ROUNDS_COMPLETE, GameController.handleAllRoundsComplete)
    -- Initialize supporting services
    ProgressManager.initialize()
end

-- Handle round started event
function GameController.handleRoundStarted(config, roundIndex)
    GameController.applyRoundConfiguration(config)

    -- Create new deck for the round
    DeckModel.createFromConfig(config)
    DeckModel.shuffle()

    -- Clear board and deal new cards
    GameModel.reset()
    GameController.applyRoundConfiguration(config) 
    -- Reapply after reset
    GameController.dealInitialCards()
    -- this ensures that the round conditions actually make sense
    GameController.checkRoundCompletion()
end

-- Handle all rounds complete
function GameController.handleAllRoundsComplete()
    GameModel.setGameEnded(true)
end



-- Handle keyboard input
function GameController.handleKeypress(key)
    -- If game has ended, only respond to spacebar to start a new game
    if GameModel.hasGameEnded() then
        if key == "space" then
            GameController.setupNewGame()
            return
        else
            return -- Ignore all other keypresses in game end state
        end
    end

    if key == "s" then
        local selectedCards = GameModel.getSelectedCards()
        if #selectedCards == 3 then
            GameController.processSelectedCards()
            return
        end
    end

    -- Clear card selection on any other key input
    GameController.clearCardSelection()

    if key == "d" then
        GameController.drawCard()
    elseif key == "h" then
        GameController.toggleHint()
    elseif key == "x" then
        GameController.checkNoSetOnBoard()
    elseif key == "escape" then
        EventManager.emit(Events.GAME.REQUEST_MENU_TRANSITION)
    end
end

-- Handle mouse press events
function GameController.handleMousePress(x, y, button)
    -- Ignore mouse events if the game has ended
    if GameModel.hasGameEnded() then
        return
    end

    if button == 1 then -- Left mouse button
        local clickedCardIndex = BoardView.getCardAtPosition(x, y)
        if clickedCardIndex then
            local board = GameModel.getBoard()
            local cardRef = board[clickedCardIndex]
            local selectedCards = GameModel.getSelectedCards()
            local bClickedCardIsSelected = CardModel.isSelected(cardRef)
            -- Get current set size for this game mode
            local currentSetSize = GameModel.getCurrentSetSize()

            -- If we already have the required number of cards selected and trying to select a new one, do nothing
            if #selectedCards == currentSetSize and not bClickedCardIsSelected then
                return
            end
            -- Toggle the card's selection state
            CardModel.toggleSelected(cardRef)
            EventManager.emit(Events.BOARD.CARD_SELECTION_CHANGED, clickedCardIndex, CardModel.isSelected(cardRef))

            -- Disable hint mode when a card is selected
            GameModel.clearHint()
        end
    end
end

-- Process selected cards (validate and remove if valid set)
function GameController.processSelectedCards()
    local selectedCards = GameModel.getSelectedCards()
    local board = GameModel.getBoard()
    local currentSetSize = GameModel.getCurrentSetSize()

    if #selectedCards == currentSetSize then
        local cardRefs = {}
        for i, idx in ipairs(selectedCards) do
            cardRefs[i] = board[idx]
        end

        local bIsValid, message = RulesService.validateSelectedCardsOfSize(selectedCards, board, currentSetSize)        if bIsValid then
            -- Valid set - remove cards and increment score
            GameController.removeValidSet(selectedCards)
            GameModel.incrementScore()
            GameModel.incrementSetsFound()

            -- Check for round completion in both modes
            GameController.checkRoundCompletion()
        else
            -- Invalid set - animate flash red and decrement score
            GameController.animateInvalidSet(selectedCards)
            GameModel.decrementScore()
        end
    end
end

-- Remove a valid set of cards
function GameController.removeValidSet(selectedIndices)
    local board = GameModel.getBoard()

    -- Sort in reverse order so indices remain valid during removal
    table.sort(selectedIndices, function(a, b)
        return a > b
    end)

    -- Remove the cards from board and add to discard pile
    for _, idx in ipairs(selectedIndices) do
        local cardRef = GameModel.removeCardAtPosition(idx)
        if cardRef then
            GameModel.addToDiscardPile(cardRef)
        end
    end
end

-- Animate invalid set (flash red)
function GameController.animateInvalidSet(selectedIndices)
    local board = GameModel.getBoard()
    local animationsCompleted = 0

    for _, index in ipairs(selectedIndices) do
        local cardRef = board[index]
        local x, y, width, height = BoardView.getCardPosition(index)

        AnimationService.createFlashRedAnimation(cardRef, x, y, width, height, function()
            animationsCompleted = animationsCompleted + 1
            if animationsCompleted == #selectedIndices then
                -- Deselect all cards after animation completes
                for _, idx in ipairs(selectedIndices) do
                    CardModel.setSelected(board[idx], false)
                end
                EventManager.emit(Events.BOARD.CARD_DESELECTED, selectedIndices)
            end
        end)
    end
end

-- Draw a new card from deck
function GameController.drawCard()
    local emptyPosition = GameModel.findEmptyPosition()

    if not emptyPosition then
        return -- No empty positions
    end    local cardRef = DeckModel.takeCard()
    if cardRef then
        GameModel.setCardAtPosition(emptyPosition, cardRef)
        -- Reset hint state when board changes
        GameModel.clearHint()
        
        -- Check if this card draw results in round completion
        GameController.checkRoundCompletion()
    end
end

-- Toggle hint mode
function GameController.toggleHint()
    if GameModel.isHintActive() then
        GameModel.clearHint()
        return
    end

    local board = GameModel.getBoard()
    local currentSetSize = GameModel.getCurrentSetSize()
    local validSet = RulesService.findValidSetOfSize(board, currentSetSize)
    if validSet then
        GameModel.setHint(validSet)
    end
end

-- Check if there's no set on the board
function GameController.checkNoSetOnBoard()
    local board = GameModel.getBoard()
    local currentSetSize = GameModel.getCurrentSetSize()
    local validSet = RulesService.findValidSetOfSize(board, currentSetSize)

    if validSet then
        -- There is a set but player claimed there wasn't (incorrect)
        GameController.burnIncorrectCards(validSet)
        GameModel.decrementScore()
    else
        -- There is no set and player was correct
        GameController.handleCorrectNoSet()
        GameModel.incrementScore()
    end
end

-- Burn cards when player incorrectly claims no set
function GameController.burnIncorrectCards(validSet)
    local board = GameModel.getBoard()
    local cardsToAnimate = {}

    -- Save card references and positions before modifying the board
    for _, index in ipairs(validSet) do
        local cardRef = board[index]
        local x, y, width, height = BoardView.getCardPosition(index)

        table.insert(cardsToAnimate, {
            cardRef = cardRef,
            x = x,
            y = y,
            width = width,
            height = height,
            index = index
        })

        -- Add card to discard pile and remove from board
        GameModel.addToDiscardPile(cardRef)
        GameModel.removeCardAtPosition(index)
    end

    -- Start burn animations
    local animationsStarted = 0
    local totalAnimations = #cardsToAnimate

    for _, cardInfo in ipairs(cardsToAnimate) do
        AnimationService.createBurnAnimation(cardInfo.cardRef, cardInfo.x, cardInfo.y, cardInfo.width, cardInfo.height,
            function()
                animationsStarted = animationsStarted + 1
                if animationsStarted == totalAnimations then
                    GameModel.clearHint()
                end
            end)
    end
end

-- Handle correct "no set" claim
function GameController.handleCorrectNoSet()
    local board = GameModel.getBoard()
    local nonEmptyPositions = {}

    -- Find all non-empty positions
    for i = 1, GameModel.getBoardSize() do
        if board[i] then
            table.insert(nonEmptyPositions, i)
        end
    end

    local numToRemove = math.floor(#nonEmptyPositions / 2)

    -- Shuffle the indices
    for i = #nonEmptyPositions, 2, -1 do
        local j = math.random(i)
        nonEmptyPositions[i], nonEmptyPositions[j] = nonEmptyPositions[j], nonEmptyPositions[i]
    end

    -- Remove selected cards and return to deck
    for i = 1, numToRemove do
        local index = nonEmptyPositions[i]
        local cardRef = GameModel.removeCardAtPosition(index)
        if cardRef then
            CardModel.setSelected(cardRef, false)
            DeckModel.returnCard(cardRef)
        end
    end

    -- Shuffle deck and refill board
    DeckModel.shuffle()
    for i = 1, GameModel.getBoardSize() do
        if not board[i] and DeckModel.getCount() > 0 then
            local cardRef = DeckModel.takeCard()
            if cardRef then
                GameModel.setCardAtPosition(i, cardRef)
            end
        end
    end
    GameModel.clearHint()
end

-- Clear all card selections
function GameController.clearCardSelection()
    local board = GameModel.getBoard()
    local boardSize = GameModel.getBoardSize()

    for i = 1, boardSize do
        local cardRef = board[i]
        if cardRef then
            CardModel.setSelected(cardRef, false)
        end
    end

    EventManager.emit(Events.BOARD.CARD_ALL_DESELECTED)
end

-- Check if the current round is complete
function GameController.checkRoundCompletion() 
    if RoundManager.IsRoundComplete() then
        if GameModeModel.isClassicMode() then
            -- Classic mode only has one round, so end the game when complete
            GameModel.setGameEnded(true)
            EventManager.emit(Events.GAME.CLASSIC_COMPLETED)
        else
            -- Rogue mode progression
            local currentRound = GameModeModel.getCurrentRoundIndex()
            ProgressManager.markRoundCompleted(currentRound)
            ProgressManager.saveProgress()

            if RoundManager.gameHasMoreRounds() then
                -- Advance to next round
                local nextConfig = RoundManager.advanceToNextRound()
                -- The handleRoundStarted event will be triggered automatically
            else
                -- All rounds completed
                GameModel.setGameEnded(true)
                ProgressManager.saveProgress()
            end
        end
    end
end

-- Handle animation completion
function GameController.handleAnimationCompleted(animId, animType)
    -- Could add specific logic here if needed
end

