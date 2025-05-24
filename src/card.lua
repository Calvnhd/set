-- Card module for Set game - responsible for card appearance and animations

local card = {}

-- Store card images
local cardImages = {}

-- Animation tracking
local animatingCards = {} -- animation state information each currently animating card

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
            stripes = love.graphics.newImage("images/squiggle-stripe-54x96.png"),
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
    local animationsCompleted = {}

    -- Process each animating card
    for i, anim in ipairs(animatingCards) do
        -- Update the animation timer
        anim.timer = anim.timer + dt
        -- Calculate progress (0 to 1)
        local progress = math.min(anim.timer / anim.duration, 1)
        -- Update the card's animation properties based on progress
        if anim.type == "burn" then
            -- Calculate which phase we're in based on progress
            local phaseLength = 1 / 4 -- Each phase is 1/4 of the total animation
            anim.phase = math.min(4, math.floor(progress / phaseLength) + 1)
            -- Calculate progress within the current phase (0 to 1)
            anim.phaseProgress = (progress - (anim.phase - 1) * phaseLength) / phaseLength
            -- Phase-specific updates will be handled in the drawing function
        elseif anim.type == "fadeIn" then
            -- Simple fade in - opacity increases with progress
            anim.opacity = progress
        end
        -- Check if animation is complete
        if progress >= 1 then
            table.insert(animationsCompleted, i)
            if anim.onComplete then
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
function card.animateBurn(cardData, x, y, width, height, onComplete)
    local anim = {
        card = cardData,
        x = x,
        y = y,
        width = width,
        height = height,
        type = "burn",
        duration = 2.0, -- Animation takes 2 seconds
        timer = 0,
        phase = 1, -- Start with phase 1
        phaseProgress = 0, -- Progress within the current phase
        opacity = 1, -- Start fully visible
        onComplete = onComplete
    }
    table.insert(animatingCards, anim)
    return anim
end

-- Function to animate a card fading in
function card.animateFadeIn(cardData, x, y, width, height, onComplete)
    local anim = {
        card = cardData,
        x = x,
        y = y,
        width = width,
        height = height,
        type = "fadeIn",
        duration = 1.0, -- Animation takes 1 second
        timer = 0,
        opacity = 0, -- Start invisible
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
        elseif anim.type == "fadeIn" then
            card.drawFadingInCard(anim)
        end
    end
end

-- Draw a card with fade-in effect
function card.drawFadingInCard(anim)
    -- Draw card with opacity based on animation progress
    love.graphics.setColor(1, 1, 1, anim.opacity)
    love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)
    -- Draw border with opacity
    love.graphics.setColor(0, 0, 0, anim.opacity)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)
    -- Set color for the card symbols
    if anim.card.color == "red" then
        love.graphics.setColor(0.85, 0.15, 0.15, anim.opacity) -- Red tint
    elseif anim.card.color == "green" then
        love.graphics.setColor(0.15, 0.65, 0.25, anim.opacity) -- Green tint
    elseif anim.card.color == "blue" then
        love.graphics.setColor(0.15, 0.35, 0.75, anim.opacity) -- Blue tint
    end
    -- Get the image for this shape and fill
    local image = cardImages[anim.card.shape][anim.card.fill]
    if not image then
        return
    end
    
    -- Draw the symbols with calculated positions
    card.drawSymbols(image, anim.card.number, anim.x, anim.y, anim.width, anim.height)
end

-- Draw a card with burning effect
function card.drawBurningCard(anim)
    -- Different drawing logic depending on which phase we're in
    local phase = anim.phase
    local progress = anim.phaseProgress

    if phase == 1 then
        -- Phase 1: Background fades to medium red, shapes fade to black

        -- Draw card background with increasing red tint
        local redAmount = 0.6 * progress -- Medium red
        love.graphics.setColor(1, 1 - redAmount, 1 - redAmount, 1)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)

        -- Draw border with slight red tint
        love.graphics.setColor(1, 0.3, 0.3, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)

        -- Set color for the shapes - fade toward black
        local blackAmount = progress
        if anim.card.color == "red" then
            love.graphics.setColor(0.85 * (1 - blackAmount), 0.15 * (1 - blackAmount), 0.15 * (1 - blackAmount), 1)
        elseif anim.card.color == "green" then
            love.graphics.setColor(0.15 * (1 - blackAmount), 0.65 * (1 - blackAmount), 0.25 * (1 - blackAmount), 1)
        elseif anim.card.color == "blue" then
            love.graphics.setColor(0.15 * (1 - blackAmount), 0.35 * (1 - blackAmount), 0.75 * (1 - blackAmount), 1)
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
        love.graphics.setColor(darkRed, darkGreen, darkBlue, 1)

    elseif phase == 4 then
        -- Phase 4: Card fades from opaque to transparent
        local opacity = 1 - progress

        -- Draw card with dark red and fading opacity
        local darkRed = 0.1
        local darkGreen = 0
        local darkBlue = 0

        -- Draw card background with fading opacity
        love.graphics.setColor(darkRed, darkGreen, darkBlue, opacity)
        love.graphics.rectangle("fill", anim.x, anim.y, anim.width, anim.height, 8, 8)

        -- Draw border with fading opacity
        love.graphics.setColor(darkRed + 0.2, darkGreen, darkBlue, opacity)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", anim.x, anim.y, anim.width, anim.height, 8, 8)

        -- No need to draw shapes at this point
        return
    end

    -- Only draw shapes for phases 1-3 (phase 4 returns early)
    -- Get the image for this shape and fill
    local image = cardImages[anim.card.shape][anim.card.fill]
    if not image then
        return
    end

    -- Draw the symbols with calculated positions
    card.drawSymbols(image, anim.card.number, anim.x, anim.y, anim.width, anim.height)
end

-- Draw a single card
function card.draw(cardData, x, y, width, height, bIsSelected, bIsInHint)
    -- Draw card background
    if cardData.selected then
        love.graphics.setColor(0.9, 0.9, 0.7) -- Slight yellow tint for selected cards
    else
        love.graphics.setColor(1, 1, 1) -- White background for normal cards
    end
    love.graphics.rectangle("fill", x, y, width, height, 8, 8) -- Rounded corners
    
    -- Draw border
    if cardData.selected then
        love.graphics.setColor(1, 1, 0) -- Yellow highlight for selected cards
        love.graphics.setLineWidth(4)
    elseif bIsInHint then
        love.graphics.setColor(0, 0.8, 0.8) -- Cyan highlight for hint cards
        love.graphics.setLineWidth(4)
    else
        love.graphics.setColor(0, 0, 0) -- Black border for normal cards
        love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle("line", x, y, width, height, 8, 8)
    
    -- Set color based on card color for tinting the white images
    if cardData.color == "red" then
        love.graphics.setColor(0.85, 0.15, 0.15) -- Slightly deeper red
    elseif cardData.color == "green" then
        love.graphics.setColor(0.15, 0.65, 0.25) -- Softer, more natural green
    elseif cardData.color == "blue" then
        love.graphics.setColor(0.15, 0.35, 0.75) -- Brighter, royal blue
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

-- Get any current animation data (could be used for game logic)
function card.getAnimatingCards()
    return animatingCards
end

return card
