/* 
data(ID, 
     Initial Info
          [ [[Row,Column], Piece type], ...)
               Ship Piece Type can be:
                    north -> northernmost piece
                    east -> rightmost piece
                    west -> leftmost piece
                    south -> southernmost piece
                    single -> ship with only one piece; no ship pieces around it
                    water
     , 
     Per Row Data, 
     Per Column Data) 
*/
data(id1, [ [[7,5], east], [[5,5], water], [[7,1], water] ],
    [4,1,3,0,3,0,4,0,2,3],
    [1,4,1,0,4,4,1,3,1,1]).

data(id2, [], % said to have 70 solutions
     [2,4,3,3,2,4,1,1,0,0],
     [0,5,0,2,2,3,1,3,2,2]).
data(id3, [], % said to have 49874 solutions
     [1,3,2,2,2,2,2,3,1,2],
     [3,0,4,0,3,0,3,1,2,4]).

data(id4, [], % 1 solution
     [1,3,3,1,1,4,0,1,1,5],
     [0,0,1,4,1,5,2,1,6,0]).

