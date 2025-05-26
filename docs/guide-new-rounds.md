# Adding New Rounds to Rogue Mode

## Overview

The rogue mode system in Set is designed to be easily extensible, allowing you to add new rounds and sequences to create custom learning experiences. This guide explains how to add new rounds to the system.

## Quick Start

To add a new round, you primarily work with the `src/config/roundDefinitions.lua` file. Each round is defined by a configuration object that specifies game parameters, rules, and completion conditions.

## Round Configuration Structure

Each round follows this structure:

```lua
{
    id = "unique_round_id",                    -- Unique identifier for the round
    name = "Display Name",                     -- Name shown to players in the UI
    description = "Educational purpose",       -- What this round teaches
    attributes = {                             -- Available card attributes
        number = {1, 2, 3},                   -- Numbers that can appear on cards
        color = {"green", "blue", "red"},     -- Available card colors
        shape = {"diamond", "oval"},          -- Available card shapes  
        fill = {"empty", "solid", "stripes"}   -- Available fill patterns
    },
    setSize = 3,                              -- How many cards make a valid set
    boardSize = {columns = 4, rows = 3},      -- Board layout (4x3 = 12 cards)
    scoring = {                               -- Point system
        validSet = 3,                         -- Points for finding a valid set
        invalidSet = -1,                      -- Penalty for wrong set selection
        noSetCorrect = 2,                     -- Points for correctly identifying no sets
        noSetIncorrect = -2                   -- Penalty for wrong "no set" claims
    },
    endCondition = {                          -- When the round ends
        type = "score",                       -- "score" or "sets"
        target = 15                           -- Target score or number of sets
    }
}
```

## Configuration Options

### Attributes
Control which card features are available in the round:

```lua
attributes = {
    number = {1, 2, 3},                    -- Available numbers (1-3)
    color = {"green", "blue", "red"},      -- Available colors
    shape = {"diamond", "oval", "squiggle"}, -- Available shapes
    fill = {"empty", "solid", "stripes"}   -- Available fill patterns
}
```

**Tips:**
- Start with fewer attributes for easier rounds
- Gradually introduce new attributes to teach progressively
- Use subsets to focus on specific concepts

### Set Sizes
Control how many cards make a valid set:

- `setSize = 3` - Traditional Set rules (standard difficulty)
- `setSize = 4` - Advanced four-card sets (expert level)

**Note**: 2-card sets are not supported as they violate the fundamental Set rule that attributes must be either all the same OR all different. With only 2 cards, you can only achieve "all the same" but never "all different" in a meaningful way.

### Board Layouts
Control the game board dimensions:

```lua
boardSize = {columns = 4, rows = 3}  -- 4x3 grid = 12 cards total
```

**Common layouts:**
- `{columns = 2, rows = 2}` - 4 cards (very simple)
- `{columns = 3, rows = 3}` - 9 cards (beginner)
- `{columns = 4, rows = 3}` - 12 cards (standard)
- `{columns = 5, rows = 3}` - 15 cards (challenging)
- `{columns = 6, rows = 4}` - 24 cards (expert)

### Scoring Systems
Customize point values to match difficulty:

```lua
scoring = {
    validSet = 3,        -- Points for finding a valid set
    invalidSet = -1,     -- Penalty for invalid set selection
    noSetCorrect = 2,    -- Points for correctly identifying no sets
    noSetIncorrect = -2  -- Penalty for incorrectly claiming no sets
}
```

**Balancing tips:**
- Higher rewards for harder rounds
- Use penalties to discourage guessing
- Make "no set" rewards meaningful but not exploitable

### End Conditions
Define how rounds complete:

```lua
-- Score-based completion
endCondition = {
    type = "score",
    target = 15
}

-- Set-based completion  
endCondition = {
    type = "sets",
    target = 5
}
```

## Adding Rounds to Existing Sequences

### Method 1: Append to Tutorial Sequence

To add a round to the end of the tutorial sequence:

```lua
-- In roundDefinitions.lua, add to the tutorial array:
RoundDefinitions.tutorial = {
    -- ...existing rounds...
    {
        id = "tutorial_6",
        name = "Master Challenge",
        description = "Put all your skills together",
        attributes = {
            number = {1, 2, 3},
            color = {"green", "blue", "red"},
            shape = {"diamond", "oval", "squiggle"},
            fill = {"empty", "solid", "stripes"}
        },
        setSize = 3,  -- Standard 3-card sets
        boardSize = {columns = 4, rows = 3},
        scoring = {
            validSet = 3,
            invalidSet = -1,
            noSetCorrect = 2,
            noSetIncorrect = -1
        },
        endCondition = {
            type = "score",
            target = 20
        }
    }
}
```

### Method 2: Insert Within a Sequence

To add a round in the middle, simply insert it at the desired position in the array.

## Creating New Sequences

You can create entirely new round sequences for different learning paths:

```lua
-- Add a new sequence
RoundDefinitions.expert = {
    {
        id = "expert_1",
        name = "Speed Challenge",
        description = "Fast-paced set finding with time pressure",
        attributes = {
            number = {1, 2, 3},
            color = {"green", "blue", "red"},
            shape = {"diamond", "oval", "squiggle"},
            fill = {"empty", "solid", "stripes"}
        },
        setSize = 3,
        boardSize = {columns = 5, rows = 3},
        scoring = {
            validSet = 5,
            invalidSet = -3,
            noSetCorrect = 3,
            noSetIncorrect = -5
        },
        endCondition = {
            type = "sets",
            target = 10
        }
    }
    -- Add more rounds...
}
```

Then update the available sequences:

```lua
function RoundDefinitions.getAvailableSequences()
    return {
        tutorial = "Tutorial - Learn progressively",
        intermediate = "Intermediate - Bridge to 3-card sets", 
        advanced = "Advanced - Classic Set rules",
        expert = "Expert - Maximum challenge"  -- Add your new sequence
    }
end
```

