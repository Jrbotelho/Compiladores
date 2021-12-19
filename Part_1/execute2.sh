#!/bin/bash
clear
lex gocompiler.l
yacc -d -v gocompiler.y
clang -o run lex.yy.c y.tab.c functions.c symtable.c
./run -s < texto.txt > texto2.txt

