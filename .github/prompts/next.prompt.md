# FEATURE 1: fix card selection
- currently, if 3 cards are selected, they cannot be delselected
- update function game.mousepressed(x, y, button) to fix this problem.  Do not touch other parts of the codebase.
- the player should be able to select up to 3 cards.  
- the player should never be able to select more than 3 cards.
- If 3 cards are selected, and the player clicks on another un-selected card, nothing should happen.
- the player should be able to deselect a selected card by clicking on it.

# FEATURE 2: clearing card selection with other inputs
- card selection should be cleared when any input other than a mouse click is entered

# FEATURE 3: update score on incorrect set attempt
- when the player has selected 3 cards and presses "s" to check for a set, they should lose one point if they are incorrect
- keep the current implementation of gaining 1 point if correct.

# FEATURE 4: incorrect set visual indication
- when the player presses "s" but is incorrect on the set selection, the invalid set cards should display some visual indication of the error
- the invalid set cards should flash red, and then back to normal colour
- the flash should last 1 second.

# FEATURE 5: Score update visual indication
- every time the score updates, the score display text should throb
- a throb means the text should get slightly larger, back to original size, then slightly smaller, and then back to original size.  This ends the throb.
- the throb should take 1 second to complete.