## Example Round Types

### Educational Rounds
Focus on teaching specific concepts:

```lua
{
    id = "shape_focus",
    name = "Shape Master",
    description = "Focus on shape recognition",
    attributes = {
        number = {2},  -- Fixed number to focus on shapes
        color = {"blue"},  -- Fixed color
        shape = {"diamond", "oval", "squiggle"},  -- All shapes
        fill = {"solid"}  -- Fixed fill
    },
    setSize = 3,  -- Standard 3-card sets
    boardSize = {columns = 3, rows = 3},
    -- ...scoring and end condition
}
```

### Challenge Rounds
Test mastery with difficult conditions:

```lua
{
    id = "penalty_round",
    name = "High Stakes",
    description = "High rewards, harsh penalties",
    attributes = {
        number = {1, 2, 3},
        color = {"green", "blue", "red"},
        shape = {"diamond", "oval", "squiggle"},
        fill = {"empty", "solid", "stripes"}
    },
    setSize = 3,
    boardSize = {columns = 6, rows = 4},
    scoring = {
        validSet = 10,
        invalidSet = -5,
        noSetCorrect = 5,
        noSetIncorrect = -10
    },
    endCondition = {
        type = "score",
        target = 50
    }
}
```

### Experimental Rounds
Try new mechanics:

```lua
{
    id = "four_card_intro",
    name = "Four-Card Sets",
    description = "Introduction to 4-card combinations",
    attributes = {
        number = {1, 2},  -- Simplified attributes
        color = {"green", "blue"},
        shape = {"diamond"},
        fill = {"empty", "solid"}
    },
    setSize = 4,  -- Advanced 4-card sets
    boardSize = {columns = 4, rows = 4},
    scoring = {
        validSet = 8,
        invalidSet = -2,
        noSetCorrect = 4,
        noSetIncorrect = -3
    },
    endCondition = {
        type = "sets",
        target = 3
    }
}
```

## Best Practices

### Progressive Difficulty
1. **Start Simple**: Begin with fewer attributes and smaller boards
2. **Add One Concept**: Each round should introduce only one new concept
3. **Build Gradually**: Each round should build on previous learning
4. **Test Mastery**: Include rounds that test previously learned concepts

### Balanced Gameplay
1. **Fair Scoring**: Rewards should match difficulty level
2. **Meaningful Penalties**: Discourage random guessing without being punitive
3. **Achievable Targets**: End conditions should be challenging but fair
4. **Appropriate Board Size**: Match board size to attribute complexity

### Educational Value
1. **Clear Objectives**: Each round should have a clear learning goal
2. **Descriptive Names**: Use names that hint at what players will learn
3. **Progressive Sequences**: Design sequences that build skills logically
4. **Variety**: Include different types of challenges (speed, accuracy, complexity)

## Validation

The system automatically validates your round configurations. Common validation errors:

- **Invalid attributes**: Using non-existent colors, shapes, etc.
- **Impossible combinations**: Not enough cards for the specified board size
- **Missing required fields**: All fields in the configuration are required
- **Invalid set sizes**: Set size must be 2, 3, or 4
- **Invalid end conditions**: Type must be "score" or "sets"

## Testing New Rounds

After adding rounds, you can test them using the developer tools:

1. Load the game in developer mode
2. Use the round testing utilities in `src/dev/devTools.lua`
3. Validate configurations with `src/dev/tests.lua`

## File Locations

- **Round Definitions**: `src/config/roundDefinitions.lua`
- **Validation Logic**: `src/services/configValidator.lua`
- **Round Management**: `src/services/roundManager.lua`
- **Developer Tools**: `src/dev/devTools.lua`

## Example: Complete Round Addition

Here's a complete example of adding a new intermediate sequence:

```lua
-- In src/config/roundDefinitions.lua

-- Add the new sequence
RoundDefinitions.colorMaster = {
    {
        id = "color_1",
        name = "Two Colors",
        description = "Master sets with just two colors",
        attributes = {
            number = {1, 2},
            color = {"green", "blue"},
            shape = {"diamond"},
            fill = {"empty", "solid"}
        },
        setSize = 3,
        boardSize = {columns = 3, rows = 3},
        scoring = {
            validSet = 2,
            invalidSet = -1,
            noSetCorrect = 1,
            noSetIncorrect = -1
        },
        endCondition = {
            type = "score",
            target = 8
        }
    },
    {
        id = "color_2",
        name = "Three Colors",
        description = "Add the third color for more complexity",
        attributes = {
            number = {1, 2},
            color = {"green", "blue", "red"},
            shape = {"diamond"},
            fill = {"empty", "solid"}
        },
        setSize = 3,
        boardSize = {columns = 3, rows = 3},
        scoring = {
            validSet = 3,
            invalidSet = -1,
            noSetCorrect = 2,
            noSetIncorrect = -1
        },
        endCondition = {
            type = "score",
            target = 12
        }
    }
}

-- Update the available sequences
function RoundDefinitions.getAvailableSequences()
    return {
        tutorial = "Tutorial - Learn progressively",
        colorMaster = "Color Master - Focus on color recognition",
        intermediate = "Intermediate - Bridge to 3-card sets", 
        advanced = "Advanced - Classic Set rules",
        challenge = "Challenge - Expert difficulty"
    }
end
```

This creates a new sequence focused specifically on color recognition, which players can select from the rogue mode menu.

## Conclusion

The round system is designed to be flexible and extensible. You can create educational progressions, challenging gameplay modes, or experimental rule sets by simply adding configuration objects to the round definitions file. The system handles all the game logic, validation, and progression automatically based on your configurations.
