-- Event Registry - Centralized event name constants
-- This module provides a single source of truth for all event names used throughout the application

local Events = {    -- Input-related events from InputController
    INPUT = {
        KEY_PRESSED = 'input:keypressed',
        MOUSE_PRESSED = 'input:mousepressed',
        MOUSE_RELEASED = 'input:mousereleased',
        MOUSE_MOVED = 'input:mousemoved'
    },
    
    -- Scene management events
    SCENE = {
        CHANGE_TO_GAME = 'scene:changeToGame',
        CHANGE_TO_MENU = 'scene:changeToMenu',
        PAUSE = 'scene:pause',
        RESUME = 'scene:resume'
    },
      -- Game-related events
    GAME = {
        PLAYER_SCORED = 'game:playerScored',
        GAME_OVER = 'game:gameOver',
        LEVEL_COMPLETE = 'game:levelComplete',
        PAUSE_REQUESTED = 'game:pauseRequested',
        ROUND_COMPLETE = 'game:roundComplete',
        CARD_SELECTED = 'game:cardSelected',
        SET_FOUND = 'game:setFound',
        REQUEST_MENU_TRANSITION = 'game:requestMenuTransition'
    }
}

return Events
