
# Rogue Mode Implementation Guide

## Overview

Rogue Mode is a progressive game mode for the Set card game that introduces players to the game through a series of increasingly complex rounds. Each round has customizable attributes, board layouts, set sizes, and completion conditions.

## Architecture

### Core Components

#### 1. Game Mode Management
- **GameModeModel** (`models/gameModeModel.lua`): Tracks current game mode and round state
- **RoundManager** (`services/roundManager.lua`): Manages round progression and configuration
- **ProgressManager** (`services/progressManager.lua`): Handles save/load of player progress

#### 2. Dynamic Game Rules
- **RulesService** (`services/rulesService.lua`): Extended to support variable set sizes (2, 3, 4+ cards)
- **DeckModel** (`models/deckModel.lua`): Enhanced to generate decks from attribute specifications
- **GameModel** (`models/gameModel.lua`): Modified to support dynamic board sizes and round tracking

#### 3. Configuration System
- **ConfigValidator** (`services/configValidator.lua`): Validates round configurations
- **roundDefinitions.lua** (`config/roundDefinitions.lua`): Round configuration storage

### Key Features

#### Round-Based Progression
- Sequential rounds with increasing complexity
- Each round has specific learning objectives
- Automatic progression based on completion criteria
- Progress saving and loading

#### Customizable Game Parameters
- **Attributes**: Subset of card attributes (number, color, shape, fill)
- **Set Size**: Variable set sizes (2, 3, or 4 cards)
- **Board Layout**: Dynamic board dimensions
- **Scoring**: Configurable point values
- **End Conditions**: Score-based or sets-based completion

#### Dynamic UI
- Round information display
- Progress tracking
- Mode-specific game end screens
- Real-time completion progress

## Round Configuration Format

```lua
{
    id = "unique_round_id",
    name = "Round Display Name",
    attributes = {
        number = {1, 2},  -- Available values for number attribute
        color = {"green", "blue", "red"},  -- Available colors
        shape = {"diamond"},  -- Available shapes
        fill = {"empty", "solid"}  -- Available fill types
    },
    setSize = 2,  -- Required cards per set
    boardSize = {columns = 3, rows = 2},  -- Board layout
    scoring = {
        validSet = 1,
        invalidSet = -1,
        noSetCorrect = 1,
        noSetIncorrect = -1
    },
    endCondition = {
        type = "score",  -- "score" or "sets"
        target = 5
    }
}
```

## Implementation Details

### Event System Integration
The rogue mode uses the existing event system for loose coupling:

- `roundManager:roundStarted` - Emitted when a new round begins
- `roundManager:allRoundsComplete` - Emitted when all rounds are finished
- `gameMode:changed` - Emitted when switching between Classic/Rogue modes
- `progressManager:progressSaved` - Emitted when progress is saved

### Backward Compatibility
- Classic mode remains completely unchanged
- All existing game mechanics work identically in Classic mode
- Rogue mode is additive - no breaking changes to existing code

### Performance Considerations
- Round configurations are validated once at startup
- Progress is saved only at round completion (not continuously)
- Dynamic board sizing is optimized for typical round sizes (2x2 to 4x3)

## Adding New Rounds

1. **Define Configuration**: Add a new round object to `roundDefinitions.lua`
2. **Validate**: The system automatically validates configurations on startup
3. **Test**: Use the configuration validator to ensure correctness
4. **Deploy**: Rounds are loaded dynamically, no code changes needed

### Example: Adding a New Round

```lua
-- In config/roundDefinitions.lua
{
    id = "advanced_4card_sets",
    name = "Master Challenge",
    attributes = {
        number = {1, 2, 3},
        color = {"red", "green", "blue"},
        shape = {"diamond", "oval", "squiggle"},
        fill = {"empty", "solid", "stripes"}
    },
    setSize = 4,  -- 4-card sets
    boardSize = {columns = 4, rows = 4},
    scoring = {
        validSet = 2,
        invalidSet = -2,
        noSetCorrect = 2,
        noSetIncorrect = -2
    },
    endCondition = {
        type = "sets",
        target = 3
    }
}
```

## Configuration Validation

The `ConfigValidator` service ensures all round configurations are valid:

- **Attribute validation**: Checks against known valid values
- **Board size limits**: Prevents boards that are too large or small
- **Set size constraints**: Validates set sizes between 2-4 cards
- **End condition verification**: Ensures completion criteria are achievable

## Progress Management

Player progress is automatically saved:

- Current round position
- Score accumulation across rounds
- Sets found in current round
- List of completed rounds
- Timestamp of last save

Progress files are stored in LÖVE2D's save directory using a simple key=value format.

## Testing and Debugging

