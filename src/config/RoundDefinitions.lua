-- Round Definitions Configuration - Define round sequences for rogue mode
local RoundDefinitions = {}

-- Classic Set configuration (for standard play)
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

-- Tutorial sequence with progressive attribute introduction
RoundDefinitions.tutorial = {{
    id = "tutorial_1",
    name = "Getting Started",
    description = "Learn the basics with simple 3-card sets",
    attributes = {
        number = {1, 2},
        color = {"green", "blue"},
        shape = {"diamond", "oval"},
        fill = {"empty", "solid"}
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
        color = {"green", "blue", "red"},
        shape = {"diamond"},
        fill = {"empty", "solid"}
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
    },
    endCondition = {
        type = "score",
        target = 5
    }
}, {
    id = "tutorial_3",
    name = "Add Oval Shape",
    description = "Introducing shape variety",
    attributes = {
        number = {1, 2},
        color = {"green", "blue", "red"},
        shape = {"diamond", "oval"},
        fill = {"empty", "solid"}
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
    },
    endCondition = {
        type = "score",
        target = 7
    }
}}

-- Get a specific round sequence
function RoundDefinitions.getSequence(sequenceName)
    return RoundDefinitions[sequenceName] or RoundDefinitions.tutorial
end

return RoundDefinitions
