-- Card module for Set game - responsible for card appearance and animations

local card = {}

-- Store card images
local cardImages = {}

-- Animation tracking
local animatingCards = {} -- animation state information each currently animating card

-- Card objects cache - storing internal data for all created cards
local cardObjects = {} -- indexed by card id
local nextCardId = 1 -- unique id counter for cards

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
        red = {0.77, 0.51, 0.64, 0.2},      -- Alpha of 0.6 (60% opacity)
        green = {0.81, 0.34, 0.24, 0.2},     -- Alpha of 0.6 (60% opacity)
        blue = {0.9, 0.83, 0.70, 0.2}       -- Alpha of 0.6 (60% opacity)
    },
    
    -- Selection and UI colors
    ui = {
        selected = {0.9, 0.9, 0.7},       -- Slight yellow tint for selected cards
        selectedBorder = {1, 1, 0},       -- Yellow highlight for selected cards
        hintBorder = {0, 0.8, 0.8},       -- Cyan highlight for hint cards
        normalBorder = {0, 0, 0}          -- Black border for normal cards
    }
}

-- Helper function to get a pale complementary color for card background
local function getPaleComplementaryColor(color)
    if COLORS.background[color] then
        -- Use the centralized color definitions, including alpha if available
        local r = COLORS.background[color][1]
        local g = COLORS.background[color][2]
        local b = COLORS.background[color][3]
        local a = COLORS.background[color][4] or 1.0  -- Use 1.0 (fully opaque) if alpha is not specified
        return r, g, b, a
    else
        -- Default white (fully opaque)
        return 1.0, 1.0, 1.0, 1.0
    end
end

-- Load all card images
function card.loadImages()
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

-- Get the loaded card images
function card.getImages()
    return cardImages
end

-- Update card animations
function card.updateAnimations(dt)
    local animationsCompleted = {}    -- Process each animating card
    for i, anim in ipairs(animatingCards) do
        -- Update the animation timer
        anim.timer = anim.timer + dt
        -- Calculate progress (0 to 1)
        local progress = math.min(anim.timer / anim.duration, 1)        -- Update the card's animation properties based on progress
        if anim.type == "burn" then
            -- Calculate which phase we're in based on progress
            local phaseLength = 1 / 4 -- Each phase is 1/4 of the total animation
            anim.phase = math.min(4, math.floor(progress / phaseLength) + 1)
            -- Calculate progress within the current phase (0 to 1)
            anim.phaseProgress = (progress - (anim.phase - 1) * phaseLength) / phaseLength
            -- Phase-specific updates will be handled in the drawing function
        elseif anim.type == "flashRed" then
            -- Flash red animation is handled in the drawing function
        end
        -- Check if animation is complete
        if progress >= 1 then
            table.insert(animationsCompleted, i)
            -- Only call the completion callback if it hasn't been called during phase 4 already
            if anim.onComplete and not anim.bCompletionCalled then
                anim.onComplete()
            end
        end
    end
    -- Remove completed animations in reverse order to avoid index issues
    table.sort(animationsCompleted, function(a, b)
        return a > b
    end)
    for _, index in ipairs(animationsCompleted) do
        table.remove(animatingCards, index)
    end
end

-- Function to animate a card burning
function card.animateBurn(cardRef, x, y, width, height, onComplete)
    local cardData = card._getInternalData(cardRef)
    local anim = {
        card = cardData,
        x = x,
        y = y,
        width = width,
        height = height,
        type = "burn",
        duration = 1.5, -- Animation takes 1.5 seconds (shortened for better feel)
        timer = 0,
        phase = 1, -- Start with phase 1
        phaseProgress = 0, -- Progress within the current phase
        opacity = 1, -- Start fully visible
        onComplete = onComplete,
        bCompletionCalled = false -- Flag to track if animation completion callback was already called
    }
    table.insert(animatingCards, anim)
    return anim
end

-- Function to animate a card flashing red (for invalid sets)
function card.animateFlashRed(cardRef, x, y, width, height, onComplete)
    local cardData = card._getInternalData(cardRef)
    local anim = {
        card = cardData,
        x = x,
        y = y,
        width = width,
        height = height,
        type = "flashRed",
        duration = 1.0, -- Animation takes 1 second
        timer = 0,
        opacity = 1, -- Start fully visible
        onComplete = onComplete
    }
    table.insert(animatingCards, anim)
    return anim
