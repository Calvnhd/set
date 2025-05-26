# Event System Guide

The event system in this LOVE2D game implements a publisher-subscriber pattern that enables loose coupling between different components. This guide explains how the event system works and how to use it effectively.

## Architecture Overview

The event system consists of two main components:

1. **EventManager** (`src/core/eventManager.lua`) - Handles the pub/sub mechanism
2. **Events Registry** (`src/core/events.lua`) - Provides centralized event name constants

## Core Components

### EventManager

The EventManager provides four main functions:

- `subscribe(eventName, callback)` - Register a listener for an event
- `emit(eventName, ...)` - Publish an event to all subscribers
- `unsubscribe(eventName, callback)` - Remove a specific listener
- `clear(eventName)` - Remove all listeners for an event

### Events Registry

The Events registry provides constant strings for all event names, organized by category:

```lua
local Events = require('core.events')

-- Input events
Events.INPUT.KEY_PRESSED       -- 'input:keypressed'
Events.INPUT.MOUSE_PRESSED     -- 'input:mousepressed'

-- Scene events  
Events.SCENE.CHANGE_TO_GAME    -- 'scene:changeToGame'
Events.SCENE.CHANGE_TO_MENU    -- 'scene:changeToMenu'

-- Game events
Events.GAME.PLAYER_SCORED      -- 'game:playerScored'
Events.GAME.GAME_OVER          -- 'game:gameOver'
```

## Basic Usage

### Subscribing to Events

```lua
local EventManager = require('core.eventManager')
local Events = require('core.events')

-- Define a callback function
local function onKeyPressed(key)
    print("Key pressed:", key)
end

-- Subscribe to the event
EventManager.subscribe(Events.INPUT.KEY_PRESSED, onKeyPressed)
```

### Emitting Events

```lua
local EventManager = require('core.eventManager')
local Events = require('core.events')

-- Emit an event with parameters
EventManager.emit(Events.INPUT.KEY_PRESSED, "space")

-- Emit a scene change event
EventManager.emit(Events.SCENE.CHANGE_TO_GAME, "classic")
```

### Unsubscribing from Events

```lua
-- Unsubscribe a specific callback
EventManager.unsubscribe(Events.INPUT.KEY_PRESSED, onKeyPressed)

-- Remove all listeners for an event
EventManager.clear(Events.INPUT.KEY_PRESSED)
```

## Complete Example: Menu Scene Input Handling

Here's how the menu scene uses the event system for input handling:

```lua
local MenuView = require('views.menuView')
local EventManager = require('core.eventManager')
local Events = require('core.events')
local Logger = require('core.logger')

local MenuScene = {}

-- Scene initialization - subscribe to events
function MenuScene.enter()
    Logger.info("Entering menu scene")
    MenuView.initialize()
    
    -- Subscribe to input events
    EventManager.subscribe(Events.INPUT.KEY_PRESSED, MenuScene.keypressed)
    EventManager.subscribe(Events.INPUT.MOUSE_PRESSED, MenuScene.mousepressed)
    
    Logger.trace("Menu scene subscribed to input events")
end

-- Scene cleanup - unsubscribe from events
function MenuScene.exit()
    Logger.info("Exiting menu scene")
    
    -- Unsubscribe from events to prevent memory leaks
    EventManager.unsubscribe(Events.INPUT.KEY_PRESSED, MenuScene.keypressed)
    EventManager.unsubscribe(Events.INPUT.MOUSE_PRESSED, MenuScene.mousepressed)
    
    Logger.trace("Menu scene unsubscribed from input events")
end

-- Handle keyboard input events
function MenuScene.keypressed(key)
    Logger.trace("Menu scene handling key: %s", key)
    if key == "escape" then
        Logger.info("Escape key pressed - quitting game")
        love.event.quit()
    end
end

-- Handle mouse press events
function MenuScene.mousepressed(x, y, button)
    Logger.trace("Menu scene handling mouse press: (%d, %d) button %d", x, y, button)
    
    if button == 1 then -- Left mouse button
        if MenuView.isClassicButtonClicked(x, y) then
            Logger.info("Classic mode button clicked")
            -- Emit scene change event
            EventManager.emit(Events.SCENE.CHANGE_TO_GAME, 'classic')
        elseif MenuView.isRogueButtonClicked(x, y) then
            Logger.info("Rogue mode button clicked")
            EventManager.emit(Events.SCENE.CHANGE_TO_GAME, 'rogue')
        end
    end
end

return MenuScene
```

## Event Flow Example

Let's trace how a mouse click flows through the system:

### 1. Input Capture
```lua
-- In main.lua - Love2D callback
function love.mousepressed(x, y, button)
    InputController.mousepressed(x, y, button)
end
```

### 2. Event Emission
```lua
-- In InputController
function InputController.mousepressed(x, y, button)
    EventManager.emit(Events.INPUT.MOUSE_PRESSED, x, y, button)
end
```

### 3. Event Distribution
The EventManager automatically calls all subscribed callbacks:
- `MenuScene.mousepressed(x, y, button)` gets called
- Any other components listening to `Events.INPUT.MOUSE_PRESSED` also get called

