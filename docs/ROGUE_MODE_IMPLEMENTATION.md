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
