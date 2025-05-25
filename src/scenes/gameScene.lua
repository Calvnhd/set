-- Game Scene - Main gameplay scene with full game functionality

local BoardView = require('views.boardView')
local GameUIView = require('views.gameUIView')
local CardView = require('views.cardView')
local GameController = require('controllers.gameController')
local AnimationService = require('services.animationService')
local EventManager = require('core.eventManager')

local GameScene = {}

-- Enter the game scene
function GameScene.enter(gameMode)
    -- Load card images
    CardView.loadImages()
    
    -- Initialize game controller
    GameController.initialize()
    
    -- Setup new game with specified mode
    GameController.setupNewGame(gameMode)
    
    -- Subscribe to scene transition events
    EventManager.subscribe('game:requestMenuTransition', GameScene.handleMenuTransition)
end

-- Exit the game scene
function GameScene.exit()
    -- Unsubscribe from events
    EventManager.unsubscribe('game:requestMenuTransition', GameScene.handleMenuTransition)
    
    -- Clear any remaining animations
    AnimationService.clearAll()
end

-- Update game state
function GameScene.update(dt)
    AnimationService.update(dt)
end

-- Draw the game
function GameScene.draw()
    -- Set background color
    love.graphics.setBackgroundColor(0.34, 0.45, 0.47)
    
    -- Draw board
    BoardView.draw()
    
    -- Draw animations
    GameScene.drawAnimations()
    
    -- Draw UI elements
    GameUIView.draw()
end

-- Draw all active animations
function GameScene.drawAnimations()
    local animations = AnimationService.getAnimations()
    
    for _, anim in ipairs(animations) do
        if anim.type == "burn" then
            CardView.drawBurningCard(anim)
        elseif anim.type == "flashRed" then
            CardView.drawFlashingRedCard(anim)
        end
    end
end

-- Handle request to transition back to menu
function GameScene.handleMenuTransition()
    EventManager.emit('scene:changeToMenu')
end

return GameScene
