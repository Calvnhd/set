-- Menu View - Main menu interface

local MenuView = {}

-- UI elements
local playButton = {
    x = 0,
    y = 0,
    width = 200,
    height = 60,
    text = "Play Game"
}

-- Initialize menu layout
function MenuView.initialize()
    local windowWidth, windowHeight = love.graphics.getDimensions()
    playButton.x = windowWidth / 2 - playButton.width / 2
    playButton.y = windowHeight / 2 - playButton.height / 2
end

-- Draw the menu
function MenuView.draw()
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

-- Check if play button was clicked
function MenuView.isPlayButtonClicked(x, y)
    return x >= playButton.x and x <= playButton.x + playButton.width and
           y >= playButton.y and y <= playButton.y + playButton.height
end

return MenuView
