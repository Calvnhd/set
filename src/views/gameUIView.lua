-- Game UI View - Score, deck info, and game end screen

local GameModel = require('models.gameModel')
local GameModeModel = require('models.gameModeModel')
local DeckModel = require('models.deckModel')
local RoundManager = require('services.roundManager')

local GameUIView = {}

-- Draw deck info (score and cards remaining)
function GameUIView.drawDeckInfo()
    love.graphics.setColor(1, 1, 1)
    local windowWidth = love.graphics.getWidth()
    local font = love.graphics.newFont(16)
    love.graphics.setFont(font)
    
    local yOffset = 20
    local lineHeight = 25
    
    -- Display score in top right
    local score = GameModel.getScore()
    local scoreText = "Score: " .. score
    love.graphics.print(scoreText, windowWidth - 250, yOffset)
    yOffset = yOffset + lineHeight
    
    -- Display cards remaining
    local cardsRemaining = DeckModel.getCount()
    local infoText = "Cards remaining: " .. cardsRemaining
    love.graphics.print(infoText, windowWidth - 250, yOffset)
    yOffset = yOffset + lineHeight
    
    -- Display rogue mode specific information
    if GameModeModel.bIsRogueMode() then
        GameUIView.drawRogueInfo(windowWidth - 250, yOffset)
    end
end

-- Draw rogue mode specific information
function GameUIView.drawRogueInfo(x, y)
    local font = love.graphics.newFont(16)
    love.graphics.setFont(font)
    local lineHeight = 25
    
    -- Get round progress
    local progress = RoundManager.getRoundProgress()
    local config = RoundManager.getCurrentRoundConfig()
    
    if progress and config then
        -- Round information
        local roundText = string.format("Round: %d/%d", progress.currentRound, progress.totalRounds)
        love.graphics.print(roundText, x, y)
        y = y + lineHeight
        
        -- Round name
        local nameText = progress.roundName
        love.graphics.print(nameText, x, y)
        y = y + lineHeight
        
        -- Current set size
        local setSize = GameModel.getCurrentSetSize()
        local setSizeText = "Set size: " .. setSize
        love.graphics.print(setSizeText, x, y)
        y = y + lineHeight
        
        -- Sets found in current round
        local setsFound = GameModel.getSetsFound()
        local setsText = "Sets found: " .. setsFound
        love.graphics.print(setsText, x, y)
        y = y + lineHeight
        
        -- End condition progress
        if config.endCondition then
            GameUIView.drawEndConditionProgress(config.endCondition, x, y)
        end
    end
end

-- Draw end condition progress
function GameUIView.drawEndConditionProgress(endCondition, x, y)
    local font = love.graphics.newFont(16)
    love.graphics.setFont(font)
    
    if endCondition.type == "score" then
        local currentScore = GameModel.getScore()
        local targetScore = endCondition.target
        local progressText = string.format("Target Score: %d/%d", currentScore, targetScore)
        love.graphics.print(progressText, x, y)
    elseif endCondition.type == "sets" then
        local currentSets = GameModel.getSetsFound()
        local targetSets = endCondition.target
        local progressText = string.format("Target Sets: %d/%d", currentSets, targetSets)
        love.graphics.print(progressText, x, y)
    end
end

-- Draw the game end screen with final score
function GameUIView.drawGameEndScreen()
    if not GameModel.hasGameEnded() then
        return
    end
    
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local circleRadius = math.min(windowWidth, windowHeight) * 0.4
    local centerX, centerY = windowWidth / 2, windowHeight / 2

    -- Draw a big yellow circle
    love.graphics.setColor(1, 1, 0) -- Yellow
    love.graphics.circle("fill", centerX, centerY, circleRadius)

    -- Create a larger font for the score text
    local fontSize = circleRadius / 6
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)

    -- Draw the final score text in black
    love.graphics.setColor(0, 0, 0) -- Black
    local score = GameModel.getScore()
    
    -- Different text for different modes
    local titleText, scoreText
    if GameModeModel.bIsRogueMode() then
        local progress = RoundManager.getRoundProgress()
        titleText = "Rogue Mode Complete!"
        scoreText = "Final Score: " .. score
    else
        titleText = "Game Over!"
        scoreText = "Final Score: " .. score
    end

    -- Calculate text dimensions for centering
    local titleWidth = font:getWidth(titleText)
    local scoreWidth = font:getWidth(scoreText)
    local textHeight = font:getHeight()

    -- Draw the texts centered
    love.graphics.print(titleText, centerX - titleWidth / 2, centerY - textHeight)
    love.graphics.print(scoreText, centerX - scoreWidth / 2, centerY)
    
    -- Add instruction text
    local instructionFont = love.graphics.newFont(fontSize * 0.4)
    love.graphics.setFont(instructionFont)
    local instructionText = "Press SPACE to play again or ESC for menu"
    local instructionWidth = instructionFont:getWidth(instructionText)
    love.graphics.print(instructionText, centerX - instructionWidth / 2, centerY + textHeight * 1.5)

    -- Reset font to default
    love.graphics.setFont(love.graphics.newFont(16))
end

-- Draw round transition screen (for rogue mode)
function GameUIView.drawRoundTransition()
    if not GameModeModel.bIsRogueMode() then
        return
    end
    
    local progress = RoundManager.getRoundProgress()
    if not progress then
        return
    end
    
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local centerX, centerY = windowWidth / 2, windowHeight / 2
    
    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
    
    -- White background for text
    local boxWidth, boxHeight = windowWidth * 0.6, windowHeight * 0.4
    local boxX, boxY = centerX - boxWidth / 2, centerY - boxHeight / 2
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 10, 10)
    
    -- Round transition text
    love.graphics.setColor(0, 0, 0)
    local font = love.graphics.newFont(24)
    love.graphics.setFont(font)
    
    local roundText = string.format("Round %d Complete!", progress.currentRound - 1)
    local nextRoundText = string.format("Starting Round %d: %s", progress.currentRound, progress.roundName)
    
    local textWidth1 = font:getWidth(roundText)
    local textWidth2 = font:getWidth(nextRoundText)
    local textHeight = font:getHeight()
    
    love.graphics.print(roundText, centerX - textWidth1 / 2, centerY - textHeight)
    love.graphics.print(nextRoundText, centerX - textWidth2 / 2, centerY + textHeight / 2)
    
    -- Reset to default font
    love.graphics.setFont(love.graphics.newFont(16))
end

-- Draw all UI elements
function GameUIView.draw()
    GameUIView.drawDeckInfo()
    -- Game end screen is drawn last so it appears on top
    if GameModel.hasGameEnded() then
        GameUIView.drawGameEndScreen()
    end
    -- Note: Round transition screen would be handled by a separate state/scene
end

return GameUIView
