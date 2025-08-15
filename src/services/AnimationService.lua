-- AnimationService - description
local AnimationService = {}

-- Required modules
local Logger = require('core.Logger')

-- Animation tracking
local animatingCards = {}

-- Animation types
local ANIMATION_TYPES = {
    BURN = "burn",
    FLASH_RED = "flashRed"
}

---------------
-- functions --
---------------

-- Clear all animations
function AnimationService.clearAll()
    animatingCards = {}
    -- EventManager.emit(Events.ANIMATION.CLEARED)
end

-- Get all current animations
function AnimationService.getAnimations()
    return animatingCards
end

-- Create a flash red animation
function AnimationService.createFlashRedAnimation(cardRef, x, y, width, height, onComplete)
    Logger.trace("AnimationService", "createFlashRedAnimation")
    local CardModel = require('models.CardModel')
    local cardData = CardModel._getInternalData(cardRef)

    local animId = "flash_" .. cardData.id .. "_" .. os.time()

    -- @todo make this an object in like a builder pattern or something?
    local anim = {
        id = animId,
        card = cardData,
        cardRef = cardRef,
        x = x,
        y = y,
        width = width,
        height = height,
        type = ANIMATION_TYPES.FLASH_RED,
        duration = 1.0,
        timer = 0,
        flashIntensity = 0,
        onComplete = onComplete,
        bCompletionCalled = false
    }
    table.insert(animatingCards, anim)
    -- EventManager.emit(Events.ANIMATION.STARTED, animId, ANIMATION_TYPES.FLASH_RED, cardRef)

    return anim
end

-- Update all animations
function AnimationService.update(dt)
    local animationsCompleted = {}

    -- Process each animating card
    for i, anim in ipairs(animatingCards) do
        -- Update the animation timer
        anim.timer = anim.timer + dt

        -- Calculate progress (0 to 1)
        local progress = math.min(anim.timer / anim.duration, 1)

        -- Update animation-specific properties
        if anim.type == ANIMATION_TYPES.BURN then
            -- AnimationService._updateBurnAnimation(anim, progress)
        elseif anim.type == ANIMATION_TYPES.FLASH_RED then
            AnimationService._updateFlashRedAnimation(anim, progress)
        end

        -- Check if animation is complete
        if progress >= 1 then
            table.insert(animationsCompleted, i)

            -- Call completion callback if it hasn't been called already
            -- if anim.onComplete and not anim.bCompletionCalled then
                -- anim.onComplete()
                -- EventManager.emit(Events.ANIMATION.COMPLETED, anim.id, anim.type)
            -- end
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

-- Update flash red animation properties
function AnimationService._updateFlashRedAnimation(anim, progress)
    Logger.trace("AnimationService", "_updateFlashRedAnimation")

    -- Calculate the flash intensity (peak at middle of animation)
    if progress < 0.5 then
        anim.flashIntensity = progress * 2 -- 0 to 1 in first half
    else
        anim.flashIntensity = (1 - progress) * 2 -- 1 to 0 in second half
    end
end

-- module return
return AnimationService
