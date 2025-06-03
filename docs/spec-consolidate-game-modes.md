# Consolidate Game Modes Underlying Logic

## Executive Summary

This specification outlines changes to unify the underlying logic between classic mode and rogue mode in the Set card game. Currently, the two modes operate independently with separate code paths, which has led to inconsistent behavior - particularly with game ending logic. The classic mode currently never ends (identified as a bug), while rogue mode properly detects when no more sets can be formed.

By refactoring classic mode to function as a special case of rogue mode (a single round with standardized rules), we can:
1. Fix the bug with classic mode not ending
2. Ensure consistent behavior across both modes
3. Simplify code maintenance by removing duplicate logic
4. Leverage the existing round completion detection for both modes

The changes required are moderate in scope but will significantly improve gameplay consistency and code maintainability.

## Current Implementation

### Classic Mode
- Directly initializes the game with a standard deck
- Has no explicit end condition defined
- Does not use round-based configuration
- Lacks integration with the round completion detection system

### Rogue Mode
- Uses a sequence of rounds with different configurations
- Each round has custom attributes, board sizes, and rules
- Round completion is detected using `RoundManager.IsRoundComplete()`
- Game ends when all rounds are completed

## Proposed Changes

1. **Create a Standard Set Configuration**: Define a "Classic Set" round configuration in `roundDefinitions.lua` with standard Set rules.

2. **Modify Classic Mode Initialization**: Update `setupClassicGame()` in `gameController.lua` to use the round manager with the Classic Set configuration.

3. **Unify Game End Detection**: Ensure classic mode uses the same `IsRoundComplete()` function as rogue mode to detect when the game should end.

4. **Configuration Updates**: Update game initialization to ensure classic mode is properly configured as a single-round game.

## Technical Implementation

### 1. Add Classic Configuration to Round Definitions

Add a standard classic Set configuration to `roundDefinitions.lua`:

```lua
RoundDefinitions.classic = {{
    id = "classic_set",
    name = "Classic Set",
    description = "Traditional Set rules with all attributes",
    attributes = {
        number = {1, 2, 3},
        color = {"green", "blue", "red"},
        shape = {"diamond", "oval", "squiggle"},
        fill = {"empty", "solid", "stripes"}
    },
    setSize = 3,
    boardSize = {columns = 4, rows = 3},
    scoring = {
        validSet = 1,
        invalidSet = -1,
        noSetCorrect = 1,
        noSetIncorrect = -1
    },
    endCondition = {
        type = "automatic" -- Game ends when no more sets can be formed
    }
}}
```

### 2. Modify Game Controller Setup Function

Update the classic game setup function to use the round-based logic:

```lua
function GameController.setupClassicGame()
    GameModel.reset()
    
    -- Start with classic set configuration
    local config = RoundManager.loadClassicConfig()
    GameModeModel.setCurrentRoundIndex(1)
    GameModeModel.setCurrentConfig(config)
    
    -- Apply configuration and create deck
    GameController.applyRoundConfiguration(config)
    DeckModel.createFromConfig(config)
    DeckModel.shuffle()
    GameController.dealInitialCards()
}
```

### 3. Add Classic Configuration Loading to Round Manager

Add a function to load the classic game configuration:

```lua
function RoundManager.loadClassicConfig()
    if not RoundDefinitions.classic or #RoundDefinitions.classic == 0 then
        error("Classic mode configuration is missing")
    end
    
    currentRoundSequence = RoundDefinitions.classic
    return currentRoundSequence[1]
end
```

### 4. Update Game End Checking for Classic Mode

Modify `GameController.checkRoundCompletion()` to handle classic mode:

