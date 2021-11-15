
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
program: PACKAGE ID SEMICOLON declaration  {$$ = program($2, $4);}
       ;

declaration:    declaration var_declaration     {$$ = insert_declaration($1, $2);}
           |    declaration func_declaration    {$$ = insert_declaration($1, $2);}
           |    /*Nothing*/                     {$$ = NULL;}
           ;    

var_declaration:    VAR var_spec                        {$$ = $2;}
               |    VAR LPAR var_spec SEMICOLON RPAR    {$$ = $3;}
               ;

var_spec:   vs_cont type        {$$ = insert_vardec_type($1, $2);}
        ;

vs_cont:    vs_cont ID  {$$ = insert_vardec_without_type($1, $2);}
       ;    

vs_cont_cont:   vs_cont_cont ID COMMA   {$$ = insert_vardec_without_type($1, $2);}
            |   /*Nothing*/             {$$ = NULL;}

type:   INT     {$$ = d_int;}
    |   FLOAT32 {$$ = d_float;}
    |   BOOL    {$$ = d_bool;}
    |   STRING  {$$ = d_str;}
    :

func_declaration:   FUNC ID LPAR parameters RPAR fd_cont func_body  {insert_fundec(insert_fun_header($4, $2, $6), $7);}
                ;

fd_cont:   type        {$$ = $1;}
        |   /*Nothing*/ {$$ = d_no_type;}
        ;

parameters: p_cont ID type  {$$ = insert_param($1, insert_vardec($2, $3));}
          ; 

p_cont: p_cont ID type COMMA    {$$ = insert_param($1, insert_vardec($2, $3));}
      | /*Nothing*/             {$$ = NULL;}

func_body:  LBRACE vars_and_statements RBRACE   {$$ = insert_funbody($2);}
         ;

vars_and_statements:    vars_and_statements vas_cont SEMICOLON  {$$ = insert_vos_list($1, $2);}
                   |    /*Nothing*/                             {$$ = NULL;}
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