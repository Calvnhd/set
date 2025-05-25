# Refactoring Code for Maintainability and Re-use

## Current code-base structure

The Set game codebase is structured in a modular fashion with three primary Lua modules:

1. **main.lua** - The entry point for the Love2D framework, handling callbacks from the game engine to the main game module.
2. **game.lua** - Contains the core game logic, state management, and all UI rendering. Currently a monolithic module that handles multiple concerns.
3. **deck.lua** - Manages the deck of cards with creation, shuffling and card handling.
4. **card.lua** - Responsible for card creation, rendering, selection state and animations.

The code follows a procedural programming style with modules acting as namespaces for related functions. State is managed using local variables in each module, with most of the game state residing in game.lua.

## Potential issues

The current codebase, while functional, has several areas that could be improved for maintainability and extensibility. The main concerns are:

1. **Monolithic game.lua module**: This file is nearly 700 lines long and handles too many responsibilities, from state management to UI rendering to game logic.
2. **Tight coupling**: The modules are tightly integrated, making it difficult to modify one part of the system without affecting others.
3. **Mixed concerns**: UI rendering, game logic, and state management are often intermingled in the same functions.
4. **Limited state management**: The current approach uses local variables for state, which doesn't scale well for complex games.
5. **No clear separation of game rules and game UI**: The rules of the game (what makes a valid set) are mixed with the UI code.

### List of problems
#### Monolithic game.lua module
- **Issue:** Large file that's difficult to navigate and maintain
- **Severity:** High
- **Suggested Fix:** Split into multiple smaller, focused modules

#### Tight coupling between modules
- **Issue:** Makes changes and extensions difficult, increasing risk of bugs
- **Severity:** High
- **Suggested Fix:** Introduce clearer interfaces between modules

#### Mixed concerns (rendering, logic, state)
- **Issue:** Leads to changes in one area affecting others, creates cognitive load
- **Severity:** Medium
- **Suggested Fix:** Separate concerns using a more structured architecture

#### Limited state management
- **Issue:** Doesn't scale well for more complex state transitions
- **Severity:** Medium
- **Suggested Fix:** Implement a more robust state management system

#### No separation of rules and UI
- **Issue:** Makes it difficult to change game rules or UI independently
- **Severity:** Medium
- **Suggested Fix:** Extract game rules into a separate module

## Suggested improvements

I recommend refactoring the codebase using a combination of architectural patterns that will provide better separation of concerns, improved maintainability, and easier extensibility for future features.

### Table of changes
#### Implement a State Machine pattern
- **Description:** Create a formal state machine with defined transitions between game states
- **Intended Outcome:** Makes game flow clearer, easier to add new states
- **Priority:** High

#### Apply Model-View-Controller (MVC) pattern
- **Description:** Separate data (Model), presentation (View), and logic (Controller)
- **Intended Outcome:** Allows independent development and testing of each component
- **Priority:** High

#### Create a Scene Manager
- **Description:** Handle different scenes (menu, game, end screen) separately
- **Intended Outcome:** Enables easy addition of new screens and transitions
- **Priority:** High

#### Extract Game Rules to a Rules Service
- **Description:** Move Set game rules to a dedicated module
- **Intended Outcome:** Makes rule modifications isolated and testable
- **Priority:** Medium

#### Implement an Event System
- **Description:** Create a publisher-subscriber pattern for game events
- **Intended Outcome:** Reduces direct dependencies between modules
- **Priority:** Medium

## Additional comments

### Proposed Directory Structure

