-- Round Definitions Configuration - Define round sequences for rogue mode
local RoundDefinitions = {}

-- required modules
local Constants = require('config.Constants')

-- simplify constant Use
local colors = Constants.COLOR
local shapes = Constants.SHAPE
local fill = Constants.FILL

-- A single round of classic Set for standard play
RoundDefinitions.classic = {{
    id = "classic_set",
    name = "Classic Set",
    description = "Traditional Set rules with all attributes",
    attributes = {
        number = {1, 2, 3},
        color = {colors.GREEN, colors.BLUE, colors.RED},
        shape = {shapes.DIAMOND, shapes.OVAL, shapes.SQUIGGLE},
        fill = {fill.EMPTY, fill.SOLID, fill.STRIPES}
    },
    setSize = 3,
    boardSize = {
        columns = 4,
        rows = 3
    },
    scoring = {
        validSet = 1,
        invalidSet = -1,
        noSetCorrect = 1,
        noSetIncorrect = -1
    }
}}

-- Mulitple rounds with progressive attribute introduction
RoundDefinitions.rogue = {{
    id = "tutorial_1",
    name = "Getting Started",
    description = "Learn the basics with simple 3-card sets",
    attributes = {
        number = {1, 2},
        color = {colors.GREEN, colors.BLUE},
        shape = {shapes.DIAMOND, shapes.OVAL},
        fill = {fill.EMPTY, fill.SOLID}
    },
    setSize = 3,
    boardSize = {
        columns = 2,
        rows = 2
    },
    scoring = {
        validSet = 1,
        invalidSet = -1,
        noSetCorrect = 1,
        noSetIncorrect = -1
    }
}, {
    id = "tutorial_2",
    name = "Add Red Color",
    description = "More color variety with 3-card sets",
    attributes = {
        number = {1, 2},
        color = {colors.GREEN, colors.BLUE, colors.RED},
        shape = {shapes.DIAMOND},
        fill = {fill.EMPTY, fill.SOLID}
    },
    setSize = 3,
    boardSize = {
        columns = 3,
        rows = 3
    },
    scoring = {
        validSet = 1,
        invalidSet = -1,
        noSetCorrect = 1,
        noSetIncorrect = -1
    }
}, {
    id = "tutorial_3",
    name = "Add Oval Shape",
    description = "Introducing shape variety",
    attributes = {
        number = {1, 2},
        color = {colors.GREEN, colors.BLUE, colors.RED},
        shape = {shapes.DIAMOND, shapes.OVAL},
        fill = {fill.EMPTY, fill.SOLID}
    },
    setSize = 3,
    boardSize = {
        columns = 3,
        rows = 3
    },
    scoring = {
        validSet = 1,
        invalidSet = -1,
        noSetCorrect = 1,
        noSetIncorrect = -1
    }
}}

-- Get a specific round sequence
function RoundDefinitions.getSequence(sequenceName)
    return RoundDefinitions[sequenceName] or RoundDefinitions.classic
end

return RoundDefinitions
