-- DeckModel
local DeckModel = {}

-- required modules
local Logger = require('core.Logger')
local CardModel = require('models.cardModel')
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
    return cards
end

-- Take a card from the top of the deck
function DeckModel.takeCard()
    Logger.trace("Removing card from deck")
    if #cards > 0 then
        local card = table.remove(cards, 1)
        return card
    else
        Logger.warning("DeckModel.takeCard() returning nil")
        return nil
    end
end

-- Return a card to the deck
function DeckModel.returnCard(cardRef)
    Logger.trace("Returning card to deck")
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
