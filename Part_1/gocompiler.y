
%{
    #include "lex.yy.c"
    #include <stdio.h>
    #include <stdlib.h>
    #include "functions.h"
    int yylex(void);
    void yyerror(char* s);
}%

%union{
    char* id;
}%

%right ASSIGN
%left MINUS PLUS
%left STAR DIV
%left MOD

%%
program: PACKAGE ID SEMICOLON declaration  {insert_program($2, $4);}
       ;

declaration:    declaration var_declaration     {$$ = insert_declaration_list($1, $2);}
           |    declaration func_declaration    {$$ = insert_declaration_list($1, $2);}
           |    /*Nothing*/                     {$$ = NULL;}
           ;    

var_declaration:    VAR var_spec                        {$$ = insert_declaration($2);}
               |    VAR LPAR var_spec SEMICOLON RPAR    {$$ = insert_declaration($2);}
               ;

var_spec:   vs_cont type        {$$ = insert_vardec($1, $2);}
        ;

vs_cont:    vs_cont COMMA ID    {$$ = insert_id_list($1, $2);}
       |    ID                  {$$ = insert_id_list(NULL; $1);}
       |    /*Nothing*/         {$$ = NULL;}
       ;    

type:   INT     {$$ = d_int;}
    |   FLOAT32 {$$ = d_float;}
    |   BOOL    {$$ = d_bool;}
    |   STRING  {$$ = d_string;}
    :

func_declaration:   FUNC ID LPAR fd_cont RPAR fd2_cont func_body    {;}
                ;

fd_cont:    parameters  {;}
       |    /*Nothing*/ {;}
       ; 

fd2_cont:   type        {;}
        |   /*Nothing*/ {;}
        ;

parameters: ID type p_cont  {;}
          ; 

p_cont: p_cont COMMA ID type    {;}
      | /*Nothing*/             {;}

func_body:  LBRACE vars_and_statements RBRACE   {;}
         ;

vars_and_statements:    vars_and_statements vas_cont SEMICOLON  {;}
                   |    /*Nothing*/                             {;}
                   ;

vas_cont:   var_declaration {;}
        |   statement       {;}
        |   /*Nothing*/     {;}
        ;

statement:  ID ASSIGN expr  {;}
         |  LBRACE st_cont RBRACE   {;}
         |  IF expr LBRACE st_cont RBRACE st2_cont  {;}
         |  FOR maybe_expr LBRACE st_cont RBRACE    {;}
         |  RETURN maybe_expr   {;}
         |  func_invocation {;}
         |  parse_args      {;}
         |  PRINT LPAR st3_cont RPAR {;}
         ;

st_cont:    statement SEMICOLON {;}
       |    /*Nothing*/         {;}

st2_cont:   ELSE LBRACE st_cont RBRACE  {;}
        |   /*Nothing*/                 {;}
        ;

st3_cont:   expr    {;}
        |   STRLIT  {;}
        ;

maybe_expr: expr        {;}    
          | /*Nothing*/ {;}
          ;

maybe_exprs:    expr more_exprs {;}    
           |    /*Nothing*/     {;}

more_exprs: COMMA expr more_exprs   {;}
          | /*Northing*/            {;}

parse_args: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ expr RSQ RPAR {;}
          ;

func_invocation:    ID LPAR maybe_exprs RPAR {;}
               ;

expr:   expr comp expr  {;}
    |   sig expr        {;}
    |   INTLIT          {;}
    |   REALLIT         {;}
    |   ID              {;}
    |   func_invocation {;}
    |   LPAR expr RPAR  {;}
    ;

sig:    MINUS   {;}
   |    PLUS    {;}
   |    NOT     {;}
   ;

comp:   OR      {;}
    |   AND     {;}
    |   LT      {;}
    |   GT      {;}
    |   EQ      {;}
    |   NE      {;}
    |   LE      {;}
    |   GE      {;}
    |   PLUS    {;}
    |   MINUS   {;}
    |   STAR    {;}
    |   DIV     {;}
    |   MOD     {;}
    ;

%%