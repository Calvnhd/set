-- Event Registry - Centralized event name constants
-- This module provides a single source of truth for all event names used throughout the application

local Events = {
    -- Input-related events from InputController
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
        REQUEST_MENU_TRANSITION = 'game:requestMenuTransition',
        RESET = 'game:reset',
        SET_SIZE_CHANGED = 'game:setSizeChanged',
        CARD_DISCARDED = 'game:cardDiscarded',
        SETS_FOUND_CHANGED = 'game:setsFoundChanged',
        SETS_FOUND_RESET = 'game:setsFoundReset',
        ENDED = 'game:ended'
    },
    
    -- Card-related events
    CARD = {
        SELECTION_CHANGED = 'card:selectionChanged'
    },
    
    -- Cards (plural) events
    CARDS = {
        DESELECTED = 'cards:deselected',
        ALL_DESELECTED = 'cards:allDeselected'
    },
    
    -- Deck-related events
    DECK = {
        CREATED = 'deck:created',
        SHUFFLED = 'deck:shuffled',
        CARD_TAKEN = 'deck:cardTaken',
        EMPTY = 'deck:empty',
        CARD_RETURNED = 'deck:cardReturned'
    },
    
    -- Board-related events
    BOARD = {
        SIZE_CHANGED = 'board:sizeChanged',
        CARD_PLACED = 'board:cardPlaced',
        CARD_REMOVED = 'board:cardRemoved'
    },
    
    -- Score-related events
    SCORE = {
        CHANGED = 'score:changed'
    },
    
    -- Hint-related events
    HINT = {
        CHANGED = 'hint:changed'
    },
    
    -- Game Mode events
    GAME_MODE = {
        INITIALIZED = 'gameMode:initialized',
        CHANGED = 'gameMode:changed',
        CONFIG_CHANGED = 'gameMode:configChanged',
        ROUND_INDEX_CHANGED = 'gameMode:roundIndexChanged'
    },
    
    -- Animation events
    ANIMATION = {
        COMPLETED = 'animation:completed',
        STARTED = 'animation:started'
    },
    
    -- Animations (plural) events
    ANIMATIONS = {
        CLEARED = 'animations:cleared'
    },
    
    -- Progress Manager events
    PROGRESS_MANAGER = {
        INITIALIZED = 'progressManager:initialized',
        PROGRESS_SAVED = 'progressManager:progressSaved',
        SAVE_FAILED = 'progressManager:saveFailed',
        PROGRESS_LOADED = 'progressManager:progressLoaded',
        PROGRESS_APPLIED = 'progressManager:progressApplied',
        ROUND_COMPLETED = 'progressManager:roundCompleted',
        PROGRESS_RESET = 'progressManager:progressReset',
        PROGRESS_DELETED = 'progressManager:progressDeleted'
    },
    
    -- Round Manager events
    ROUND_MANAGER = {
        INITIALIZED = 'roundManager:initialized',
        DEFINITIONS_LOADED = 'roundManager:definitionsLoaded',
        ROUND_STARTED = 'roundManager:roundStarted',
        ALL_ROUNDS_COMPLETE = 'roundManager:allRoundsComplete',
        RESET = 'roundManager:reset'
    }
}

return Events
