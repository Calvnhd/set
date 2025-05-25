-- Card View - Card rendering with animation support

local CardModel = require('models.cardModel')

local CardView = {}

-- Store card images
local cardImages = {}

-- Centralized color definitions
local COLORS = {
    -- Symbol colors (standard)
    symbol = {
        red = {0.64, 0.19, 0.19},     
        green = {0.45, 0.65, 0.26},  
        blue = {0.30, 0.56, 0.72}     
    },
    
    -- Background complementary colors with opacity (R, G, B, Alpha)
    background = {
        red = {0.77, 0.51, 0.64, 0.2},
        green = {0.81, 0.34, 0.24, 0.2},
        blue = {0.9, 0.83, 0.70, 0.2}
    },
    
    -- Selection and UI colors
    ui = {
        selected = {0.9, 0.9, 0.7},
        selectedBorder = {1, 1, 0},
        hintBorder = {0, 0.8, 0.8},
        normalBorder = {0, 0, 0}
    }
}

-- Load all card images
function CardView.loadImages()
    cardImages = {
        oval = {
            solid = love.graphics.newImage("images/oval-fill-54x96.png"),
            stripes = love.graphics.newImage("images/oval-stripes-54x96.png"),
            empty = love.graphics.newImage("images/oval-empty-54x96.png")
        },
        diamond = {
            solid = love.graphics.newImage("images/diamond-fill-54x96.png"),
            stripes = love.graphics.newImage("images/diamond-stripes-54x96.png"),
            empty = love.graphics.newImage("images/diamond-empty-54x96.png")
        },
        squiggle = {
            solid = love.graphics.newImage("images/squiggle-fill-54x96.png"),
            stripes = love.graphics.newImage("images/squiggle-stripes-54x96.png"),
            empty = love.graphics.newImage("images/squiggle-empty-54x96.png")
        }
    }
    return cardImages
end

-- Helper function to get a pale complementary color for card background
local function getPaleComplementaryColor(color)
    if COLORS.background[color] then
        local r = COLORS.background[color][1]
        local g = COLORS.background[color][2]
        local b = COLORS.background[color][3]
        local a = COLORS.background[color][4] or 1.0
        return r, g, b, a
    else
        return 1.0, 1.0, 1.0, 1.0
    end
end

-- Draw a single card
function CardView.draw(cardRef, x, y, width, height, bIsInHint)
    local cardData = CardModel._getInternalData(cardRef)
    
    -- Draw card background with pale complementary color
    if cardData.bIsSelected then
        love.graphics.setColor(unpack(COLORS.ui.selected))
    else
        local r, g, b, a = getPaleComplementaryColor(cardData.color)
        love.graphics.setColor(r, g, b, a)
    end
    love.graphics.rectangle("fill", x, y, width, height, 8, 8)
    
    -- Draw border
    if cardData.bIsSelected then
        love.graphics.setColor(unpack(COLORS.ui.selectedBorder))
        love.graphics.setLineWidth(4)
    elseif bIsInHint then
        love.graphics.setColor(unpack(COLORS.ui.hintBorder))
        love.graphics.setLineWidth(4)
    else
        love.graphics.setColor(unpack(COLORS.ui.normalBorder))
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle("line", x, y, width, height, 8, 8)
    
    -- Set color for symbols
    if COLORS.symbol[cardData.color] then
        love.graphics.setColor(unpack(COLORS.symbol[cardData.color]))
    end

    -- Get the image for this shape and fill
    local image = cardImages[cardData.shape][cardData.fill]
    if not image then
        print("Warning: Missing image for " .. cardData.shape .. "-" .. cardData.fill)
        return
    end
    
    -- Draw the symbols
    CardView.drawSymbols(image, cardData.number, x, y, width, height)
end

-- Draw symbols on a card
function CardView.drawSymbols(image, number, x, y, width, height)
    local imgWidth = image:getWidth()
    local imgHeight = image:getHeight()

    -- Calculate a consistent scale for all shapes
    local baseScale = 0.8
    local maxShapesWidth = imgWidth * 3
    local spacingWidth = imgWidth * 0.6
    local totalWidthNeeded = maxShapesWidth + spacingWidth
    local scaleForWidth = (width * 0.85) / totalWidthNeeded
    local scaleForHeight = (height * 0.55) / imgHeight
    local scale = math.min(scaleForWidth, scaleForHeight, baseScale)

    local scaledWidth = imgWidth * scale
    local scaledHeight = imgHeight * scale
    
    -- Calculate positions for the symbols
    local positions = {}
    if number == 1 then
        positions = {{x + width / 2, y + height / 2}}
    elseif number == 2 then
        local spacing = scaledWidth * 0.15
        positions = {
            {x + width / 2 - spacing - scaledWidth / 2, y + height / 2},
            {x + width / 2 + spacing + scaledWidth / 2, y + height / 2}
        }
    elseif number == 3 then
        local spacing = scaledWidth * 0.15
        positions = {
            {x + width / 2 - spacing * 2 - scaledWidth, y + height / 2}, 
            {x + width / 2, y + height / 2},
            {x + width / 2 + spacing * 2 + scaledWidth, y + height / 2}
        }
    end

    -- Draw the symbols at each position
    for _, pos in ipairs(positions) do
        love.graphics.draw(image, 
                         pos[1] - scaledWidth / 2,
                         pos[2] - scaledHeight / 2,
                         0,
                         scale, scale
        )
    end
