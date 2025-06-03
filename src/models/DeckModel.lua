-- DeckModel
local DeckModel = {}

-- required modules
local Logger = require('core.Logger')
local CardModel = require('models.CardModel')
local Constants = require('config.Constants')

-- local variables
local cards = {}

local DEFAULT_COLOR = {Constants.COLOR.BLUE, Constants.COLOR.GREEN, Constants.COLOR.RED}
local DEFAULT_SHAPE = {Constants.SHAPE.DIAMOND, Constants.SHAPE.OVAL, Constants.SHAPE.SQUIGGLE}
local DEFAULT_NUMBER = {1, 2, 3}
local DEFAULT_FILL = {Constants.FILL.EMPTY, Constants.FILL.SOLID, Constants.FILL.STRIPES}

---------------
-- functions --
---------------

function DeckModel.printDeck()
    Logger.trace("--- BEGIN DECK DUMP ---")
    Logger.trace(string.format("Deck contains %d cards", #cards))
    
    for i, cardRef in ipairs(cards) do
        if not cardRef then
            Logger.trace(string.format("[%d]: nil card reference", i))
        elseif not cardRef._cardId then
            Logger.trace(string.format("[%d]: invalid card reference (missing _cardId)", i))
        else
            local cardData = CardModel._getInternalData(cardRef)
            if not cardData then
                Logger.trace(string.format("[%d]: card ID %s has no associated data", i, tostring(cardRef._cardId)))
            else
                Logger.trace(string.format("[%d]: %s %s %s %d (ID: %s)", 
                    i, 
                    tostring(cardData.color),
                    tostring(cardData.shape),
                    tostring(cardData.fill),
                    cardData.number,
                    tostring(cardRef._cardId)
                ))
            end
        end
    end
    Logger.trace("--- END DECK DUMP ---")
end

-- Create a deck of cards with default attributes (classic mode)
function DeckModel.createDefault()
    Logger.trace("Creating default deck")
    return DeckModel.createWithAttributes(DEFAULT_COLOR, DEFAULT_SHAPE, DEFAULT_NUMBER, DEFAULT_FILL)
end

-- Create a deck with custom attributes (rogue mode)
function DeckModel.createWithAttributes(colors, shapes, numbers, fills)
    cards = {}

    -- Use provided attributes or defaults
    local colorList = colors or DEFAULT_COLOR
    local shapeList = shapes or DEFAULT_SHAPE
    local numberList = numbers or DEFAULT_NUMBER
    local fillList = fills or DEFAULT_FILL

    -- Generate all possible combinations of the attributes
    for _, color in ipairs(colorList) do
        for _, shape in ipairs(shapeList) do
            for _, number in ipairs(numberList) do
                for _, fill in ipairs(fillList) do
                    local cardRef = CardModel.create(color, shape, number, fill)
                    table.insert(cards, cardRef)
                end
            end
        end
    end
    DeckModel.printDeck()
    return cards
end

-- Create deck from round configuration
function DeckModel.createFromConfig(config)
    Logger.trace("Creating deck from config")
    if not config or not config.attributes then
        return DeckModel.create()
    end
    local attrs = config.attributes
    return DeckModel.createWithAttributes(attrs.color, attrs.shape, attrs.number, attrs.fill)
end

-- Shuffle the deck using Fisher-Yates algorithm
function DeckModel.shuffle()
    Logger.trace("Shuffling deck")
    math.randomseed(os.time())
    for i = #cards, 2, -1 do
        local j = math.random(i)
        cards[i], cards[j] = cards[j], cards[i]
    end
    DeckModel.printDeck()
    return cards
end

-- Take a card from the top of the deck
function DeckModel.takeCard()
    Logger.trace("Removing card from deck")
    if #cards > 0 then
        local card = table.remove(cards, 1)
        Logger.trace(string.format("Deck contains %d cards", #cards))
        if card then
            if not card._cardId then
                Logger.trace("DeckModel Took card with missing _cardId")
            else
                local cardData = CardModel._getInternalData(card)
                if not cardData then
                    Logger.trace(string.format("DeckModel Took card with ID %s (no associated data)", tostring(card._cardId)))
                else
                    Logger.trace(string.format("DeckModel Took card: %s %s %s %d (ID: %s)", 
                        tostring(cardData.color),
                        tostring(cardData.shape),
                        tostring(cardData.fill),
                        cardData.number,
                        tostring(card._cardId)
                    ))
                end
            end
        end
        return card
    else
        Logger.error("DeckModel.takeCard() returning nil")
        error("DeckModel.takeCard() returning nil")
        return nil
    end
end

-- Return a card to the deck
function DeckModel.returnCard(cardRef)
    Logger.trace("Returning card to deck")
    DeckModel.printDeck()
    table.insert(cards, cardRef)
end

-- Get the number of cards remaining in the deck
function DeckModel.getCountRemaining()
    return #cards
end

-- Check if deck is empty
function DeckModel.isEmpty()
    return #cards == 0
end

return DeckModel
