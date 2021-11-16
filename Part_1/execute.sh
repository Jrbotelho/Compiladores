#!/bin/bash

clear
lex gocompiler.l
clang -o gocompiler lex.yy.c
for f in ../meta1/*.dgo
do
  echo "CURDIR: ${f}"
  A=${f/.dgo/.out}
  B=${f/.dgo/.out_put}
  ./gocompiler -l < $f > $B
  diff $A $B
done
