-- Utility function to convert hex to RGB values (0-1 range for LÖVE2D)
local function hexToRGB(hex)
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return {r, g, b, 1}
end

-- https://lospec.com/palette-list/florentine24
local COLORS = {
    GREEN_1 = hexToRGB("175145"),   -- #175145
    GREEN_2 = hexToRGB("2e8065"),   -- #2e8065
    GREEN_3 = hexToRGB("51b341"),   -- #51b341
    GREEN_4 = hexToRGB("9bd547"),   -- #9bd547
    YELLOW = hexToRGB("fff971"),    -- #fff971
    ORANGE_1 = hexToRGB("ff7f4f"),  -- #ff7f4f
    ORANGE_2 = hexToRGB("ff4f4f"),  -- #ff4f4f
    RED = hexToRGB("ee3046"),       -- #ee3046
    RED_2 = hexToRGB("5d1835"),     -- #5d1835
    PINK_1 = hexToRGB("df426e"),    -- #df426e
    PINK_2 = hexToRGB("a62654"),    -- #a62654
    PURPLE_1 = hexToRGB("0c082a"),  -- #0c082a
    PURPLE_2 = hexToRGB("261152"),  -- #261152
    PURPLE_3 = hexToRGB("371848"),  -- #371848
    PURPLE_4 = hexToRGB("272573"),  -- #272573
    PURPLE_5 = hexToRGB("621b52"),  -- #621b52
    PURPLE_6 = hexToRGB("35082a"),  -- #35082a
    BLUE_1 = hexToRGB("4876bb"),    -- #4876bb
    BLUE_2 = hexToRGB("7fd3e6"),    -- #7fd3e6
    BLUE_3 = hexToRGB("c7f7f2"),    -- #c7f7f2
    WHITE = hexToRGB("ffffff"),     -- #ffffff
    BROWN_3 = hexToRGB("d29c8a"),   -- #d29c8a
    BROWN_2 = hexToRGB("9e4d4d"),   -- #9e4d4d
    BROWN_1 = hexToRGB("712835")    -- #712835
}

local MAP = {
    BACKGROUND = COLORS.BLUE_1,
    MENU_BUTTONS = COLORS.PURPLE_2,
    TEXT = COLORS.WHITE
}

-- Return both tables
return {
    COLORS = COLORS,
    MAP = MAP
}
