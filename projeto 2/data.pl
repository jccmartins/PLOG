/* 
data(ID, 
     Initial Info
          [ [[Row,Column], Piece type], ...)
               Row, Column start at 1
               Ship Piece Type can be:
                    north -> northernmost piece
                    east -> rightmost piece
                    west -> leftmost piece
                    south -> southernmost piece
                    square -> ship piece with pieces either top and bottom or left and right
                    circle -> ship with only one piece; no ship pieces around it
                    water
     , 
     Per Row Data, 
     Per Column Data,
     Ships Size
          -list with a pair with ship size and number of ships with that size
     ) 
*/

/* id1 - 10x10 */
data(id1, [ [[7,5], circle], [[5,5], water], [[7,1], water] ],
    [4,1,3,0,3,0,4,0,2,3],
    [1,4,1,0,4,4,1,3,1,1],
    [4-1,3-2,2-3,1-4]).

/* id2 - 10x10 */
data(id2, [], % said to have 70 solutions
     [2,4,3,3,2,4,1,1,0,0],
     [0,5,0,2,2,3,1,3,2,2],
     [4-1,3-2,2-3,1-4]).

/* id4 - 10x10 */
data(id4, [], % 1 solution
     [1,3,3,1,1,4,0,1,1,5],
     [0,0,1,4,1,5,2,1,6,0],
     [4-1,3-2,2-3,1-4]).

/* id5 - 15x15 */
data(id5, 
     [    
          [[1,14], east], 
          [[4,6], south],
          [[6,10], square],
          [[8,11], square],
          [[9,4], square],
          [[11,2], circle],
          [[14,4], square]
     ],
     [3,2,1,1,2,5,2,7,1,3,3,1,1,1,1],
     [0,1,0,8,0,5,0,7,1,2,2,4,2,2,0],
     [5-1,4-2,3-3,2-4,1-4]).

/* id6 - 12x12 */
data(id6, 
     [    
          [[2,2],water],
          [[6,3],west],
          [[11,11],west]
     ],
     [0,2,2,1,0,4,5,3,3,2,5,0],
     [3,2,1,5,0,5,2,0,2,4,2,1],
     [5-1,4-1,3-2,2-4,1-4]).

/* id7 - 10x10 */
data(id7, 
     [    
          [[1,4],north],
          [[3,1],north],
          [[8,1],west],
          [[5,5],north]
     ],
     [2,4,1,2,2,5,1,3,3,2],
     [6,2,2,2,5,0,2,3,3,0],
     [5-1,4-1,3-2,2-3,1-4]).

/* id8 - 8x8 */
data(id8,
     [
          [[3,2],circle],
          [[7,4],north],
          [[7,8],circle]
     ],
     [6,0,4,1,1,1,4,2],
     [5,2,1,4,0,3,2,2],
     [4-1,3-2,2-3,1-3]).

/* id9 - 7x7 */
data(id9,
     [
          [[3,2],east],
          [[6,7],circle]
     ],
     [5,0,3,1,3,1,1],
     [1,4,2,1,4,0,2],
     [4-1,3-1,2-2,1-3]).

/* id10 - 6x6 */
data(id10,
     [
          [[5,1],water],
          [[2,3],water]
     ],
     [1,4,0,1,3,1],
     [4,0,1,1,2,2],
     [3-1,2-2,1-3]).


/* id11 - 15x15 */
data(id11, 
     [    
          [[11,1], north], 
          [[6,4], south],
          [[14,7], east],
          [[3,8], circle],
          [[7,9], square],
          [[1,10], circle],
          [[13,10], east],
          [[4,13],west],
          [[2,14],circle],
          [[4,15],east]
     ],
     [1,2,3,5,2,2,1,3,1,4,1,4,2,3,0],
     [2,4,0,4,0,1,1,1,6,2,0,3,5,4,1],
     [5-1,4-2,3-3,2-4,1-4]).

/* id12 - 15x15 */
data(id12, 
     [    
          [[2,4], water], 
          [[1,10], circle],
          [[2,14], circle],
          [[3,8], circle],
          [[4,12], water],
          [[4,15], east],
          [[7,9], square],
          [[11,1],north],
          [[14,7],east],
          [[14,13],circle]
     ],
     [1,2,3,5,2,2,1,3,1,4,1,4,2,3,0],
     [2,4,0,4,0,1,1,1,6,2,0,3,5,4,1],
     [5-1,4-2,3-3,2-4,1-4]).