### 4. Event Handling
```lua
-- In MenuScene
function MenuScene.mousepressed(x, y, button)
    if button == 1 and MenuView.isClassicButtonClicked(x, y) then
        -- Emit a new event for scene change
        EventManager.emit(Events.SCENE.CHANGE_TO_GAME, 'classic')
    end
end
```

### 5. Scene Transition
```lua
-- In main.lua - listening for scene changes
EventManager.subscribe(Events.SCENE.CHANGE_TO_GAME, function(gameMode)
    SceneManager.changeScene('game', gameMode)
end)
```

## Event Categories and Naming Conventions

Events follow a **namespace:action** pattern:

### Input Events (`Events.INPUT.*`)
- `KEY_PRESSED` - Keyboard input from Love2D callbacks
- `MOUSE_PRESSED` - Mouse button press events
- `MOUSE_RELEASED` - Mouse button release events
- `MOUSE_MOVED` - Mouse movement events

### Scene Events (`Events.SCENE.*`)
- `CHANGE_TO_GAME` - Request transition to game scene with mode parameter
- `CHANGE_TO_MENU` - Request transition to menu scene
- `PAUSE` - Request to pause current scene
- `RESUME` - Request to resume paused scene

### Game Events (`Events.GAME.*`)
- `PLAYER_SCORED` - Player achieved points
- `GAME_OVER` - Game session ended
- `LEVEL_COMPLETE` - Current level finished
- `PAUSE_REQUESTED` - Player requested game pause
- `ROUND_COMPLETE` - Current round finished
- `CARD_SELECTED` - Player selected a card
- `SET_FOUND` - Valid set was identified
- `REQUEST_MENU_TRANSITION` - Game requesting return to menu

## Best Practices

### 1. Always Use the Events Registry
```lua
-- Good
EventManager.emit(Events.SCENE.CHANGE_TO_GAME, 'classic')

-- Bad - typos cause silent failures
EventManager.emit('scene:changeToGaem', 'classic')
```

### 2. Clean Up Subscriptions
Always unsubscribe in cleanup functions to prevent memory leaks:

```lua
function SomeComponent.cleanup()
    EventManager.unsubscribe(Events.INPUT.KEY_PRESSED, SomeComponent.onKeyPressed)
end
```

### 3. Use Descriptive Parameter Names
```lua
-- Good
EventManager.emit(Events.GAME.PLAYER_SCORED, playerName, points, bCombo)

-- Less clear
EventManager.emit(Events.GAME.PLAYER_SCORED, p, pts, c)
```

### 4. Document Event Parameters
When adding new events to the registry, document expected parameters:

```lua
-- Game events
GAME = {
    -- Emitted when player scores points
    -- Parameters: playerName (string), points (number), bCombo (boolean)
    PLAYER_SCORED = 'game:playerScored',
}
```

## Adding New Events

To add a new event:

1. **Add to Events Registry**:
```lua
-- In src/core/events.lua
GAME = {
    -- ...existing events...
    POWER_UP_COLLECTED = 'game:powerUpCollected'
}
```

2. **Emit the Event**:
```lua
-- In game logic
EventManager.emit(Events.GAME.POWER_UP_COLLECTED, powerUpType, playerName)
```

3. **Subscribe to Handle**:
```lua
-- In interested components
EventManager.subscribe(Events.GAME.POWER_UP_COLLECTED, handlePowerUp)

function handlePowerUp(powerUpType, playerName)
    -- Handle the power-up collection
end
```

## Dual Input Handling Pattern

The system implements two parallel input paths:

1. **Event-based**: `InputController` → `EventManager` → Scene handlers
2. **Direct delegation**: `SceneManager` → Current scene

```lua
-- In main.lua - both paths are used
function love.mousepressed(x, y, button)
    InputController.mousepressed(x, y, button)  -- Event path
    SceneManager.mousepressed(x, y, button)     -- Direct path
end
```

This provides flexibility - some components prefer events (loose coupling) while others use direct calls (immediate response).

## Benefits

- **Loose Coupling**: Components don't need direct references to each other
- **Flexibility**: Multiple components can listen to the same event
- **Maintainability**: Centralized event names prevent typos and improve refactoring
- **Testability**: Events can be emitted directly for testing purposes
- **Extensibility**: New features can easily hook into existing events

## Common Patterns

### Scene Transitions
```lua
-- Request scene change
EventManager.emit(Events.SCENE.CHANGE_TO_GAME, gameMode)

-- Handle scene change
EventManager.subscribe(Events.SCENE.CHANGE_TO_GAME, function(gameMode)
    SceneManager.changeScene('game', gameMode)
end)
```

### Game State Changes
```lua
-- Notify of game over
EventManager.emit(Events.GAME.GAME_OVER, finalScore, bNewHighScore)

-- Multiple systems can respond
EventManager.subscribe(Events.GAME.GAME_OVER, UIManager.showGameOverScreen)
EventManager.subscribe(Events.GAME.GAME_OVER, SaveManager.saveScore)
EventManager.subscribe(Events.GAME.GAME_OVER, SoundManager.playGameOverSound)
```

This event system provides a robust foundation for component communication while maintaining clean, maintainable code.