end

-- Draw a burning card animation
function CardView.drawBurningCard(anim)
    local phase = anim.phase
    local progress = anim.phaseProgress

    if phase == 1 then
        -- Phase 1: Background fades from complementary color to medium red
        local baseR, baseG, baseB, baseA = getPaleComplementaryColor(anim.card.color)
        local redAmount = 0.6 * progress
        local r = baseR * (1 - progress) + progress
        local g = baseG * (1 - progress) + (1 - redAmount) * progress
        local b = baseB * (1 - progress) + (1 - redAmount) * progress
        local a = baseA * (1 - progress) + progress
        
        love.graphics.setColor(r, g, b, a)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)

        love.graphics.setColor(1, 0.3, 0.3, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)

        -- Fade shapes toward black
        local blackAmount = progress
        if COLORS.symbol[anim.card.color] then
            local symbolColor = COLORS.symbol[anim.card.color]
            love.graphics.setColor(
                symbolColor[1] * (1 - blackAmount),
                symbolColor[2] * (1 - blackAmount),
                symbolColor[3] * (1 - blackAmount),
                1
            )
        end

    elseif phase == 2 then
        -- Phase 2: Card fades to bright orange/red
        local brightRed = 1
        local brightGreen = 0.3 + (0.4 * (1 - progress))
        local brightBlue = 0.1 * (1 - progress)

        love.graphics.setColor(brightRed, brightGreen, brightBlue, 1)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)

        love.graphics.setColor(1, 0.5 * (1 - progress), 0.2 * (1 - progress), 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)

        love.graphics.setColor(brightRed, brightGreen, brightBlue, 1)

    elseif phase == 3 then
        -- Phase 3: Card fades to deep dark blackish red
        local darkRed = 0.6 - (0.5 * progress)
        local darkGreen = 0.05 * (1 - progress)
        local darkBlue = 0.05 * (1 - progress)

        love.graphics.setColor(darkRed, darkGreen, darkBlue, 1)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)

        love.graphics.setColor(darkRed + 0.2, darkGreen, darkBlue, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)

        love.graphics.setColor(darkRed, darkGreen, darkBlue, 1)

    elseif phase == 4 then
        -- Phase 4: Card fades out completely
        local opacity = 1 - progress
        
        if opacity < 0.1 then
            return -- Don't render at low opacity
        end
        
        love.graphics.setColor(0, 0, 0, opacity)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)
        
        love.graphics.setColor(0.2, 0, 0, opacity)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)
        
        return -- No symbols in phase 4
    end

    -- Draw symbols for phases 1-3
    local image = cardImages[anim.card.shape][anim.card.fill]
    if image then
        CardView.drawSymbols(image, anim.card.number, anim.x, anim.y, anim.width, anim.height)
    end
end

-- Draw a flashing red card animation
function CardView.drawFlashingRedCard(anim)
    local flashIntensity = anim.flashIntensity or 0
    
    -- Get the complementary color as a base
    local baseR, baseG, baseB, baseA = getPaleComplementaryColor(anim.card.color)
    
    -- Mix the complementary color with the red flash
    local r = baseR + (1 - baseR) * flashIntensity
    local g = baseG * (1 - flashIntensity * 0.8)
    local b = baseB * (1 - flashIntensity * 0.8)
    local a = baseA
    
    love.graphics.setColor(r, g, b, a)
    love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)
    
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)
    
    -- Set color for symbols
    if COLORS.symbol[anim.card.color] then
        love.graphics.setColor(unpack(COLORS.symbol[anim.card.color]))
    end
    
    local image = cardImages[anim.card.shape][anim.card.fill]
    if image then
        CardView.drawSymbols(image, anim.card.number, anim.x, anim.y, anim.width, anim.height)
    end
end

return CardView
