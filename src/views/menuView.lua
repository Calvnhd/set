-- Menu View - Main menu interface

local MenuView = {}

-- UI elements
local classicButton = {
    x = 0,
    y = 0,
    width = 200,
    height = 60,
    text = "Classic Mode"
}

local rogueButton = {
    x = 0,
    y = 0,
    width = 200,
    height = 60,
    text = "Rogue Mode"
}

-- Initialize menu layout
function MenuView.initialize()
    local windowWidth, windowHeight = love.graphics.getDimensions()
    
    -- Position buttons vertically centered
    local buttonSpacing = 80
    local totalHeight = 2 * 60 + buttonSpacing  -- 2 buttons + spacing
    local startY = windowHeight / 2 - totalHeight / 2
    
    classicButton.x = windowWidth / 2 - classicButton.width / 2
    classicButton.y = startY
    
    rogueButton.x = windowWidth / 2 - rogueButton.width / 2
    rogueButton.y = startY + 60 + buttonSpacing
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

    -- Draw the classic mode button
    love.graphics.setColor(0.2, 0.6, 0.2) -- Green
    love.graphics.rectangle("fill", classicButton.x, classicButton.y, classicButton.width, classicButton.height, 8, 8)

    -- Draw the rogue mode button
    love.graphics.setColor(0.6, 0.2, 0.6) -- Purple
    love.graphics.rectangle("fill", rogueButton.x, rogueButton.y, rogueButton.width, rogueButton.height, 8, 8)

    -- Set the font for the button text
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.setColor(1, 1, 1) -- White
    
    -- Draw button texts
    love.graphics.printf(classicButton.text, classicButton.x, classicButton.y + 18, classicButton.width, "center")
    love.graphics.printf(rogueButton.text, rogueButton.x, rogueButton.y + 18, rogueButton.width, "center")
    
    -- Draw mode descriptions
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(0.8, 0.8, 0.8) -- Light gray
    love.graphics.printf("Traditional Set with all cards", classicButton.x, classicButton.y + 65, classicButton.width, "center")
    love.graphics.printf("Progressive tutorial mode", rogueButton.x, rogueButton.y + 65, rogueButton.width, "center")
end

-- Check if classic mode button was clicked
function MenuView.isClassicButtonClicked(x, y)
    return x >= classicButton.x and x <= classicButton.x + classicButton.width and
           y >= classicButton.y and y <= classicButton.y + classicButton.height
end

-- Check if rogue mode button was clicked
function MenuView.isRogueButtonClicked(x, y)
    return x >= rogueButton.x and x <= rogueButton.x + rogueButton.width and
           y >= rogueButton.y and y <= rogueButton.y + rogueButton.height
end

-- Legacy function for backward compatibility
function MenuView.isPlayButtonClicked(x, y)
    return MenuView.isClassicButtonClicked(x, y)
end

return MenuView