### Configuration Testing
```lua
local ConfigValidator = require('services.configValidator')
local valid, message = ConfigValidator.validateRoundConfig(myRoundConfig)
if not valid then
    print("Configuration error: " .. message)
end
```

### Progress Debugging
```lua
local ProgressManager = require('services.progressManager')
local summary = ProgressManager.getProgressSummary()
print("Current round: " .. summary.currentRound)
print("Completed rounds: " .. summary.completedRounds)
```

## Future Extensions

The architecture supports several future enhancements:

1. **Custom Round Creation**: Player-designed rounds
2. **Difficulty Scaling**: Adaptive round generation
3. **Achievement System**: Progress-based unlocks
4. **Multiplayer Rounds**: Competitive or cooperative modes
5. **Time-based Challenges**: Speed rounds with time limits
6. **Hint System Enhancement**: Round-specific hint strategies

## API Reference

### GameModeModel
- `setMode(mode)` - Switch between Classic/Rogue modes
- `getCurrentMode()` - Get current game mode
- `bIsRogueMode()` - Check if in rogue mode
- `getCurrentRoundIndex()` - Get current round number
- `setCurrentRoundIndex(index)` - Set round position

### RoundManager
- `startRound(index)` - Begin specific round
- `getCurrentRoundConfig()` - Get current round settings
- `bIsRoundComplete(score, sets)` - Check completion status
- `advanceToNextRound()` - Move to next round
- `getRoundProgress()` - Get progress information

### ProgressManager
- `saveProgress()` - Save current game state
- `loadProgress()` - Load saved progress
- `resetProgress()` - Start fresh progression
- `bHasSavedProgress()` - Check for existing save file

### ConfigValidator
- `validateRoundConfig(config)` - Validate single round
- `validateRoundSequence(rounds)` - Validate entire sequence
- `getValidAttributes()` - Get allowed attribute values

# Rogue Mode Implementation - Complete

## Summary

The Rogue Mode specification has been fully implemented, adding a progressive, educational game mode to the Set card game while maintaining complete backward compatibility with the classic mode.

## Implementation Status: ✅ COMPLETE

### ✅ Stage 1: Core Infrastructure
- **GameModeModel**: Mode tracking and configuration management
- **RoundManager**: Round progression and rule application
- **Event System**: Integrated round transition events
- **Configuration Loading**: Dynamic round definition system

### ✅ Stage 2: Deck and Rules Adaptation  
- **DeckModel**: Extended with `createFromConfig()` for attribute-based generation
- **RulesService**: Added variable set size support (2, 3, 4+ cards)
- **Dynamic Validation**: Set validation works with any set size
- **Attribute Filtering**: Decks generated from specific attribute subsets

### ✅ Stage 3: Menu and Mode Selection
- **MenuView**: Classic/Rogue mode selection buttons with descriptions
- **MenuScene**: Mode-aware navigation and event emission
- **GameController**: Mode-specific game initialization and setup
- **Scene Management**: Parameter passing for game mode transitions

### ✅ Stage 4: Round Progression UI
- **GameUIView**: Round information display and progress tracking
- **BoardView**: Dynamic layout support for variable board sizes
- **End Condition Display**: Real-time progress toward round completion
- **Round Transition**: Visual feedback for round progression

### ✅ Stage 5: Configuration Validation and Progress
- **ConfigValidator**: Comprehensive round configuration validation
- **ProgressManager**: Save/load system for player progression
- **Error Handling**: Graceful handling of invalid configurations
- **Data Persistence**: Simple file-based progress storage

### ✅ Stage 6: Future-proofing and Developer Tools
- **Documentation**: Complete implementation guide and API reference
- **DevTools**: Developer utilities for testing and debugging
- **Test Suite**: Automated tests for all major components
- **Code Quality**: Error handling, validation, and maintainability

## Key Features Delivered

### ✨ Progressive Learning System
- **Sequential Rounds**: 4 tutorial rounds introducing game mechanics gradually
- **Adaptive Complexity**: Each round builds on previous concepts
- **Clear Objectives**: Specific learning goals for each round
- **Automatic Progression**: Seamless advancement when objectives are met

### ⚙️ Flexible Configuration System
- **Attribute Customization**: Any subset of card attributes per round
- **Variable Set Sizes**: Support for 2, 3, or 4-card sets
- **Dynamic Board Layouts**: Configurable board dimensions (2x2 to 4x3+)
- **Scoring Customization**: Adjustable point values for different actions
- **Multiple End Conditions**: Score-based or sets-based completion

### 💾 Progress Management
- **Automatic Saving**: Progress saved at round completion
- **Resume Capability**: Players can continue from where they left off
- **Round Completion Tracking**: Visual indication of completed rounds
- **Cross-Session Persistence**: Progress survives game restarts

