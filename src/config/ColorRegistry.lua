
-- required modules
local Constants = require('config.Constants')

-- Utility function to convert hex to RGB values (0-1 range for LÖVE2D)
local function hexToRGB(hex)
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return {r, g, b, 1}
end

-- Full color palette
-- https://lospec.com/palette-list/florentine24
local COLORS = {
    GREEN_1 = hexToRGB("175145"), -- #175145
    GREEN_2 = hexToRGB("2e8065"), -- #2e8065
    GREEN_3 = hexToRGB("51b341"), -- #51b341
    GREEN_4 = hexToRGB("9bd547"), -- #9bd547
    YELLOW = hexToRGB("fff971"), -- #fff971
    ORANGE_1 = hexToRGB("ff7f4f"), -- #ff7f4f
    ORANGE_2 = hexToRGB("ff4f4f"), -- #ff4f4f
    RED = hexToRGB("ee3046"), -- #ee3046
    RED_2 = hexToRGB("5d1835"), -- #5d1835
    PINK_1 = hexToRGB("df426e"), -- #df426e
    PINK_2 = hexToRGB("a62654"), -- #a62654
    PURPLE_1 = hexToRGB("0c082a"), -- #0c082a
    PURPLE_2 = hexToRGB("261152"), -- #261152
    PURPLE_3 = hexToRGB("371848"), -- #371848
    PURPLE_4 = hexToRGB("272573"), -- #272573
    PURPLE_5 = hexToRGB("621b52"), -- #621b52
    PURPLE_6 = hexToRGB("35082a"), -- #35082a
    BLUE_1 = hexToRGB("4876bb"), -- #4876bb
    BLUE_2 = hexToRGB("7fd3e6"), -- #7fd3e6
    BLUE_3 = hexToRGB("c7f7f2"), -- #c7f7f2
    WHITE = hexToRGB("ffffff"), -- #ffffff
    BROWN_3 = hexToRGB("d29c8a"), -- #d29c8a
    BROWN_2 = hexToRGB("9e4d4d"), -- #9e4d4d
    BROWN_1 = hexToRGB("712835") -- #712835
}

-- Maps colors from the palette to specific elements of the game
local MAP = {
    BACKGROUND = COLORS.BLUE_1,
    MENU_BUTTONS = COLORS.PURPLE_2,
    TEXT = COLORS.WHITE,
    CARD = {
        SYMBOL = {
            RED = COLORS.RED,
            GREEN = COLORS.GREEN_3,
            BLUE = COLORS.BLUE_1
        },
        BACKGROUND = COLORS.WHITE,
        BORDER = COLORS.PURPLE_4,
        SELECTED_BACKGROUND = COLORS.YELLOW,
        SELECTED_BORDER = COLORS.GREEN_2,
        HINT_BORDER = COLORS.BLUE_3
    },
    BOARD_BACKGROUND = COLORS.WHITE
}

-- Maps symbol color constants to actual colors
local SYMBOL_COLOR_MAPPING = {
    [Constants.COLOR.RED] = MAP.CARD.SYMBOL.RED,
    [Constants.COLOR.GREEN] = MAP.CARD.SYMBOL.GREEN,
    [Constants.COLOR.BLUE] = MAP.CARD.SYMBOL.BLUE
}

function withAlpha(colorTable, alpha)
    return {colorTable[1], colorTable[2], colorTable[3], alpha}
end

-- Return both tables and the utility function
return {
    COLORS = COLORS,
    MAP = MAP,
    withAlpha = withAlpha,
    SYMBOL_COLOR_MAPPING = SYMBOL_COLOR_MAPPING
}
