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

### State Management Strategy

A robust approach to state management is crucial for this refactoring. I recommend implementing:

1. **Game State Container**: A centralized state container in the `models/gameModel.lua` that will store:
   - Current board state
   - Selected cards
   - Score
   - Deck state
   - Animation states

2. **State Access Patterns**:
   - Controllers should modify state through well-defined methods
   - Views should only read state, never modify it
   - State changes should trigger events for UI updates

3. **Persistent vs. Transient State**:
   - Clearly separate persistent game state (score, cards) from transient UI state (animations, hover effects)
   - Use local state in view components for UI-specific state

This approach will enable better testing, debugging, and extension of game features while maintaining clear data flow.

### Data Flow Architecture

Understanding how data flows through the application is critical for maintaining the separation of concerns:

#### Core Data Flow Pattern:

```
User Input → Controllers → Models (State Update) → Events → Views (Re-render)
```

#### Key Interaction Points:

1. **User Input to Game State**:
   - Input controller receives user actions (clicks, key presses)
   - Controller validates input via rules service
   - Controller updates model state if input is valid
   - State changes trigger events

2. **Game Logic to UI Updates**:
   - Model changes emit events
   - View components subscribe to relevant events
   - Views re-render when state changes
   - No direct model-to-view communication

3. **Scene Transitions**:
   - Controllers determine when scene changes should occur
   - Scene manager handles the actual transition
   - Each scene initializes with required state data

4. **Animation Flow**:
   - Game events trigger animation requests
   - Animation service manages animation state
   - View layer renders based on combined game state and animation state

This unidirectional data flow pattern makes the system more predictable and easier to debug.

### Testing Strategy

Testing is essential for maintaining the stability of the codebase during and after refactoring:

1. **Unit Testing**:
   - Each service and model component should have unit tests
   - The `rulesService` is particularly important to test thoroughly
   - Mock dependencies to isolate components during testing

2. **Integration Testing**:
   - Test interactions between components
   - Ensure events properly propagate through the system
   - Verify state changes correctly affect the UI

3. **Test Framework Recommendation**:
   - Use Busted (Lua testing framework) for unit tests
   - Consider implementing a simple test harness for integration tests

4. **Test Coverage Goals**:
   - 80%+ coverage for model and service layers
   - Focus testing on game logic rather than rendering code

5. **Regression Testing**:
   - Create a test suite that verifies core game functionality remains intact
   - Include tests for edge cases identified in the current implementation

Tests should be implemented alongside the refactoring process, not afterward, to catch issues early.

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

1. **Stage 1: Extract the Scene Management (Week 1)**
   - Create a scene manager and separate scenes for menu, gameplay, and end-game
   - Move the existing UI rendering code into appropriate scene modules
   - Update main.lua to use the scene manager
   - **Migration Focus**: Minimal changes to game logic, primarily restructuring UI flow

2. **Stage 2: Separate Model and View (Week 2)**
   - Extract data structures from rendering code
   - Create dedicated view modules for each UI component
   - Implement basic state container for game data
   - **Migration Focus**: Carefully extract state variables, ensure rendering still works properly

3. **Stage 3: Implement Controllers and Services (Week 3)**
   - Create controllers to handle game logic
   - Extract rules and animations into services
   - Connect controllers to views via basic event system
   - **Migration Focus**: Move complex logic into appropriate services, create clean APIs

4. **Stage 4: Enhance Event System and Refine (Week 4)**
   - Implement a full publisher-subscriber pattern
   - Gradually convert direct function calls to event dispatches
   - Polish architecture and fix any integration issues
   - **Migration Focus**: Complete separation of concerns, ensure all components communicate properly

5. **Stage 5: Testing and Optimization (Week 5)**
   - Implement testing framework
   - Create tests for critical components
   - Optimize performance of new architecture
   - **Migration Focus**: Ensure stability and performance meet or exceed original implementation

Each stage should end with a fully functioning game. This allows for incremental verification and reduces risk during the refactoring process.

### Performance Considerations

While refactoring for maintainability, we must ensure performance remains optimal:

1. **Rendering Optimization**:
   - Implement dirty checking to only re-render views when state changes
   - Use Love2D's SpriteBatch for more efficient card rendering
   - Consider object pooling for animations to reduce garbage collection

2. **Event System Efficiency**:
   - Use targeted events rather than broad broadcasts
   - Implement event debouncing for high-frequency events
   - Allow subscribers to specify priority for critical event handlers

3. **State Update Batching**:
   - Batch related state updates to minimize event triggers
   - Use a predictable update cycle to prevent rendering/logic conflicts
   - Consider implementing a transaction-like pattern for complex state changes

4. **Memory Management**:
   - Implement proper cleanup for scenes when they're exited
   - Use weak references for event listeners to prevent memory leaks
   - Profile memory usage during development to catch issues early

5. **Performance Testing**:
   - Create benchmarks for critical operations (card rendering, set validation)
   - Compare performance metrics before and after refactoring
   - Test on lower-end hardware to ensure broad compatibility

By following these guidelines, the refactored code can achieve better architecture while maintaining or improving runtime performance.

### Animation System Architecture

The current animation system in `card.lua` is complex and tightly coupled with rendering. I recommend:

1. **Animation Service**: Create a dedicated animation service that:
   - Manages animation state separate from card data
   - Provides a standardized interface for creating and updating animations
   - Supports different animation types (burn, flash, move, etc.)

2. **Animation Components**:
   - Create specific components for each animation type that define:
     - Animation timeline
     - Visual properties at each stage
     - Completion callbacks

3. **Rendering Integration**:
   - Animation state should be applied during the view rendering phase
   - The view layer shouldn't know about animation logic, only how to render a card with given visual properties

4. **Event-Based Triggers**:
   - Animations should be triggered via the event system
   - Completion of animations should emit events that other systems can subscribe to

This approach will make the animation system more maintainable and allow for easier addition of new animation types in the future.

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
