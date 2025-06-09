-- Game Scene - Main gameplay scene with full game functionality
local CardView = {}

-- required modules
local Logger = require('core.Logger')
local Constants = require('config.Constants')
local CardModel = require('models.CardModel')
local Colors = require('config.ColorRegistry')

-- local variables
local cardImages = {}
local symbolColors = Colors.SYMBOL_COLOR_MAPPING
local cardColors = Colors.MAP.CARD

---------------
-- functions --
---------------

function CardView.loadImages()
    Logger.trace("CardView", "Loading card images")
    cardImages = {
        [Constants.SHAPE.OVAL] = {
            [Constants.FILL.SOLID] = love.graphics.newImage("images/oval-fill-54x96.png"),
            [Constants.FILL.STRIPES] = love.graphics.newImage("images/oval-stripes-54x96.png"),
            [Constants.FILL.EMPTY] = love.graphics.newImage("images/oval-empty-54x96.png")
        },
        [Constants.SHAPE.DIAMOND] = {
            [Constants.FILL.SOLID] = love.graphics.newImage("images/diamond-fill-54x96.png"),
            [Constants.FILL.STRIPES] = love.graphics.newImage("images/diamond-stripes-54x96.png"),
            [Constants.FILL.EMPTY] = love.graphics.newImage("images/diamond-empty-54x96.png")
        },
        [Constants.SHAPE.SQUIGGLE] = {
            [Constants.FILL.SOLID] = love.graphics.newImage("images/squiggle-fill-54x96.png"),
            [Constants.FILL.STRIPES] = love.graphics.newImage("images/squiggle-stripes-54x96.png"),
            [Constants.FILL.EMPTY] = love.graphics.newImage("images/squiggle-empty-54x96.png")
        }
    }
    return cardImages
end

-- Draw a single card
function CardView.draw(cardRef, x, y, width, height, bIsInHint)
     -- Ensure images are loaded
    if not next(cardImages) then
        Logger.warning("CardView", "Images not loaded, loading now...")
        CardView.loadImages()
    end
    local cardData = CardModel._getInternalData(cardRef)
    if not cardData then
        Logger.error("CardView", "no cardData!")
        error("no cardData!")
    end
    if cardData.bIsSelected then
        love.graphics.setColor(unpack(cardColors.SELECTED_BACKGROUND))
    else
        love.graphics.setColor(unpack(cardColors.BACKGROUND))
    end
    love.graphics.rectangle("fill", x, y, width, height, 8, 8)
    -- Draw border
    if cardData.bIsSelected then
        love.graphics.setColor(unpack(cardColors.SELECTED_BORDER))
        love.graphics.setLineWidth(4)
    elseif bIsInHint then
        love.graphics.setColor(unpack(cardColors.HINT_BORDER))
        love.graphics.setLineWidth(4)
    else
        love.graphics.setColor(unpack(cardColors.BORDER))
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle("line", x, y, width, height, 8, 8)
    -- Set color for symbols based on the card's color
    local symbolColor = symbolColors[cardData.color] or {0, 0, 0, 1}
    love.graphics.setColor(unpack(symbolColor))

    -- Get the image for this shape and fill
    local image = cardImages[cardData.shape][cardData.fill]
    if not image then
        Logger.error("CardView", "Missing image for " .. cardData.shape .. "-" .. cardData.fill)
        error("Missing image for " .. cardData.shape .. "-" .. cardData.fill)
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
        positions = {{x + width / 2 - spacing - scaledWidth / 2, y + height / 2},
                     {x + width / 2 + spacing + scaledWidth / 2, y + height / 2}}
    elseif number == 3 then
        local spacing = scaledWidth * 0.15
        positions = {{x + width / 2 - spacing * 2 - scaledWidth, y + height / 2}, {x + width / 2, y + height / 2},
                     {x + width / 2 + spacing * 2 + scaledWidth, y + height / 2}}
    end

    -- Draw the symbols at each position
    for _, pos in ipairs(positions) do
        love.graphics.draw(image, pos[1] - scaledWidth / 2, pos[2] - scaledHeight / 2, 0, scale, scale)
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
        local symbolColor = symbolColors[anim.card.color] or {0, 0, 0, 1}
        love.graphics.setColor(symbolColor[1] * (1 - blackAmount), symbolColor[2] * (1 - blackAmount),
            symbolColor[3] * (1 - blackAmount), 1)

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
    love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8) -- Set color for symbols based on the card's color
    -- Use the mapped color or default to black if not found
    local symbolColor = symbolColors[anim.card.color] or {0, 0, 0, 1}
    love.graphics.setColor(unpack(symbolColor))

    local image = cardImages[anim.card.shape][anim.card.fill]
    if image then
        CardView.drawSymbols(image, anim.card.number, anim.x, anim.y, anim.width, anim.height)
    end
end

return CardView
