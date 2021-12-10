/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     RETURN = 258,
     RESERVED = 259,
     PACKAGE = 260,
     FOR = 261,
     FUNC = 262,
     IF = 263,
     ELSE = 264,
     VAR = 265,
     INT = 266,
     FLOAT32 = 267,
     BOOL = 268,
     STRNG = 269,
     PRINT = 270,
     PARSEINT = 271,
     CMDARGS = 272,
     COMMA = 273,
     BLANKID = 274,
     SEMICOLON = 275,
     ASSIGN = 276,
     STAR = 277,
     DIV = 278,
     MINUS = 279,
     PLUS = 280,
     EQ = 281,
     GE = 282,
     GT = 283,
     LE = 284,
     LT = 285,
     LBRACE = 286,
     RBRACE = 287,
     LSQ = 288,
     RSQ = 289,
     LPAR = 290,
     RPAR = 291,
     MOD = 292,
     NE = 293,
     NOT = 294,
     AND = 295,
     OR = 296,
     REALLIT = 297,
     INTLIT = 298,
     ID = 299,
     STRLT = 300,
     UNARY = 301
   };
#endif
/* Tokens.  */
#define RETURN 258
#define RESERVED 259
#define PACKAGE 260
#define FOR 261
#define FUNC 262
#define IF 263
#define ELSE 264
#define VAR 265
#define INT 266
#define FLOAT32 267
#define BOOL 268
#define STRNG 269
#define PRINT 270
#define PARSEINT 271
#define CMDARGS 272
#define COMMA 273
#define BLANKID 274
#define SEMICOLON 275
#define ASSIGN 276
#define STAR 277
#define DIV 278
#define MINUS 279
#define PLUS 280
#define EQ 281
#define GE 282
#define GT 283
#define LE 284
#define LT 285
#define LBRACE 286
#define RBRACE 287
#define LSQ 288
#define RSQ 289
#define LPAR 290
#define RPAR 291
#define MOD 292
#define NE 293
#define NOT 294
#define AND 295
#define OR 296
#define REALLIT 297
#define INTLIT 298
#define ID 299
#define STRLT 300
#define UNARY 301




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 62 "gocompiler.y"
{
    char* text;
    node* no;
}
/* Line 1529 of yacc.c.  */
#line 146 "y.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

