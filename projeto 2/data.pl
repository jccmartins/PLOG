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
     Ships Size (list with a pair with ship size and number of ships with that size)) 
*/

/* id1 - 10x10 */
data(id1, [ [[7,5], west], [[5,5], water], [[7,1], water] ],
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
          [[3,4],north],
          [[3,9],east],
          [[6,7],water],
          [[6,12],circle],
          [[8,3],water],
          [[10,2],west],
          [[12,8],south]
     ],
     [0,2,4,1,0,4,0,6,2,4,3,1],
     [1,1,2,2,1,5,1,6,1,1,3,3],
     [5-1,4-1,3-2,2-4,1-4]).

/* id7 - 10x10 */
data(id7, 
     [    
          [[1,8],north],
          [[4,9],west],
          [[6,3],north],
          [[9,1],circle]
     ],
     [4,1,4,4,3,3,1,2,2,1],
     [3,2,6,0,5,1,3,2,1,2],
     [5-1,4-1,3-2,2-3,1-4]).

/* id8 - 8x8 */
data(id8,
     [
          [[5,8],circle],
          [[6,3],north]
     ],
     [2,2,4,1,2,4,1,3],
     [2,3,3,4,2,1,1,3],
     [4-1,3-2,2-3,1-3]).

/* id9 - 7x7 */
data(id9,
     [
          [[2,5],north],
          [[4,3],south]
     ],
     [3,2,3,1,2,2,1],
     [4,0,4,0,5,0,1],
     [4-1,3-1,2-2,1-3]).

/* id10 - 6x6 */
data(id10,
     [
          [[2,5],north],
          [[6,1],water]
     ],
     [2,1,2,1,3,1],
     [4,0,3,0,2,1],
     [3-1,2-2,1-3]).