end

-- Draw animating cards
function card.drawAnimatingCards()
    for _, anim in ipairs(animatingCards) do
        if anim.type == "burn" then
            card.drawBurningCard(anim)
        elseif anim.type == "flashRed" then
            card.drawFlashingRedCard(anim)
        end
    end
end



-- Draw a card with burning effect
function card.drawBurningCard(anim)
    -- Different drawing logic depending on which phase we're in
    local phase = anim.phase
    local progress = anim.phaseProgress

    if phase == 1 then
        -- Phase 1: Background fades from complementary color to medium red, shapes fade to black
          -- Get the complementary color as a starting point
        local baseR, baseG, baseB, baseA = getPaleComplementaryColor(anim.card.color)
        
        -- Transition from complementary color to red
        local redAmount = 0.6 * progress -- Medium red
        local r = baseR * (1 - progress) + progress -- Transition to reddish
        local g = baseG * (1 - progress) + (1 - redAmount) * progress -- Fade green component
        local b = baseB * (1 - progress) + (1 - redAmount) * progress -- Fade blue component
        -- Transition from the base alpha to full opacity
        local a = baseA * (1 - progress) + progress
        
        love.graphics.setColor(r, g, b, a)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)

        -- Draw border with slight red tint
        love.graphics.setColor(1, 0.3, 0.3, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)

    -- Set color for the shapes - fade toward black
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
        -- Phase 2: Card fades to bright orange/red (shapes no longer visible)
        local brightRed = 1
        local brightGreen = 0.3 + (0.4 * (1 - progress)) -- Fades from orange-red to red
        local brightBlue = 0.1 * (1 - progress) -- Almost no blue at the end

        -- Draw card background with bright orange/red
        love.graphics.setColor(brightRed, brightGreen, brightBlue, 1)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)

        -- Draw border slightly brighter
        love.graphics.setColor(1, 0.5 * (1 - progress), 0.2 * (1 - progress), 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)

        -- Draw shapes with the same color (they become invisible against background)
        love.graphics.setColor(brightRed, brightGreen, brightBlue, 1)

    elseif phase == 3 then
        -- Phase 3: Card fades to deep dark blackish red
        local darkRed = 0.6 - (0.5 * progress) -- From medium red to very dark red
        local darkGreen = 0.05 * (1 - progress)
        local darkBlue = 0.05 * (1 - progress)

        -- Draw card background with darkening red
        love.graphics.setColor(darkRed, darkGreen, darkBlue, 1)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)

        -- Draw border with matching dark red
        love.graphics.setColor(darkRed + 0.2, darkGreen, darkBlue, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)

        -- Shapes use the same color as the background (invisible)
        love.graphics.setColor(darkRed, darkGreen, darkBlue, 1)    elseif phase == 4 then
        -- Phase 4: Card simply fades out completely
        local opacity = 1 - progress
        
        -- Make sure the card becomes completely invisible as we approach the end
        if opacity < 0.1 then
            -- When we get to 90% through phase 4, mark this animation as complete
            -- This ensures the card never reappears, even for a single frame
            if anim.onComplete and not anim.bCompletionCalled then
                anim.bCompletionCalled = true
                anim.onComplete()
            end
            
            -- Don't render anything at this low opacity
            return
        end
        
        -- Draw a completely black card with fading opacity
        love.graphics.setColor(0, 0, 0, opacity)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)
        
        -- Draw a thin black border
        love.graphics.setColor(0.2, 0, 0, opacity)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)
        
        -- No symbols in phase 4
        return
    end

    -- Only draw shapes for phases 1-3
    -- Get the image for this shape and fill
    local image = cardImages[anim.card.shape][anim.card.fill]
    if not image then
        return
    end

    -- Draw the symbols with calculated positions
    card.drawSymbols(image, anim.card.number, anim.x, anim.y, anim.width, anim.height)
end

