local BoardView = require('views.BoardView')
local GameUIView = require('views.GameUIView')
local GameController = require('controllers.GameController')
local AnimationService = require('services.AnimationService')

-- Enter the game scene
function GameScene.enter(gameMode)
   
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
