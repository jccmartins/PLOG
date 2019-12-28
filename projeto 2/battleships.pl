:-use_module(library(clpfd)).
:-use_module(library(lists)).

:-consult('display.pl').
:-consult('data.pl').
:-consult('utils.pl').

/* get or set cell value */
cellValue(_,0,_,_,_,0).
cellValue(_,_,0,_,_,0).
cellValue(_,Row,_,NRows,_,0) :- Row > NRows.
cellValue(_,_,Column,_,NColumns,0) :- Column > NColumns.
cellValue(Vars, Row, Column, _, NColumns, Value) :-
    N is (Row-1)*NColumns+Column,
    nth1(N, Vars, Value).

/* set margin of ship piece to 0 considering its type (north,east,west or single) */
constrainMargin(Vars, Row, Column, NRows, NColumns, ShipPiece) :-
    TopRow is Row-1,
    BottomRow is Row+1,
    LeftColumn is Column-1,
    RightColumn is Column+1,
    (ShipPiece == single ->
        cellValue(Vars, TopRow, Column, NRows, NColumns, 0),      
        cellValue(Vars, Row, LeftColumn, NRows, NColumns, 0),    
        cellValue(Vars, Row, RightColumn, NRows, NColumns, 0),    
        cellValue(Vars, BottomRow, Column, NRows, NColumns, 0);
    ShipPiece == square ->
        cellValue(Vars, TopRow, Column, NRows, NColumns, Top),      
        cellValue(Vars, Row, LeftColumn, NRows, NColumns, Left),    
        cellValue(Vars, Row, RightColumn, NRows, NColumns, Right),    
        cellValue(Vars, BottomRow, Column, NRows, NColumns, Bottom),
        Top+Bottom #= 2 #\/ Left+Right #= 2;
    ShipPiece == north ->
        cellValue(Vars, TopRow, Column, NRows, NColumns, 0),      
        cellValue(Vars, Row, LeftColumn, NRows, NColumns, 0),    
        cellValue(Vars, Row, RightColumn, NRows, NColumns, 0),    
        cellValue(Vars, BottomRow, Column, NRows, NColumns, 1);
    ShipPiece == east ->
        cellValue(Vars, TopRow, Column, NRows, NColumns, 0),
        cellValue(Vars, Row, LeftColumn, NRows, NColumns, 1),
        cellValue(Vars, Row, RightColumn, NRows, NColumns, 0),   
        cellValue(Vars, BottomRow, Column, NRows, NColumns, 0);
    ShipPiece == west ->
        cellValue(Vars, TopRow, Column, NRows, NColumns, 0),      
        cellValue(Vars, Row, LeftColumn, NRows, NColumns, 0),    
        cellValue(Vars, Row, RightColumn, NRows, NColumns, 1),  
        cellValue(Vars, BottomRow, Column, NRows, NColumns, 0); 
    ShipPiece == south ->     
        cellValue(Vars, TopRow, Column, NRows, NColumns, 1),
        cellValue(Vars, Row, LeftColumn, NRows, NColumns, 0),    
        cellValue(Vars, Row, RightColumn, NRows, NColumns, 0),    
        cellValue(Vars, BottomRow, Column, NRows, NColumns, 0)).

/* fills board with initial info */
fillVarsWithInfo([],_,_,_).
fillVarsWithInfo([H|T], NRows, NColumns, Vars):-
    [[Row, Column], PieceType] = H,
    N is (Row-1)*NColumns+Column,
    (PieceType == water ->
        nth1(N, Vars, 0);
    nth1(N,Vars,1),    
    constrainMargin(Vars, Row, Column, NRows, NColumns, PieceType)),
    fillVarsWithInfo(T, NRows, NColumns, Vars).

/* constrain number of ship pieces there are in each row or column */
constrain([], []).
constrain([H|T], [Constraint|ConstraintsTail]) :-
    global_cardinality(H, [1-Constraint,0-_]),
    constrain(T, ConstraintsTail).

/* constrain ships so there are the exact number of ships (with the respective size) on the board */
constrainShips(_,_,[]).
constrainShips(Vars, NColumns, [Ship|ShipsTail]) :-
    ship(X, SizeX, Y, SizeY) = Ship,
    constrainShipX(Vars, X, Y, NColumns, SizeX),
    constrainShipY(Vars, X, Y, NColumns, SizeY),
    constrainShips(Vars, NColumns, ShipsTail).

constrainShipX(_,_,_,_,1).
constrainShipX(Vars, X, Y, NColumns, SizeX) :-
    N #= (Y-1)*NColumns+X,
    nth1(N, Vars, 1),
    NewX #= X+1,
    NewSizeX #= SizeX-1,
    constrainShipX(Vars, NewX, Y, NColumns, NewSizeX).
    
