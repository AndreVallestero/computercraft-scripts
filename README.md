# computercraft-scripts
A collection of high quality scripts for ComputerCraft

### branchrec
- `pastebin get P7bwwSQY branchrec`
- A highly optimized and automated branch mining script with powerful recursion-based AI
- For mining turtles
- Place a block of fliter items in the top row (cobble, andesite, diorite, granite)
- To guarantee space for an item, place one of it in one of the slots of the bottom three rows
- When entering y coord, stand at the same foot level as turtle and use y value from f3 menu
- Stay in the same chunks as the turtle or else it might get lost
- Recommended to only put one block of coal each run to limit range
- For best efficiency place turtle at y 14 and space holes 16 to 32 blocks away.

### branchrec2
- TODO: make a new script that doesn't look left or right unless it finds an ore
  - when doing general search, it should go in a archimedes spiral search pattern up to a certain distance, only ever checking the blocks above, infront, and below, leaving once space between the spiral layers. Once it reaches the edge of the box, it should go one layer down and go directly underneath the walls of the previous level, going back to the center. This will allow it to check the old walls by checking the block above each time it moves. This is the optimal search pattern as it reduces turning while still checking every block
  - example pattern: 
  ```
  Layer 1
  XXXXXX
  X   
  X XXXX
  X X  X
  X XX X
  X    X
  XXXXXX

  Layer 2
   
   XXXXX   
   X
   X  XX
   X   X
   XXXXX

  ```
  - TODO: maybe skip every other layer, and have 3 spaces between the spiral layers, that way we can catch the edges of veins which is technically more efficient.
- TODO: auto drop off and refuel