```lua
function GameController.checkRoundCompletion() 
    if RoundManager.IsRoundComplete() then
        if GameModeModel.isClassicMode() then
            -- Classic mode only has one round, so end the game
            GameModel.setGameEnded(true)
        else
            -- Rogue mode progression
            local currentRound = GameModeModel.getCurrentRoundIndex()
            ProgressManager.markRoundCompleted(currentRound)
            ProgressManager.saveProgress()

            if RoundManager.gameHasMoreRounds() then
                -- Advance to next round
                local nextConfig = RoundManager.advanceToNextRound()
                -- The handleRoundStarted event will be triggered automatically
            else
                -- All rounds completed
                GameModel.setGameEnded(true)
                ProgressManager.saveProgress()
            end
        end
    end
end
```

## Required Changes by File

### 1. `config/roundDefinitions.lua`
- Add Classic Set configuration

### 2. `services/roundManager.lua` 
- Add `loadClassicConfig()` function
- Ensure `IsRoundComplete()` works consistently for both modes

### 3. `controllers/gameController.lua`
- Update `setupClassicGame()` to use round-based approach
- Modify `checkRoundCompletion()` to handle classic mode
- Add call to `checkRoundCompletion()` in classic mode functions

## Validation and Testing

1. **Classic Mode Game End**: Verify that a classic mode game properly ends when no more sets can be formed.

2. **Rule Consistency**: Ensure all rules (set validation, scoring) remain consistent between modes.

3. **Performance**: Confirm that using the round-based approach for classic mode doesn't impact performance.

## Backwards Compatibility

This change should be fully backwards compatible:
- Player experience in classic mode remains the same (except the game now properly ends)
- No changes to save file formats are required
- Existing rogue mode functionality is unchanged

## Future Considerations

This architectural change enables several future improvements:
1. Custom classic mode variants (e.g., 4-card sets, different board sizes)
2. Game mode parameter tuning without code changes
3. Easier transition to potential future game modes

By ensuring that all game modes use the same underlying logic, we create a more maintainable codebase that can be extended more easily in the future.

# Consolidate Game Modes - Implementation Plan

This document outlines the technical implementation steps to make classic mode use the same underlying logic as rogue mode.

## Overview of Changes

The core architectural change is to make the classic mode function as a special case of rogue mode - essentially a single-round game with a fixed configuration that matches classic Set rules. This ensures both modes use the same functions for game flow control and end condition detection.

## Implementation Steps

### 1. Add Classic Mode Round Definition

First, we'll add a standard classic Set configuration to `roundDefinitions.lua`.

### 2. Create Round Loading Function for Classic Mode

Add a function to `RoundManager` to load the classic configuration.

### 3. Update Classic Game Setup

Modify the classic game setup function to use the round-based approach.

### 4. Update Game End Detection

Ensure game end detection functions properly for classic mode.

### 5. Add Round Completion Checks to Classic Mode

Make sure classic mode calls round completion checks at appropriate points.

## Code Changes by File

### config/roundDefinitions.lua

Add a classic mode configuration to the existing round definitions:

```lua
-- Add a formal definition for classic Set
RoundDefinitions.classic = {{
    id = "classic_set",
    name = "Classic Set",
    description = "Traditional Set rules with all attributes",
    attributes = {
        number = {1, 2, 3},
        color = {"green", "blue", "red"},
        shape = {"diamond", "oval", "squiggle"},
        fill = {"empty", "solid", "stripes"}
    },
    setSize = 3,
    boardSize = {columns = 4, rows = 3},
    scoring = {
        validSet = 1,
        invalidSet = -1,
        noSetCorrect = 1,
        noSetIncorrect = -1
    },
    endCondition = {
        type = "automatic" -- Game ends when no more sets can be formed
    }
}}
```

### services/roundManager.lua

Add functions to support classic mode:

```lua
-- Load classic game configuration
function RoundManager.loadClassicConfig()
    if not RoundDefinitions.classic or #RoundDefinitions.classic == 0 then
        error("Classic mode configuration is missing")
    end
    
    -- Use the classic configuration sequence
    currentRoundSequence = RoundDefinitions.classic
    
    -- Return the configuration for the only round in classic mode
    return currentRoundSequence[1]
end

-- Validate the classic configuration
function RoundManager.validateClassicConfig()
    if not RoundDefinitions.classic or #RoundDefinitions.classic == 0 then
        return false, "Classic mode configuration is not defined"
    end
    
    local config = RoundDefinitions.classic[1]
    local bValid, message = ConfigValidator.validateRoundConfig(config)
    
    return bValid, message
end
```