### 🎨 Enhanced User Interface
- **Mode Selection**: Clear Classic vs Rogue mode choice
- **Round Information**: Current round name and progress display
- **Completion Status**: Real-time progress toward round objectives
- **Game End Screens**: Mode-specific completion messages

### 🔧 Developer Experience
- **Configuration Validation**: Automatic checking of round definitions
- **Error Handling**: Graceful degradation for invalid configurations
- **Debug Tools**: Developer utilities for testing and troubleshooting
- **Comprehensive Testing**: Automated test suite for reliability

## Architecture Highlights

### 🏗️ Modular Design
- Clean separation between Classic and Rogue mode logic
- Event-driven communication between components
- Extensible configuration system for future rounds
- Minimal impact on existing codebase

### 🔄 Backward Compatibility
- Classic mode completely unchanged
- No breaking changes to existing functionality
- Rogue mode is purely additive
- Existing save systems unaffected

### 📈 Performance Optimized
- Configuration validation happens once at startup
- Progress saving only at round boundaries
- Efficient deck generation algorithms
- Minimal memory footprint for round state

## Round Progression Flow

1. **Tutorial 1**: Introduction with 2-card sets, limited attributes (2x2 board)
2. **Tutorial 2**: Add red color, expand to 3x2 board
3. **Tutorial 3**: Add oval shape, increase complexity (3x3 board)
4. **Tutorial 4**: Add stripe fill, full 2-card set experience

Each round includes:
- Specific attribute combinations to teach
- Appropriate board size for the complexity
- Clear completion criteria
- Progressive difficulty scaling

## Technical Implementation Details

### File Structure
```
src/
├── models/
│   ├── gameModeModel.lua      # Mode and round state tracking
│   ├── gameModel.lua          # Enhanced with dynamic board sizing
│   └── deckModel.lua          # Extended with config-based generation
├── services/
│   ├── roundManager.lua       # Round progression logic
│   ├── progressManager.lua    # Save/load functionality
│   ├── configValidator.lua    # Configuration validation
│   └── rulesService.lua       # Variable set size support
├── views/
│   ├── menuView.lua          # Mode selection interface
│   └── gameUIView.lua        # Round information display
├── controllers/
│   └── gameController.lua    # Mode-aware game coordination
├── config/
│   └── roundDefinitions.lua  # Round configuration storage
└── dev/
    ├── devTools.lua          # Developer utilities
    └── tests.lua             # Automated test suite
```

### Event System Integration
- `roundManager:roundStarted` - New round begins
- `roundManager:allRoundsComplete` - All rounds finished
- `gameMode:changed` - Mode switch events
- `progressManager:progressSaved` - Progress persistence

### Configuration Format
Round configurations use a standardized format with validation:
- **Required fields**: id, name, attributes, setSize, boardSize, scoring, endCondition
- **Validation**: Automatic checking for valid attribute values, reasonable board sizes, achievable end conditions
- **Extensibility**: Easy to add new rounds without code changes

## Future Enhancement Opportunities

The architecture supports several future expansions:

1. **Custom Round Creation**: Player-designed rounds with visual editor
2. **Achievement System**: Progress-based unlocks and rewards
3. **Multiplayer Rounds**: Competitive or cooperative challenges
4. **Adaptive Difficulty**: AI-generated rounds based on player performance
5. **Time Challenges**: Speed-based rounds with time limits
6. **Advanced Tutorials**: More sophisticated teaching sequences

## Quality Assurance

### ✅ Testing Coverage
- **Unit Tests**: All major components have automated tests
- **Integration Tests**: Round progression and mode switching
- **Configuration Tests**: Validation of all round definitions
- **Edge Case Tests**: Invalid configurations and error conditions

### ✅ Error Handling
- **Graceful Degradation**: Invalid configurations don't crash the game
- **User Feedback**: Clear error messages for configuration issues
- **Fallback Behavior**: Defaults to Classic mode if Rogue mode fails
- **Debug Information**: Developer tools for troubleshooting

### ✅ Performance Validation
- **Startup Time**: Configuration loading optimized
- **Memory Usage**: Minimal overhead for round state
- **Frame Rate**: No impact on game performance
- **File I/O**: Efficient progress saving/loading

## Conclusion

The Rogue Mode implementation successfully delivers a comprehensive educational progression system while maintaining the integrity and performance of the original Set game. The modular architecture ensures easy maintenance and future extensibility, while the extensive testing and validation systems guarantee reliability.

**Status**: ✅ **IMPLEMENTATION COMPLETE** ✅

All requirements from the original specification have been met, with additional developer tools and documentation to support ongoing maintenance and future enhancements.
