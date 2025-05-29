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
    },
    endCondition = {
        type = "score",
        target = 3
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
}, {
    id = "tutorial_4",
    name = "Add Stripes Fill",
    description = "More fill patterns",
    attributes = {
        number = {1, 2},
        color = {"green", "blue", "red"},
        shape = {"diamond", "oval"},
        fill = {"empty", "solid", "stripes"}
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
        target = 10
    }
}, {
    id = "tutorial_5",
    name = "Add Number Three",
    description = "Introducing cards with three symbols",
    attributes = {
        number = {1, 2, 3},
        color = {"green", "blue", "red"},
        shape = {"diamond", "oval"},
        fill = {"empty", "solid", "stripes"}
    },
    setSize = 3,
    boardSize = {
        columns = 4,
        rows = 3
    },
    scoring = {
        validSet = 2,
        invalidSet = -1,
        noSetCorrect = 1,
        noSetIncorrect = -1
    },
    endCondition = {
        type = "score",
        target = 12
    }
}}

-- Intermediate sequence bridging to 3-card sets
RoundDefinitions.intermediate = {{
    id = "intermediate_1",
    name = "All Attributes",
    description = "Master 3-card sets with all attributes",
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
        validSet = 2,
        invalidSet = -1,
        noSetCorrect = 2,
        noSetIncorrect = -1
    },
    endCondition = {
        type = "sets",
        target = 8
    }
}, {
    id = "intermediate_2",
    name = "Larger Board Challenge",
    description = "Practice with more cards on the board",
    attributes = {
        number = {1, 2, 3},
        color = {"green", "blue", "red"},
        shape = {"diamond", "oval", "squiggle"},
        fill = {"empty", "solid", "stripes"}
    },
    setSize = 3,
    boardSize = {
        columns = 5,
        rows = 3
    },
    scoring = {
        validSet = 3,
        invalidSet = -2,
        noSetCorrect = 2,
        noSetIncorrect = -2
    },
    endCondition = {
        type = "score",
        target = 15
    }
}}

-- Advanced sequence with 3-card sets
RoundDefinitions.advanced = {{
    id = "advanced_1",
    name = "Classic 3-Card Sets",
    description = "Traditional Set rules with 3-card sets",
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
        validSet = 3,
        invalidSet = -1,
        noSetCorrect = 2,
        noSetIncorrect = -2
    },
    endCondition = {
        type = "score",
        target = 15
    }
}}

-- Challenge sequence for experts
RoundDefinitions.challenge = {{
    id = "challenge_1",
    name = "Speed Round",
    description = "Find 5 sets quickly with harsh penalties",
    attributes = {
        number = {1, 2, 3},
        color = {"green", "blue", "red"},
        shape = {"diamond", "oval", "squiggle"},
        fill = {"empty", "solid", "stripes"}
    },
    setSize = 3,
    boardSize = {
        columns = 5,
        rows = 3
    },
    scoring = {
        validSet = 5,
        invalidSet = -3,
        noSetCorrect = 3,
        noSetIncorrect = -5
    },
    endCondition = {
        type = "sets",
        target = 5
    }
}, {
    id = "challenge_2",
    name = "Four-Card Marathon",
    description = "Master 4-card sets on a large board",
    attributes = {
        number = {1, 2, 3},
        color = {"green", "blue", "red"},
        shape = {"diamond", "oval", "squiggle"},
        fill = {"empty", "solid", "stripes"}
    },
    setSize = 4,
    boardSize = {
        columns = 6,
        rows = 4
    },
    scoring = {
        validSet = 10,
        invalidSet = -5,
        noSetCorrect = 5,
        noSetIncorrect = -3
    },
    endCondition = {
        type = "score",
        target = 30
    }
}}

-- Get a specific round sequence
function RoundDefinitions.getSequence(sequenceName)
    return RoundDefinitions[sequenceName] or RoundDefinitions.tutorial
end

-- Get all available sequences
function RoundDefinitions.getAvailableSequences()
    return {
        tutorial = "Tutorial - Learn progressively",
        intermediate = "Intermediate - Advanced 3-card practice",
        advanced = "Advanced - Classic Set rules",
        challenge = "Challenge - Expert difficulty"
    }
end

return RoundDefinitions