### controllers/gameController.lua

Update the classic game setup and add round completion checks:

```lua
-- Setup classic mode game
function GameController.setupClassicGame()
    GameModel.reset()
    
    -- Load classic mode configuration
    local config = RoundManager.loadClassicConfig()
    GameModeModel.setCurrentRoundIndex(1)
    GameModeModel.setCurrentConfig(config)
    
    -- Apply configuration
    GameController.applyRoundConfiguration(config)
    
    -- Create deck based on configuration
    DeckModel.createFromConfig(config)
    DeckModel.shuffle()
    GameController.dealInitialCards()
    
    -- Check initial board state
    GameController.checkRoundCompletion()
end
```

Update the round completion function to handle both modes:

```lua
-- Check if the current round is complete
function GameController.checkRoundCompletion() 
    if RoundManager.IsRoundComplete() then
        if GameModeModel.isClassicMode() then
            -- Classic mode only has one round, so end the game when complete
            GameModel.setGameEnded(true)
            EventManager.emit(Events.GAME.CLASSIC_COMPLETED)
        else
            -- Rogue mode progression
            local currentRound = GameModeModel.getCurrentRoundIndex()
            ProgressManager.markRoundCompleted(currentRound)
            ProgressManager.saveProgress()

            if RoundManager.gameHasMoreRounds() then
                -- Advance to next round
                local nextConfig = RoundManager.advanceToNextRound()
                -- handleRoundStarted event will be triggered automatically
            else
                -- All rounds completed
                GameModel.setGameEnded(true)
                ProgressManager.saveProgress()
            end
        end
    end
end
```

Add round completion checks to relevant classic mode functions:

```lua
-- Process selected cards (validate and remove if valid set)
function GameController.processSelectedCards()
    local selectedCards = GameModel.getSelectedCards()
    local board = GameModel.getBoard()
    local currentSetSize = GameModel.getCurrentSetSize()

    if #selectedCards == currentSetSize then
        local cardRefs = {}
        for i, idx in ipairs(selectedCards) do
            cardRefs[i] = board[idx]
        end

        local bIsValid, message = RulesService.validateSelectedCardsOfSize(selectedCards, board, currentSetSize)

        if bIsValid then
            -- Valid set - remove cards and increment score
            GameController.removeValidSet(selectedCards)
            GameModel.incrementScore()
            GameModel.incrementSetsFound()

            -- Check for round completion in both modes
            GameController.checkRoundCompletion()
        else
            -- Invalid set - animate flash red and decrement score
            GameController.animateInvalidSet(selectedCards)
            GameModel.decrementScore()
        end
    end
end
```

Add round completion checks to card drawing function:

```lua
-- Draw a new card from deck
function GameController.drawCard()
    local emptyPosition = GameModel.findEmptyPosition()

    if not emptyPosition then
        return -- No empty positions
    end

    local cardRef = DeckModel.takeCard()
    if cardRef then
        GameModel.setCardAtPosition(emptyPosition, cardRef)
        -- Reset hint state when board changes
        GameModel.clearHint()
        
        -- Check if this card draw results in round completion
        GameController.checkRoundCompletion()
    end
end
```

## Testing Strategy

### Unit Tests

1. Test classic mode configuration loading
2. Test round completion detection in classic mode
3. Test game end conditions for classic mode

### Integration Tests

1. Test full game flow in classic mode
2. Verify proper game end detection
3. Test corner cases (nearly empty deck, etc.)

### Manual Testing

1. Play classic mode to completion and verify it ends properly
2. Test edge cases like using all cards without a valid set

## Success Criteria

1. Classic mode properly ends when no more sets can be formed
2. Both modes use the same underlying logic for game flow
3. No regression in existing functionality
4. Game rules remain consistent between modes