constrainShipY(_,_,_,_,1).
constrainShipY(Vars, X, Y, NColumns, SizeY) :-
    N #= (Y-1)*NColumns+X,
    nth1(N, Vars, 1),
    NewY #= Y+1,
    NewSizeY #= SizeY-1,
    constrainShipY(Vars, X, NewY, NColumns, NewSizeY).

/* constrain ships to be non adjacent */
constrainDiagonals(_, Row, _, NRows, _) :-
    Row > NRows.

constrainDiagonals(Board, Row, Column, NRows, NColumns) :-
    Column > NColumns,
    BottomRow is Row+1,
    constrainDiagonals(Board, BottomRow, 1, NRows, NColumns).
    
constrainDiagonals(Vars, Row, Column, NRows, NColumns) :-
    N is (Row-1)*NColumns+Column,
    nth1(N, Vars, Value),
    TopRow is Row-1,
    BottomRow is Row+1,
    LeftColumn is Column-1,
    RightColumn is Column+1,
    cellValue(Vars, TopRow, LeftColumn, NRows, NColumns, TopLeft),
    cellValue(Vars, TopRow, RightColumn, NRows, NColumns, TopRight),
    cellValue(Vars, BottomRow, LeftColumn, NRows, NColumns, BottomLeft),
    cellValue(Vars, BottomRow, RightColumn, NRows, NColumns, BottomRight),
    Value+TopLeft #=< 1,
    Value+TopRight #=< 1,
    Value+BottomLeft #=< 1,
    Value+BottomRight #=< 1,
    constrainDiagonals(Vars, Row, RightColumn, NRows, NColumns).

/* creates list of ships with same size */
createShipsGroup(_, [], [], _, _, []).
createShipsGroup(SizeWithMargin, [X|XsTail], [Y|YsTail], NRows, NColumns, ShipsGroup) :-
    (SizeWithMargin \= 2 ->
        Width in {2, SizeWithMargin},
        Height in {2, SizeWithMargin},
        Width #\= Height;
    Width = 2,
    Height = 2
    ),
    X+Width-2 #=< NColumns, 
    Y+Height-2 #=< NRows,
    createShipsGroup(SizeWithMargin, XsTail, YsTail, NRows, NColumns, AuxShipsGroup),
    append([ship(X, Width, Y, Height)], AuxShipsGroup, ShipsGroup).

/* creates list with starts with this format [[Ax,Ay], [Bx,By], ...] */
groupStarts([],[],[]).
groupStarts([X|XsTail], [Y|YsTail], Starts) :-
    groupStarts(XsTail, YsTail, AuxStarts),
    append([[X,Y]], AuxStarts, Starts).

/* create ships */
createShips([], _, _, []).
createShips([Size-NumberOfShips|ShipsDataTail], NRows, NColumns, Ships) :-
    length(StartsX, NumberOfShips),
    length(StartsY, NumberOfShips),
    domain(StartsX, 1, NColumns),
    domain(StartsY, 1, NRows),
    SizeWithMargin is Size+1,
    createShipsGroup(SizeWithMargin, StartsX, StartsY, NRows, NColumns, ShipsGroup),
    groupStarts(StartsX, StartsY, Starts),
    % break symmetries with ships of same size
    lex_chain(Starts, [op(#<),global(true)]),
    createShips(ShipsDataTail, NRows, NColumns, AuxShips),
    append(ShipsGroup, AuxShips, Ships).


/* battleships */
battleships(ID, Vars):-
    data(ID, InitialInfo, PerRowData, PerColumnData, ShipsData),
    length(PerRowData, NRows),
    length(PerColumnData, NColumns),
    N is NRows*NColumns,
    length(Vars, N),
    domain(Vars,0,1),
    fillVarsWithInfo(InitialInfo, NRows, NColumns, Vars),

    list_to_matrix(Vars,NColumns,Board),
    
    % constrain rows and columns number of ship segments 
    constrain(Board, PerRowData),
    transpose(Board, BoardTransposed, 0, NColumns),
    constrain(BoardTransposed, PerColumnData),

    % constrain ships to be non-adjacent
    constrainDiagonals(Vars, 1, 1, NRows, NColumns),

    % constrain ships and their size
    createShips(ShipsData, NRows, NColumns, Ships),

    disjoint2(Ships),
    !,
    
    % constrain ships and their size
    constrainShips(Vars, NColumns, Ships),
    labeling([bisect], Vars),
    printBoard(Board, PerRowData, PerColumnData).
    