-- Draw a card with flash red effect
function card.drawFlashingRedCard(anim)
    local progress = anim.timer / anim.duration
    
    -- Calculate the flash intensity (peak at middle of animation)
    local flashIntensity = 0
    if progress < 0.5 then
        flashIntensity = progress * 2 -- 0 to 1 in first half
    else
        flashIntensity = (1 - progress) * 2 -- 1 to 0 in second half
    end
      -- Get the complementary color as a base
    local baseR, baseG, baseB, baseA = getPaleComplementaryColor(anim.card.color)
    
    -- Mix the complementary color with the red flash
    local r = baseR + (1 - baseR) * flashIntensity
    local g = baseG * (1 - flashIntensity * 0.8)
    local b = baseB * (1 - flashIntensity * 0.8)
    -- Keep the same alpha value
    local a = baseA
    
    -- Draw card background with mixed color
    love.graphics.setColor(r, g, b, a)
    love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)
    
    -- Draw border with red highlight based on flash intensity
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)
    
    -- Set color for the card symbols using centralized color definitions
    if COLORS.symbol[anim.card.color] then
        love.graphics.setColor(unpack(COLORS.symbol[anim.card.color]))
    end
    
    -- Get the image for this shape and fill
    local image = cardImages[anim.card.shape][anim.card.fill]
    if not image then
        return
    end
      -- Draw the symbols with calculated positions
    card.drawSymbols(image, anim.card.number, anim.x, anim.y, anim.width, anim.height)
end

-- Draw a single card
function card.draw(cardRef, x, y, width, height, bIsInHint)
    local cardData = card._getInternalData(cardRef)
    
    -- Draw card background with pale complementary color
    if cardData.bIsSelected then
        love.graphics.setColor(unpack(COLORS.ui.selected)) -- Selected card background
    else
        -- Use a pale complementary color based on the card's symbol color
        local r, g, b, a = getPaleComplementaryColor(cardData.color)
        love.graphics.setColor(r, g, b, a) -- Pale complementary color with opacity
    end
    love.graphics.rectangle("fill", x, y, width, height, 8, 8) -- Rounded corners
    
    -- Draw border
    if cardData.bIsSelected then
        love.graphics.setColor(unpack(COLORS.ui.selectedBorder)) -- Selected card border
        love.graphics.setLineWidth(4)
    elseif bIsInHint then
        love.graphics.setColor(unpack(COLORS.ui.hintBorder)) -- Hint card border
        love.graphics.setLineWidth(4)
    else
        love.graphics.setColor(unpack(COLORS.ui.normalBorder)) -- Normal card border
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle("line", x, y, width, height, 8, 8)
    
    -- Set color based on card color for tinting the white images
    if COLORS.symbol[cardData.color] then
        love.graphics.setColor(unpack(COLORS.symbol[cardData.color])) -- Symbol color from centralized definition
    end

    -- Get the image for this shape and fill
    local image = cardImages[cardData.shape][cardData.fill]
    if not image then
        print("Warning: Missing image for " .. cardData.shape .. "-" .. cardData.fill)
        return
    end
    
    -- Draw the symbols with calculated positions
    card.drawSymbols(image, cardData.number, x, y, width, height)
end

-- Draw symbols on a card (helper function used by multiple draw methods)
function card.drawSymbols(image, number, x, y, width, height)
    -- Calculate image dimensions
    local imgWidth = image:getWidth()
    local imgHeight = image:getHeight()

    -- Calculate a consistent scale for all shapes regardless of card number
    local baseScale = 0.8 -- Default scale factor

    -- Calculate the maximum width needed for 3 shapes plus spacing
    local maxShapesWidth = imgWidth * 3 -- Width of three shapes
    local spacingWidth = imgWidth * 0.6 -- Total spacing between 3 shapes
    local totalWidthNeeded = maxShapesWidth + spacingWidth

    -- Calculate the scale that would make 3 shapes fit on any card
    local scaleForWidth = (width * 0.85) / totalWidthNeeded -- 85% of card width

    -- Ensure the height also fits (55% of card height)
    local scaleForHeight = (height * 0.55) / imgHeight

    -- Take the smaller scale to ensure both width and height fit
    local scale = math.min(scaleForWidth, scaleForHeight, baseScale)

    -- Calculate scaled dimensions
    local scaledWidth = imgWidth * scale
    local scaledHeight = imgHeight * scale
    
    -- Calculate positions for the symbols based on card.number and scaled size
    local positions = {}
    if number == 1 then
        -- Single symbol centered
        positions = {{x + width / 2, y + height / 2}}
    elseif number == 2 then
        -- Two symbols side by side
        local spacing = scaledWidth * 0.15 -- Spacing between symbols
        positions = {{x + width / 2 - spacing - scaledWidth / 2, y + height / 2},
                     {x + width / 2 + spacing + scaledWidth / 2, y + height / 2}}
    elseif number == 3 then
        -- Reduced spacing for three symbols to ensure they fit
        local spacing = scaledWidth * 0.15 -- Reduced spacing between symbols
        positions = {{x + width / 2 - spacing * 2 - scaledWidth, y + height / 2}, 
                     {x + width / 2, y + height / 2},
                     {x + width / 2 + spacing * 2 + scaledWidth, y + height / 2}}
    end

    -- Draw the symbols at each position with the calculated scale
    for _, pos in ipairs(positions) do
        -- Center the image at the position
        love.graphics.draw(image, 
                         pos[1] - scaledWidth / 2, -- Center horizontally
                         pos[2] - scaledHeight / 2, -- Center vertically
                         0, -- Rotation (none)
                         scale, scale -- Apply the calculated scale
        )
    end
