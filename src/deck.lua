-- Deck management for Set card game
local deck = {}

-- Card attributes
local COLOR = {"blue", "green", "red"}
local SHAPE = {"oval", "diamond", "squiggle"}
local NUMBER = {1, 2, 3}
local FILL = {"solid", "stripes", "empty"}

-- The actual cards collection
local cards = {}

-- Create a deck of cards. Each card has a unique combination of color, shape, number, and fill
function deck.create()
    -- ensure we're beginning with an empty table
    cards = {}
    -- Generate all possible combinations of the four attributes
    for _, color in ipairs(COLOR) do
        for _, shape in ipairs(SHAPE) do
            for _, number in ipairs(NUMBER) do
                for _, fill in ipairs(FILL) do
                    local card = {
                        -- attributes
                        color = color,
                        shape = shape,
                        number = number,
                        fill = fill,
                        -- state
                        selected = false
                    }
                    -- Add newly created card to the deck
                    table.insert(cards, card)
                end
            end
        end
    end
    return cards
end

-- Shuffle the deck using Fisher-Yates algorithm
function deck.shuffle()
    math.randomseed(os.time())
    for i = #cards, 2, -1 do
        local j = math.random(i)
        cards[i], cards[j] = cards[j], cards[i]
    end
    return cards
end

-- Take a card from the top of the deck
function deck.takeCard()
    if #cards > 0 then
        return table.remove(cards, 1)
    else
        return nil
    end
end

-- Get the number of cards remaining in the deck
function deck.getCount()
    return #cards
end

-- Get all cards in the deck
function deck.getCards()
    return cards
end

return deck
