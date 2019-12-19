:-consult('display.pl').
:-consult('data.pl').

:-use_module(library(clpfd)).

b :-
    initialBoard(Board),
    printBoard(Board).
