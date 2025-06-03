-- Deck Model - Manages deck operations with event notifications
local CardModel = require('models.cardModel')
local EventManager = require('core.eventManager')
local Events = require('core.events')

local DeckModel = {}

-- Default card attributes (for classic mode)
local DEFAULT_COLOR = {"blue", "green", "red"}
local DEFAULT_SHAPE = {"oval", "diamond", "squiggle"}
local DEFAULT_NUMBER = {1, 2, 3}
local DEFAULT_FILL = {"solid", "stripes", "empty"}

-- The actual cards collection
local cards = {}

-- Create a deck of cards with default attributes (classic mode)
function DeckModel.create()
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

    EventManager.emit(Events.DECK.CREATED, #cards)
    return cards
end

-- Create deck from round configuration
function DeckModel.createFromConfig(config)
    if not config or not config.attributes then
        return DeckModel.create()
    end

    local attrs = config.attributes
    return DeckModel.createWithAttributes(attrs.color, attrs.shape, attrs.number, attrs.fill)
end

-- Shuffle the deck using Fisher-Yates algorithm
function DeckModel.shuffle()
    math.randomseed(os.time())
    for i = #cards, 2, -1 do
        local j = math.random(i)
        cards[i], cards[j] = cards[j], cards[i]
    end

    EventManager.emit(Events.DECK.SHUFFLED)
    return cards
end

-- Take a card from the top of the deck
function DeckModel.takeCard()
    if #cards > 0 then
        local card = table.remove(cards, 1)
        EventManager.emit(Events.DECK.CARD_TAKEN, card, #cards)
        return card
    else
        EventManager.emit(Events.DECK.EMPTY)
        return nil
    end
end

-- Return a card to the deck
function DeckModel.returnCard(cardRef)
    table.insert(cards, cardRef)
    EventManager.emit(Events.DECK.CARD_RETURNED, cardRef, #cards)
end

-- Get the number of cards remaining in the deck
function DeckModel.getCount()
    return #cards
end

-- Get all cards in the deck (for internal use)
function DeckModel.getCards()
    return cards
end

-- Check if deck is empty
function DeckModel.isEmpty()
    return #cards == 0
end

return DeckModel
