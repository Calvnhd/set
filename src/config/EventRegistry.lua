-- Event Registry - Centralized event name constants
-- This module provides a single source of truth for all event names used throughout the application
local EventRegistry = {
    -- Input-related events from InputController
    INPUT = {},
    -- Scene management events
    SCENE = {
        CHANGE_TO_GAME = 'scene:changeToGame',
        CHANGE_TO_MENU = 'scene:changeToMenu'
    },
    -- Game-related events
    GAME = {},
    -- Deck-related events
    DECK = {},
    -- Board-related events
    BOARD = {},
    -- Score-related events
    SCORE = {},
    -- Hint-related events
    HINT = {},
    -- Game Mode events
    GAME_MODE = {},
    -- Animation events
    ANIMATION = {},
    -- Progress Manager events
    PROGRESS_MANAGER = {},
    -- Round Manager events
    ROUND_MANAGER = {}
}
return EventRegistry
