#!/bin/bash
clear
lex gocompiler.l
clang -o gocompiler lex.yy.c
./gocompiler
