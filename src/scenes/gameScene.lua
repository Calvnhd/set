local BoardView = require('views.boardView')
local GameUIView = require('views.gameUIView')
local CardView = require('views.cardView')
local GameController = require('controllers.gameController')
local AnimationService = require('services.animationService')

-- Enter the game scene
function GameScene.enter(gameMode)
    -- Load card images
    CardView.loadImages()
    -- Subscribe to scene transition events
    EventManager.subscribe(Events.GAME.REQUEST_MENU_TRANSITION, GameScene.handleMenuTransition)
end

-- Exit the game scene
function GameScene.exit()
    -- Unsubscribe from events
    EventManager.unsubscribe(Events.GAME.REQUEST_MENU_TRANSITION, GameScene.handleMenuTransition)
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
    EventManager.emit(Events.SCENE.CHANGE_TO_MENU)
end
