-- Card Model - Data structure for cards separated from rendering
local CardModel = {}
CardModel.__index = CardModel

-- required modules
local Logger = require('core.Logger')

-- Card objects cache - storing internal data for all created cards
local cardObjects = {}
local nextCardId = 1

---------------
-- functions --
---------------

-- Create a new card with the given attributes
function CardModel.create(color, shape, number, fill)
    -- Logger.trace("Creating card: "..number..", "..color..", "..shape..", "..fill)
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
    return {
        _cardId = id
    }
end

-- Get a card's attributes
function CardModel.getColor(cardRef)
    local cardData = cardObjects[cardRef._cardId]
    return cardData.color
end

function CardModel.getShape(cardRef)
    local cardData = cardObjects[cardRef._cardId]
    return cardData.shape
end

function CardModel.getNumber(cardRef)
    local cardData = cardObjects[cardRef._cardId]
    return cardData.number
end

function CardModel.getFill(cardRef)
    local cardData = cardObjects[cardRef._cardId]
    return cardData.fill
end

-- Selection state management
function CardModel.isSelected(cardRef)
    local cardData = cardObjects[cardRef._cardId]
    return cardData.bIsSelected
end

function CardModel.setSelected(cardRef, bSelected)
    local cardData = cardObjects[cardRef._cardId]
    cardData.bIsSelected = bSelected
end

function CardModel.toggleSelected(cardRef)
    local cardData = cardObjects[cardRef._cardId]
    cardData.bIsSelected = not cardData.bIsSelected
    return cardData.bIsSelected
end

-- Get internal card data (for use by other modules)
function CardModel._getInternalData(cardRef)
    return cardObjects[cardRef._cardId]
end

-- Get all card data for a card reference
function CardModel.getAllData(cardRef)
    local data = cardObjects[cardRef._cardId]
    if data then
        return {
            id = data.id,
            color = data.color,
            shape = data.shape,
            number = data.number,
            fill = data.fill,
            bIsSelected = data.bIsSelected
        }
    end
    return nil
end

-- Convert card attributes to a formatted string for logging
function CardModel.cardAttributesToString(cardRef)
    if not cardRef or not cardRef._cardId then
        return " (invalid card reference)"
    end
    local cardData = cardObjects[cardRef._cardId]
    if not cardData then
        return " (card data not found)"
    end
    return
        string.format("| number:%d\t| %s\t| %s\t| %s", cardData.number, cardData.color, cardData.fill, cardData.shape)
end

return CardModel
