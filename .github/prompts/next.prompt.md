# Feature 1
- fix the score display and cards remaining text display position
- the score and cards remaining text should both be aligned in the top right corner
- the score should be displayed above the cards remaining
- the first letter of both display strings should be vertically aligned

# Feature 2
- add a new key pressed input
- a player will press the key "x" if they believe there is no set available on the board
- write a new function to handle this input
- on pressing "x", check if there is a set on the board and take the appropriate action described below

## yes set, player is incorrect
- if there is a set on the board and the player is incorrect, the set should be removed from the board and discarded 
- discarded cards never return to the deck until a new game begins and the cards are re-dealt
- the player loses one point for being incorrect

## no set, player is correct
- if there is a set on the board and the player is correct, half of the cards on the board are randomly selected to be removed from the board
- the board is refilled from the deck
- the cards that were just removed from the board are returned to the deck
- ensure that the board is never refilled with cards that were just removed
- the player gains one point for being correct

# feature 3
- create a simple animation that shows the "burning" of discarded cards
- this animation should play when the player incorrectly inputs "x" for no set
- the code for this animation should be integrated into the existing code such that it is re-useable for any other future scenarios where a card is "burned" or discarded
- the animation should show a card fading to a red color, and then fading to transparent
- after the animation is complete, the card removal code logic can return