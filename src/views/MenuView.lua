-- Menu View - Main menu interface
local MenuView = {}

-- required modules
local Logger = require('core.Logger')
local Colors = require('views.Colors')

-----------------
-- UI elements --
-----------------

local classicButton = {
    x = 0,
    y = 0,
    width = 200,
    height = 60,
    text = "Classic Mode",
    color = Colors.MAP.MENU_BUTTONS
}

local rogueButton = {
    x = 0,
    y = 0,
    width = 200,
    height = 60,
    text = "Rogue Mode",
    color = Colors.MAP.MENU_BUTTONS
}

---------------
-- functions --
---------------

-- Initialize menu layout
function MenuView.initialize()
    local windowWidth, windowHeight = love.graphics.getDimensions()

    -- Position buttons vertically centered
    local buttonSpacing = 80
    local totalHeight = 2 * 60 + buttonSpacing -- 2 buttons + spacing
    local startY = windowHeight / 2 - totalHeight / 2

    classicButton.x = windowWidth / 2 - classicButton.width / 2
    classicButton.y = startY

    rogueButton.x = windowWidth / 2 - rogueButton.width / 2
    rogueButton.y = startY + 60 + buttonSpacing
    Logger.trace("MenuView initialized")
end

-- Draw the menu
function MenuView.draw()
    -- Draw the menu background
    love.graphics.clear(Colors.MAP.BACKGROUND)
    -- Set the font for the menu title
    love.graphics.setFont(love.graphics.newFont(32))
    -- Draw the title
    love.graphics.setColor(Colors.MAP.TEXT)
    love.graphics.printf("Welcome to Set!", 0, 100, love.graphics.getWidth(), "center")

    -- Draw the classic mode button
    love.graphics.setColor(classicButton.color)
    love.graphics.rectangle("fill", classicButton.x, classicButton.y, classicButton.width, classicButton.height, 8, 8)

    -- Draw the rogue mode button
    love.graphics.setColor(rogueButton.color)
    love.graphics.rectangle("fill", rogueButton.x, rogueButton.y, rogueButton.width, rogueButton.height, 8, 8)

    -- Set the font for the button text
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.setColor(Colors.MAP.TEXT)

    -- Draw button texts
    love.graphics.printf(classicButton.text, classicButton.x, classicButton.y + 18, classicButton.width, "center")
    love.graphics.printf(rogueButton.text, rogueButton.x, rogueButton.y + 18, rogueButton.width, "center")

    -- Draw mode descriptions
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(Colors.MAP.TEXT)
    love.graphics.printf("Traditional", classicButton.x, classicButton.y + 65, classicButton.width,
        "center")
    love.graphics.printf("Progressive", rogueButton.x, rogueButton.y + 65, rogueButton.width, "center")
end

-- Check if classic mode button was clicked
function MenuView.isClassicButtonClicked(x, y)
    return x >= classicButton.x and x <= classicButton.x + classicButton.width and y >= classicButton.y and y <=
               classicButton.y + classicButton.height
end

-- Check if rogue mode button was clicked
function MenuView.isRogueButtonClicked(x, y)
    return x >= rogueButton.x and x <= rogueButton.x + rogueButton.width and y >= rogueButton.y and y <= rogueButton.y +
               rogueButton.height
end

return MenuView
