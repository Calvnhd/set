-- Deck Model - Manages deck operations with event notifications

local CardModel = require('models.cardModel')
local EventManager = require('core.eventManager')

local DeckModel = {}

-- Card attributes
local COLOR = {"blue", "green", "red"}
local SHAPE = {"oval", "diamond", "squiggle"}
local NUMBER = {1, 2, 3}
local FILL = {"solid", "stripes", "empty"}

-- The actual cards collection
local cards = {}

-- Create a deck of cards
function DeckModel.create()
    cards = {}
    
    -- Generate all possible combinations of the four attributes
    for _, color in ipairs(COLOR) do
        for _, shape in ipairs(SHAPE) do
            for _, number in ipairs(NUMBER) do
                for _, fill in ipairs(FILL) do
                    local cardRef = CardModel.create(color, shape, number, fill)
                    table.insert(cards, cardRef)
                end
            end
        end
    end
    
    EventManager.emit('deck:created', #cards)
    return cards
end

-- Shuffle the deck using Fisher-Yates algorithm
function DeckModel.shuffle()
    math.randomseed(os.time())
    for i = #cards, 2, -1 do
        local j = math.random(i)
        cards[i], cards[j] = cards[j], cards[i]
    end
    
    EventManager.emit('deck:shuffled')
    return cards
end

-- Take a card from the top of the deck
function DeckModel.takeCard()
    if #cards > 0 then
        local card = table.remove(cards, 1)
        EventManager.emit('deck:cardTaken', card, #cards)
        return card
    else
        EventManager.emit('deck:empty')
        return nil
    end
end

-- Return a card to the deck
function DeckModel.returnCard(cardRef)
    table.insert(cards, cardRef)
    EventManager.emit('deck:cardReturned', cardRef, #cards)
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
