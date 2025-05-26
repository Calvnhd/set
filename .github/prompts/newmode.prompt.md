# SPEC: New game modes with customizable settings
- I am expanding the rules for this game of Set 
- Presently, the game follows the rules of classic set very closely. 
- The core of these rules is the available attributes and the resulting deck (each card is unique covering every combination of attributes), the definition of a set, and the set of a set.
- My expansion will have the attributes (and therefore the deck), and the "set" size change over time.
- the definition of a set "for a given attribute all cards must be the same, or all different" will be consitent.  Only the size of the set will matter. 
- the size of the board will grow to accommodate the growing set and deck size
- Points awarded or subtracted may also change over time.  Multipliers and modifiers may be introduced at some point.
- The game will be played in rounds starting with a small deck.  End of round will add more cards. Subsequent rounds grow longer and more complex as the deck grows.
- I need to add an easy way to update the game rules such that I can create a series of rounds and levels for the player to go through.

## An example of a game
- player gets dealt a set of cards
- cards will have one of each of the 4 following attributes
    - NUMBER: 1, 2, 3
    - COLOR: green, blue, red, yellow
    - SHAPE: diamond, oval, squiggle, star
    - FILL: solid, empty, stripes 
- early in the game, the player will be dealt only a small subset of the full set of cards, and the definition of a set will be simpler. 
- the following is an example of the first few rounds in a game, demonstrating the round-based gameplay and the evolving rules over time
- evolving rules for a standard difficulty curve, plus roguelike elements in the future
- perhaps the player will choose which attribute gets added next
- note this is a big motivation for a design pattern that allows quick creation of new rounds with custom rules - i need the flexibility to experiment
### round 1 - very basic / tutorial round
attributes:
    - NUMBER: 1, 2
    - COLOR: green, blue
    - SHAPE: diamond
    - FILL: empty, solid
deck size: 8
set size: 2
board size: 2x2
### round 2 - add 1 attribute: red
attributes:
    - NUMBER: 1, 2
    - COLOR: green, blue, red
    - SHAPE: diamond
    - FILL: empty, solid
deck size: 12
set size: 2
board size: 2x2
### round 3 - add 1 attribute: oval
attributes:
    - NUMBER: 1, 2
    - COLOR: green, blue, red
    - SHAPE: diamond, oval
    - FILL: empty, solid
deck size: 24
set size: 2
board size: 3x3
### round 4 - add 1 attribute: stripes
attributes:
    - NUMBER: 1, 2
    - COLOR: green, blue, red
    - SHAPE: diamond, oval
    - FILL: empty, solid, stripes
deck size: 36
set size: 2
board size: 3x3

## Your task
- set up the code base such that it is easy to add new rounds to test
- i want an alternate game mode  -- e.g. main menu has a "classic" button that runs the current game, and "rogue" button that kicks off the first of a series of round with evolving rules
- i want to easily be able to customize the ruleset for each round in rogue mode, and the number of rounds.  
- write me a spec for the design changes that you would make to acheive this

