#!/bin/bash
clear
lex gocompiler.l && yacc -d gocompiler.y && clang -o run lex.yy.c y.tab.c functions.c
./run