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
