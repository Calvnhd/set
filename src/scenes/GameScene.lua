-- Game Scene - Main gameplay scene with full game functionality
local GameScene = {}

-- required modules
local EventManager = require('core.EventManager')
local Events = require('config.EventRegistry')
local Logger = require('core.Logger')
local GameController = require('controllers.GameController')
local CardView = require('views.CardView')
local GameUIView = require('views.GameUIView')
local BoardView = require('views.BoardView')
local Colors = require('config.ColorRegistry')

---------------
-- functions --
---------------

function GameScene.enter(gameMode)
    Logger.info("Entering game scene")
    if not gameMode then
        Logger.error("No gameMode specified")
        error("No gameMode specified")
    end
    Logger.info("Loading gameMode " .. gameMode)
    -- Initialize game controller
    GameController.initialize()
    -- Setup new game with specified mode
    GameController.setUpNewGame(gameMode)
end

function GameScene.exit()
    Logger.info("Exiting game scene")
end

-- Draw the game
function GameScene.draw()
    -- Set background color
    love.graphics.setBackgroundColor(Colors.MAP.BACKGROUND)
    -- Draw board
    BoardView.draw()
    -- Draw animations
    GameScene.drawAnimations()
    -- Draw UI elements
    GameUIView.draw()
end

function GameScene.drawAnimations()
end

function GameScene.onKeyPressed(key)
    Logger.trace("Game scene handling key: %s", key)
    if key == "escape" then
        love.event.quit()
    end
end

return GameScene
