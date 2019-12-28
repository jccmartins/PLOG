:-use_module(library(clpfd)).
:-use_module(library(lists)).

:-consult('display.pl').
:-consult('data.pl').
:-consult('utils.pl').

/* constrain cell value */
constrainCell(_,0,_,0).
constrainCell(_,_,0,0).
constrainCell(_,11,_,0).
constrainCell(_,_,11,0).
constrainCell(Vars, Row, Column, Value) :-
    N is (Row-1)*10+Column,
    nth1(N, Vars, Value).

/* set margin of ship piece to 0 considering its type (north,east,west or single) */
constrainMargin(Vars, Row, Column, ShipPiece) :-
    TopRow is Row-1,
    BottomRow is Row+1,
    LeftColumn is Column-1,
    RightColumn is Column+1,
    (ShipPiece == single ->
        constrainCell(Vars, TopRow, Column, 0),      
        constrainCell(Vars, Row, LeftColumn, 0),    
        constrainCell(Vars, Row, RightColumn, 0),    
        constrainCell(Vars, BottomRow, Column, 0);
    ShipPiece == north ->
        constrainCell(Vars, TopRow, Column, 0),      
        constrainCell(Vars, Row, LeftColumn, 0),    
        constrainCell(Vars, Row, RightColumn, 0),    
        constrainCell(Vars, BottomRow, Column, 1),
    ShipPiece == east ->
        constrainCell(Vars, TopRow, Column, 0),   
        constrainCell(Vars, Row, LeftColumn, 1),
        constrainCell(Vars, Row, RightColumn, 0),   
        constrainCell(Vars, BottomRow, Column, 0);
    ShipPiece == west ->
        constrainCell(Vars, TopRow, Column, 0),      
        constrainCell(Vars, Row, LeftColumn, 0),    
        constrainCell(Vars, Row, RightColumn, 1),  
        constrainCell(Vars, BottomRow, Column, 0); 
    ShipPiece == south ->     
        constrainCell(Vars, TopRow, Column, 1),
        constrainCell(Vars, Row, LeftColumn, 0),    
        constrainCell(Vars, Row, RightColumn, 0),    
        constrainCell(Vars, BottomRow, Column, 0)).

/* fills board with initial info */
fillBoardWithInfo([], _).
fillBoardWithInfo([H|T], Vars):-
    [[Row, Column], PieceType] = H,
    N is (Row-1)*10+Column,
    (PieceType == water ->
        nth1(N, Vars, 0);
    nth1(N,Vars,1),    
    constrainMargin(Vars, Row, Column, PieceType)),
    fillBoardWithInfo(T, Vars).

/* constrain number of ship pieces there are in each row or column */
constrain([], []).
constrain([H|T], [Constraint|ConstraintsTail]) :-
    global_cardinality(H, [1-Constraint,0-_]),
    constrain(T, ConstraintsTail).

/* constrain ships so there are 10 ships on the board (1-4, 2-3, 3-2, 4-1) */
constrainShips(_, []).
constrainShips(Vars, [Ship|ShipsTail]) :-
    ship(Ax, SizeX, Ay, SizeY) = Ship,
    constrainShipX(Vars, Ax, Ay, SizeX),
    constrainShipY(Vars, Ax, Ay, SizeY),
    constrainShips(Vars, ShipsTail).

constrainShipX(_,_,_,1).
constrainShipX(Vars, Ax, Ay, SizeX) :-
    N #= (Ay-1)*10+Ax,
    nth1(N, Vars, 1),
    NewAx #= Ax+1,
    NewSizeX #= SizeX-1,
    constrainShipX(Vars, NewAx, Ay, NewSizeX).
    
constrainShipY(_,_,_,1).
constrainShipY(Vars, Ax, Ay, SizeY) :-
    N #= (Ay-1)*10+Ax,
    nth1(N, Vars, 1),
    NewAy #= Ay+1,
    NewSizeY #= SizeY-1,
    constrainShipY(Vars, Ax, NewAy, NewSizeY).

/* constrain ships to be non adjacent */
constrainDiagonals(_, 11, _).

constrainDiagonals(Board, Line, 11) :-
    BottomLine is Line+1,
    constrainDiagonals(Board, BottomLine, 1).
    
constrainDiagonals(Board, Line, Column) :-
    getValueFromMatrix(Board, Line, Column, Value),
    TopLine is Line-1,
    BottomLine is Line+1,
    LeftColumn is Column-1,
    RightColumn is Column+1,
    getValueFromMatrix(Board, TopLine, LeftColumn, TopLeft),
    getValueFromMatrix(Board, TopLine, RightColumn, TopRight),
    getValueFromMatrix(Board, BottomLine, LeftColumn, BottomLeft),
    getValueFromMatrix(Board, BottomLine, RightColumn, BottomRight),
    Value+TopLeft #=< 1,
    Value+TopRight #=< 1,
    Value+BottomLeft #=< 1,
    Value+BottomRight #=< 1,
    constrainDiagonals(Board, Line, RightColumn).

/* creates list of ships with same size */
createShipsGroup(_, [], [], []).
createShipsGroup(SizeWithMargin, [X|XsTail], [Y|YsTail], ShipsGroup) :-
    (SizeWithMargin \= 2 ->
        Width in {2, SizeWithMargin},
        Height in {2, SizeWithMargin},
        Width #\= Height;
    Width = 2,
    Height = 2
    ),
    X+Width-2 #=< 10, 
    Y+Height-2 #=< 10,
    createShipsGroup(SizeWithMargin, XsTail, YsTail, AuxShipsGroup),
    append([ship(X, Width, Y, Height)], AuxShipsGroup, ShipsGroup).

/* creates list with starts with this format [[Ax,Ay], [Bx,By], ...] */
groupStarts([],[],[]).
groupStarts([X|XsTail], [Y|YsTail], Starts) :-
    groupStarts(XsTail, YsTail, AuxStarts),
    append([[X,Y]], AuxStarts, Starts).

/* create ships */
createShips([], []).
createShips([Size-NumberOfShips|ShipsDataTail], Ships) :-
    length(StartsX, NumberOfShips),
    length(StartsY, NumberOfShips),
    domain(StartsX, 1, 10),
    domain(StartsY, 1, 10),
    SizeWithMargin is Size+1,
    createShipsGroup(SizeWithMargin, StartsX, StartsY, ShipsGroup),
    groupStarts(StartsX, StartsY, Starts),
    % break symmetries with ships of same size
    lex_chain(Starts, [op(#<),global(true)]),
    createShips(ShipsDataTail, AuxShips),
    append(ShipsGroup, AuxShips, Ships).


/* battleships */
battleships(ID, Vars):-
    initialBoard(Board),
    matrixToList(Board, Vars),
    domain(Vars,0,1),
    data(ID, InitialInfo, PerRowData, PerColumnData, ShipsData),
    fillBoardWithInfo(InitialInfo, Vars),
    
    % constrain rows and columns number of ship segments 
    constrain(Board, PerRowData),
    transpose(Board, BoardTransposed, 0, 10),
    constrain(BoardTransposed, PerColumnData),
    
    % constrain ships to be non-adjacent
    constrainDiagonals(Board, 1, 1),
    
    % constrain ships and their size
    createShips(ShipsData, Ships),

    disjoint2(Ships),
    !,
    
    % constrain ships and their size
    constrainShips(Vars, Ships),
    labeling([bisect], Vars),
    printBoard(Board, PerRowData, PerColumnData).
    