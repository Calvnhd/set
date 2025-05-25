# New Game Modes with Customizable Settings - Rogue Mode Implementation

An executive summary of the goal or intended outcome, the design changes proposed, and the motivation for them. Also include information on the magnitude of change to the codebase this require. What is the overall impact?

This specification outlines the implementation of a new "Rogue Mode" game mode that enables round-based gameplay with evolving rules, customizable deck composition, variable set sizes, and dynamic board layouts. The goal is to create a flexible framework that allows easy experimentation with different rule configurations while maintaining the existing classic Set game mode.

The motivation is to enable progressive difficulty curves, tutorial experiences, and future roguelike elements where players advance through rounds with increasingly complex rules. The core Set rule definition ("for a given attribute all cards must be the same, or all different") remains consistent - only the set size, available attributes, and scoring will evolve.

**Magnitude of Change**: Medium to Large
- New configuration system for round definitions
- Extension of existing game models to support variable parameters  
- New menu options and game mode selection
- Backwards-compatible changes to deck generation and rules validation
- Estimated 15-20 new/modified files

**Overall Impact**: The changes will be additive and backwards-compatible. The existing classic mode will remain unchanged while the new system provides a foundation for experimental gameplay and future expansions.

## Overall design

The design centers around a **Strategy Pattern** for game rule configurations combined with a **Command Pattern** for round progression. Key design principles:

1. **Rule Configuration Objects**: Each round is defined by a configuration object specifying available attributes, set size, board dimensions, and scoring rules.

2. **Game Mode Abstraction**: A new `GameMode` interface that classic and rogue modes implement, allowing the system to switch behavior based on the selected mode.

3. **Extensible Deck Generation**: Modify `DeckModel` to generate decks based on attribute specifications rather than hard-coded values.

4. **Dynamic Rules Service**: Extend `RulesService` to validate sets of configurable sizes rather than fixed sets of 3.

5. **Round Management**: New `RoundManager` service to handle round progression, rule transitions, and end-of-round logic.

6. **Progressive Configuration**: JSON or Lua-based configuration files defining round sequences for easy modification and testing.

The design maintains the existing MVC architecture while introducing new abstractions that enable rule customization without breaking existing functionality.

## Change list

### models/gameModel.lua
- **Changes**: Add game mode tracking, round state management, dynamic board sizing
- **Outcome**: Support for variable board dimensions and round-based state
- **Reason and importance**: Central game state must accommodate different rule sets and track round progression

### models/deckModel.lua  
- **Changes**: Parameterized deck generation based on attribute specifications
- **Outcome**: Generate decks with subsets of attributes instead of fixed full deck
- **Reason and importance**: Core requirement for progressive attribute introduction across rounds

### services/rulesService.lua
- **Changes**: Support variable set sizes (2, 3, 4+) instead of hard-coded 3-card sets
- **Outcome**: Validate sets of any configured size while maintaining Set rule logic
- **Reason and importance**: Essential for early rounds with 2-card sets and future expansion

### services/roundManager.lua (NEW)
- **Changes**: Create new service for round progression and rule management
- **Outcome**: Centralized round logic, configuration loading, and progression triggers
- **Reason and importance**: Manages the core rogue mode gameplay loop and rule evolution

### models/gameModeModel.lua (NEW)
- **Changes**: New model to track current game mode and associated configurations
- **Outcome**: Clean separation between classic and rogue mode states
- **Reason and importance**: Enables mode-specific behavior without cluttering existing models

### controllers/gameController.lua
- **Changes**: Mode-aware initialization and round progression handling
- **Outcome**: Orchestrate round transitions and mode-specific game logic
- **Reason and importance**: Central coordination point for new round-based gameplay

### views/menuView.lua
- **Changes**: Add "Classic" and "Rogue" mode buttons to main menu
- **Outcome**: User can select between game modes
- **Reason and importance**: User interface for mode selection

### scenes/gameScene.lua  
- **Changes**: Mode-aware scene initialization and round transition handling
- **Outcome**: Support for both classic continuous play and round-based play
- **Reason and importance**: Different scene behavior based on selected game mode

### views/gameUIView.lua
- **Changes**: Display round information, attribute progression, and round-specific scoring
- **Outcome**: UI shows current round, available attributes, and round progress
- **Reason and importance**: Player needs feedback on current rule set and progression