```
src/
  main.lua                   # Entry point
  conf.lua                   # LÖVE configuration
  assets/                    # Images and other assets
  scenes/                    # Different game scenes
    menuScene.lua            # Main menu
    gameScene.lua            # Gameplay scene
    endGameScene.lua         # End game scene
  core/                      # Core functionality
    sceneManager.lua         # Manages scene transitions
    stateMachine.lua         # State machine implementation
    eventManager.lua         # Event system
  models/                    # Data models
    cardModel.lua            # Card data structure
    deckModel.lua            # Deck operations
    gameModel.lua            # Game state
  views/                     # UI rendering
    cardView.lua             # Card rendering
    boardView.lua            # Board rendering
    menuView.lua             # Menu rendering
  controllers/               # Game logic
    gameController.lua       # Main game logic
    inputController.lua      # Input handling
  services/                  # Game services
    rulesService.lua         # Game rules
    animationService.lua     # Animation handling
```

### Implementation Strategy

I recommend implementing the refactoring in stages:

1. **Stage 1: Extract the Scene Management**
   - Create a scene manager and separate scenes for menu, gameplay, and end-game
   - This provides an immediate architectural improvement with minimal risk

2. **Stage 2: Separate Model and View**
   - Extract data structures from rendering code
   - Create dedicated view modules for each UI component

3. **Stage 3: Implement Controllers and Services**
   - Create controllers to handle game logic
   - Extract rules and animations into services

4. **Stage 4: Add Event System**
   - Implement a simple publisher-subscriber pattern
   - Gradually convert direct function calls to event dispatches

This phased approach allows for incremental improvement while maintaining a functioning game at each stage.

## Code snippets

### Example Scene Manager Implementation

```lua
-- sceneManager.lua
local SceneManager = {}
local currentScene = nil

function SceneManager.changeScene(newScene)
    if currentScene and currentScene.exit then
        currentScene.exit()
    end
    
    currentScene = newScene
    
    if currentScene and currentScene.enter then
        currentScene.enter()
    end
end

function SceneManager.update(dt)
    if currentScene and currentScene.update then
        currentScene.update(dt)
    end
end

function SceneManager.draw()
    if currentScene and currentScene.draw then
        currentScene.draw()
    end
end

function SceneManager.keypressed(key)
    if currentScene and currentScene.keypressed then
        currentScene.keypressed(key)
    end
end

function SceneManager.mousepressed(x, y, button)
    if currentScene and currentScene.mousepressed then
        currentScene.mousepressed(x, y, button)
    end
end

return SceneManager
```

### Example Scene Implementation

```lua
-- menuScene.lua
local MenuScene = {}

-- UI elements
local playButton = {
    x = 0,
    y = 0,
    width = 200,
    height = 60,
    text = "Play Game"
}

function MenuScene.enter()
    -- Center the play button
    local windowWidth, windowHeight = love.graphics.getDimensions()
    playButton.x = windowWidth / 2 - playButton.width / 2
    playButton.y = windowHeight / 2 - playButton.height / 2
end

function MenuScene.update(dt)
    -- Menu animations or logic would go here
end

function MenuScene.draw()
    -- Draw the menu background
    love.graphics.clear(0.34, 0.45, 0.47)
    
    -- Set the font for the menu title
    love.graphics.setFont(love.graphics.newFont(32))
    
    -- Draw the title
    love.graphics.setColor(1, 1, 1) -- White
    love.graphics.printf("Welcome to the Set Game!", 0, 100, love.graphics.getWidth(), "center")
    
    -- Draw the play button
    love.graphics.setColor(0.2, 0.6, 0.2) -- Green
    love.graphics.rectangle("fill", playButton.x, playButton.y, playButton.width, playButton.height, 8, 8)
    
    -- Set the font for the button text
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.setColor(1, 1, 1) -- White
    love.graphics.printf(playButton.text, playButton.x, playButton.y + 15, playButton.width, "center")
end

function MenuScene.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function MenuScene.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        -- Check if play button was clicked
        if x >= playButton.x and x <= playButton.x + playButton.width and
           y >= playButton.y and y <= playButton.y + playButton.height then
            -- Change to the game scene
            local gameScene = require('scenes.gameScene')
            local SceneManager = require('core.sceneManager')
            SceneManager.changeScene(gameScene)
        end
    end
end

return MenuScene
```