end

-- Create a new card with the given attributes
function card.create(color, shape, number, fill)
    -- Generate a unique ID for this card
    local id = nextCardId
    nextCardId = nextCardId + 1
    
    -- Store the card's data internally
    cardObjects[id] = {
        id = id,
        color = color,
        shape = shape,
        number = number,
        fill = fill,
        bIsSelected = false
    }
    
    -- Return a lightweight reference to this card
    return { _cardId = id }
end

-- Get a card's color
function card.getColor(cardRef)
    local cardData = cardObjects[cardRef._cardId]
    return cardData.color
end

-- Get a card's shape
function card.getShape(cardRef)
    local cardData = cardObjects[cardRef._cardId]
    return cardData.shape
end

-- Get a card's number
function card.getNumber(cardRef)
    local cardData = cardObjects[cardRef._cardId]
    return cardData.number
end

-- Get a card's fill
function card.getFill(cardRef)
    local cardData = cardObjects[cardRef._cardId]
    return cardData.fill
end

-- Check if a card is selected
function card.isSelected(cardRef)
    local cardData = cardObjects[cardRef._cardId]
    return cardData.bIsSelected
end

-- Set a card's selection state
function card.setSelected(cardRef, bSelected)
    local cardData = cardObjects[cardRef._cardId]
    cardData.bIsSelected = bSelected
end

-- Toggle a card's selection state and return the new state
function card.toggleSelected(cardRef)
    local cardData = cardObjects[cardRef._cardId]
    cardData.bIsSelected = not cardData.bIsSelected
    return cardData.bIsSelected
end

-- Get internal card data (for use by the card module functions)
function card._getInternalData(cardRef)
    return cardObjects[cardRef._cardId]
end

-- Get any current animation data (could be used for game logic)
function card.getAnimatingCards()
    return animatingCards
end

-- Check if three cards form a valid Set
function card.isValidSet(card1Ref, card2Ref, card3Ref)
    local card1 = card._getInternalData(card1Ref)
    local card2 = card._getInternalData(card2Ref)
    local card3 = card._getInternalData(card3Ref)

    -- Helper function to check if all values are the same or all different
    local function checkAttribute(attr1, attr2, attr3)
        if attr1 == attr2 and attr2 == attr3 then
            -- All three are the same
            return true
        elseif attr1 ~= attr2 and attr2 ~= attr3 and attr1 ~= attr3 then
            -- All three are different
            return true
        else
            -- Some are the same, some are different
            return false
        end
    end
    
    -- Check each attribute (color, shape, number, fill)
    local colorValid = checkAttribute(card1.color, card2.color, card3.color)
    local shapeValid = checkAttribute(card1.shape, card2.shape, card3.shape)
    local numberValid = checkAttribute(card1.number, card2.number, card3.number)
    local fillValid = checkAttribute(card1.fill, card2.fill, card3.fill)
    
    -- It's a valid set only if ALL attributes pass the check
    return colorValid and shapeValid and numberValid and fillValid
end

return card
