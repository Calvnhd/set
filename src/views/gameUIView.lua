-- Game UI View - Score, deck info, and game end screen

local GameModel = require('models.gameModel')
local DeckModel = require('models.deckModel')

local GameUIView = {}

-- Draw deck info (score and cards remaining)
function GameUIView.drawDeckInfo()
    love.graphics.setColor(1, 1, 1)
    local windowWidth = love.graphics.getWidth()
    local font = love.graphics.newFont(16)
    love.graphics.setFont(font)
    
    -- Display score in top right
    local score = GameModel.getScore()
    local scoreText = "Score: " .. score
    love.graphics.print(scoreText, windowWidth - 250, 20)
    
    -- Display cards remaining
    local cardsRemaining = DeckModel.getCount()
    local infoText = "Cards remaining in deck: " .. cardsRemaining
    love.graphics.print(infoText, windowWidth - 250, 45)
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
    local fontSize = circleRadius / 5
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)

    -- Draw the final score text in black
    love.graphics.setColor(0, 0, 0) -- Black
    local score = GameModel.getScore()
    local scoreText = "Final Score: " .. score

    -- Calculate text dimensions for centering
    local textWidth = font:getWidth(scoreText)
    local textHeight = font:getHeight()

    -- Draw the text centered
    love.graphics.print(scoreText, centerX - textWidth / 2, centerY - textHeight / 2)

    -- Reset font to default
    love.graphics.setFont(love.graphics.newFont(16))
end

-- Draw all UI elements
function GameUIView.draw()
    GameUIView.drawDeckInfo()
    -- Game end screen is drawn last so it appears on top
    if GameModel.hasGameEnded() then
        GameUIView.drawGameEndScreen()
    end
end

return GameUIView
