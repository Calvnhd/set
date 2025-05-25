-- Animation Service - Animation management separated from card rendering

local EventManager = require('core.eventManager')

local AnimationService = {}

-- Animation tracking
local animatingCards = {}

-- Animation types
local ANIMATION_TYPES = {
    BURN = "burn",
    FLASH_RED = "flashRed"
}

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
            AnimationService._updateBurnAnimation(anim, progress)
        elseif anim.type == ANIMATION_TYPES.FLASH_RED then
            AnimationService._updateFlashRedAnimation(anim, progress)
        end
        
        -- Check if animation is complete
        if progress >= 1 then
            table.insert(animationsCompleted, i)
            
            -- Call completion callback if it hasn't been called already
            if anim.onComplete and not anim.bCompletionCalled then
                anim.onComplete()
                EventManager.emit('animation:completed', anim.id, anim.type)
            end
        end
    end
    
    -- Remove completed animations in reverse order to avoid index issues
    table.sort(animationsCompleted, function(a, b) return a > b end)
    for _, index in ipairs(animationsCompleted) do
        table.remove(animatingCards, index)
    end
end

-- Update burn animation properties
function AnimationService._updateBurnAnimation(anim, progress)
    -- Calculate which phase we're in based on progress
    local phaseLength = 1 / 4 -- Each phase is 1/4 of the total animation
    anim.phase = math.min(4, math.floor(progress / phaseLength) + 1)
    anim.phaseProgress = (progress - (anim.phase - 1) * phaseLength) / phaseLength
    
    -- Handle early completion callback for phase 4
    if anim.phase == 4 and anim.phaseProgress > 0.9 and not anim.bCompletionCalled then
        anim.bCompletionCalled = true
        if anim.onComplete then
            anim.onComplete()
        end
    end
end

-- Update flash red animation properties
function AnimationService._updateFlashRedAnimation(anim, progress)
    -- Calculate the flash intensity (peak at middle of animation)
    if progress < 0.5 then
        anim.flashIntensity = progress * 2 -- 0 to 1 in first half
    else
        anim.flashIntensity = (1 - progress) * 2 -- 1 to 0 in second half
    end
end

-- Create a burn animation
function AnimationService.createBurnAnimation(cardRef, x, y, width, height, onComplete)
    local CardModel = require('models.cardModel')
    local cardData = CardModel._getInternalData(cardRef)
    
    local animId = "burn_" .. cardData.id .. "_" .. os.time()
    
    local anim = {
        id = animId,
        card = cardData,
        cardRef = cardRef,
        x = x,
        y = y,
        width = width,
        height = height,
        type = ANIMATION_TYPES.BURN,
        duration = 1.5,
        timer = 0,
        phase = 1,
        phaseProgress = 0,
        opacity = 1,
        onComplete = onComplete,
        bCompletionCalled = false
    }
    
    table.insert(animatingCards, anim)
    EventManager.emit('animation:started', animId, ANIMATION_TYPES.BURN, cardRef)
    
    return anim
end

-- Create a flash red animation
function AnimationService.createFlashRedAnimation(cardRef, x, y, width, height, onComplete)
    local CardModel = require('models.cardModel')
    local cardData = CardModel._getInternalData(cardRef)
    
    local animId = "flash_" .. cardData.id .. "_" .. os.time()
    
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
    EventManager.emit('animation:started', animId, ANIMATION_TYPES.FLASH_RED, cardRef)
    
    return anim
end

-- Get all current animations
function AnimationService.getAnimations()
    return animatingCards
end

-- Get animations for a specific card
function AnimationService.getCardAnimations(cardRef)
    local CardModel = require('models.cardModel')
    local cardData = CardModel._getInternalData(cardRef)
    local cardAnimations = {}
    
    for _, anim in ipairs(animatingCards) do
        if anim.card.id == cardData.id then
            table.insert(cardAnimations, anim)
        end
    end
    
    return cardAnimations
end

-- Clear all animations
function AnimationService.clearAll()
    animatingCards = {}
    EventManager.emit('animations:cleared')
end

-- Check if any animations are running
function AnimationService.hasActiveAnimations()
    return #animatingCards > 0
end

return AnimationService
