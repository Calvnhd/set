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
-- A single round of classic Set for standard play
RoundDefinitions.rogue = {{
    id = "rogue",
    name = "Let's gooo!!",
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

-- Get a specific round sequence
function RoundDefinitions.getSequence(sequenceName)
    return RoundDefinitions[sequenceName] or RoundDefinitions.classic
end

return RoundDefinitions