### views/boardView.lua
- **Changes**: Dynamic board layout based on configured board dimensions
- **Outcome**: Board adapts to different grid sizes (2x2, 3x3, 4x3, etc.)
- **Reason and importance**: Board must accommodate different deck sizes and complexity levels

### config/roundDefinitions.lua (NEW)
- **Changes**: Configuration files defining round sequences
- **Outcome**: Easy modification of round progression without code changes
- **Reason and importance**: Enables rapid experimentation and testing of different progressions

## Design plan

### Stage 1: Core Infrastructure
1. Create `models/gameModeModel.lua` with mode tracking and configuration loading
2. Create `services/roundManager.lua` with basic round progression logic
3. Extend `models/gameModel.lua` to support dynamic board sizes and round state
4. Create `config/roundDefinitions.lua` with initial round configurations

**Deliverable**: Foundation classes that can load and track round configurations

### Stage 2: Deck and Rules Adaptation  
1. Modify `models/deckModel.lua` to generate decks from attribute specifications
2. Extend `services/rulesService.lua` to validate variable-size sets
3. Update related validation and card counting logic
4. Test with simple 2-card and 3-card configurations

**Deliverable**: Flexible deck generation and set validation working with test configurations

### Stage 3: Menu and Mode Selection
1. Modify `views/menuView.lua` to add Classic/Rogue mode buttons
2. Update `scenes/menuScene.lua` to handle mode selection
3. Modify `controllers/gameController.lua` to initialize based on selected mode
4. Update `scenes/gameScene.lua` for mode-aware behavior

**Deliverable**: Working menu system that can launch either classic or rogue modes

### Stage 4: Round Progression and UI
1. Implement round transition logic in `services/roundManager.lua`
2. Update `views/gameUIView.lua` to display round information
3. Modify `views/boardView.lua` for dynamic board layouts
4. Add round completion detection and progression triggers

**Deliverable**: Complete rogue mode with round progression and appropriate UI feedback

### Stage 5: Configuration and Testing
1. Create comprehensive round definitions covering the tutorial sequence
2. Add configuration validation and error handling
3. Implement save/load of round progress (if desired)
4. Performance testing and optimization

**Deliverable**: Polished rogue mode ready for content creation and experimentation

### Stage 6: Future-Proofing and Documentation
1. Add hooks for future scoring modifiers and special rules
2. Create documentation for configuration format
3. Add developer tools for rapid round testing
4. Code cleanup and optimization

**Deliverable**: Extensible system ready for future expansions

## Other Considerations

### Performance Considerations
- Deck generation with large attribute combinations could become expensive; consider lazy loading or caching
- Board layout calculations should be cached when dimensions don't change
- Configuration loading should happen at mode selection, not during gameplay

### Extensibility
- The configuration system should support future additions like:
  - Scoring multipliers and modifiers
  - Special round types (timed rounds, bonus objectives)
  - Custom card attributes beyond the standard four
  - Player choice in attribute progression (roguelike branching)

### Backwards Compatibility
- All changes must maintain existing classic mode functionality
- Existing save files and player progress should remain valid
- Performance of classic mode should not be impacted

### Testing Strategy
- Unit tests for variable set size validation
- Integration tests for round progression
- Configuration validation tests
- Performance tests for deck generation with large attribute sets

### User Experience
- Round transitions should be smooth and clearly communicated
- Players should understand what's changing between rounds
- Failure states should be clear (e.g., impossible configurations)
- Consider tutorial tooltips explaining rule changes

### Configuration Format Example
```lua
-- Round definition structure
{
    id = "tutorial_1",
    name = "Getting Started",
    attributes = {
        number = {1, 2},
        color = {"green", "blue"},
        shape = {"diamond"},
        fill = {"empty", "solid"}
    },
    setSize = 2,
    boardSize = {columns = 2, rows = 2},
    scoring = {
        validSet = 1,
        invalidSet = -1,
        noSetCorrect = 1,
        noSetIncorrect = -1
    },
    endCondition = {
        type = "score", -- or "sets", "time"
        target = 5
    }
}
```

This specification provides a roadmap for implementing the rogue mode while maintaining code quality and extensibility for future enhancements.
