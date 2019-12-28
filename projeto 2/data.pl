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
                    single -> ship with only one piece; no ship pieces around it
                    water
     , 
     Per Row Data, 
     Per Column Data,
     Ships Size (list with a pair with ship size and number of ships with that size)) 
*/
data(id1, [ [[7,5], west], [[5,5], water], [[7,1], water] ],
    [4,1,3,0,3,0,4,0,2,3],
    [1,4,1,0,4,4,1,3,1,1],
    [4-1,3-2,2-3,1-4]).

data(id2, [], % said to have 70 solutions
     [2,4,3,3,2,4,1,1,0,0],
     [0,5,0,2,2,3,1,3,2,2],
     [4-1,3-2,2-3,1-4]).

data(id3, [], % said to have 49874 solutions
     [1,3,2,2,2,2,2,3,1,2],
     [3,0,4,0,3,0,3,1,2,4],
     [4-1,3-2,2-3,1-4]).

data(id4, [], % 1 solution
     [1,3,3,1,1,4,0,1,1,5],
     [0,0,1,4,1,5,2,1,6,0],
     [4-1,3-2,2-3,1-4]).

data(id5, [    [[1,14], east], 
               [[4,6], south],
               [[6,10], square],
               [[8,11], square],
               [[9,4], square],
               [[11,2], single],
               [[14,4], square]
          ],
          [3,2,1,1,2,5,2,7,1,3,3,1,1,1,1],
          [0,1,0,8,0,5,0,7,1,2,2,4,2,2,0],
          [5-1,4-2,3-3,2-4,1-4]).
