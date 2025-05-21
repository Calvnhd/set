-- Game logic and state management

local game = {}

-- Card collections
local deck = {}  -- Full deck of cards
local board = {} -- Cards currently in play

-- Card attributes
local COLORS = {"blue", "green", "red"}
local SHAPES = {"oval", "diamond", "squiggle"}
local NUMBER = {1, 2, 3}
local FILLS = {"solid", "stripes", "empty"}

-- Initialize the game state
function game.initialize()
    -- Create a new deck of Set cards
    game.createDeck()
    
    -- Shuffle the deck
    game.shuffleDeck()
    
    -- Print the entire deck for testing
    game.printDeck()
end

-- Create a deck of cards for the Set game
-- Each card has a unique combination of color, shape, number, and fill
function game.createDeck()
    deck = {}
    
    -- Generate all possible combinations of the four attributes
    for _, color in ipairs(COLORS) do
        for _, shape in ipairs(SHAPES) do
            for _, number in ipairs(NUMBER) do
                for _, fill in ipairs(FILLS) do
                    -- Create a new card with these attributes
                    local card = {
                        color = color,
                        shape = shape,
                        number = number,
                        fill = fill,
                        selected = false
                    }
                    
                    -- Add the card to the deck
                    table.insert(deck, card)
                end
            end
        end
    end
    
    -- The complete deck should have 81 cards (3^4 combinations)
    print("Created deck with " .. #deck .. " cards")
end

-- Shuffle the deck using Fisher-Yates algorithm
function game.shuffleDeck()
    math.randomseed(os.time())
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

-- Print the entire deck for testing purposes
function game.printDeck()
    print("==== PRINTING FULL DECK ====")
    for i, card in ipairs(deck) do
        print(string.format("Card %d: Color=%s, Shape=%s, Number=%d, Fill=%s", 
            i, card.color, card.shape, card.number, card.fill))
    end
    print("==== END OF DECK ====")
end

-- Update function called from love.update
function game.update(dt)
end

-- Draw function called from love.draw
function game.draw()
end

-- Handle keyboard input
function game.keypressed(key)
end

-- Handle mouse press events
function game.mousepressed(x, y, button)
end

-- Handle mouse release events
function game.mousereleased(x, y, button)
end

-- Export the game module
return game