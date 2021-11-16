%{
    #include "lex.yy.c"
    #include <stdio.h>
    #include <stdlib.h>
    #include "functions.h"
    int yylex(void);
    void yyerror(char* s);
    is_program* my_program;
%}

%token RETURN
%token RESERVED
%token PACKAGE
%token FOR
%token FUNC
%token IF
%token ELSE
%token VAR
%token INT
%token FLOAT32
%token BOOL
%token STRING
%token PRINT
%token PARSEINT
%token CMDARGS
%token COMMA
%token BLANKID
%token SEMICOLON
%token ASSIGN
%token STAR
%token DIV
%token MINUS
%token PLUS
%token EQ
%token GE
%token GT
%token LE
%token LT
%token LBRACE
%token RBRACE
%token LSQ
%token RSQ
%token LPAR
%token RPAR
%token MOD
%token NE
%token NOT
%token AND
%token OR
%token<real>REALLIT
%token<intlit>INTLIT
%token<str>ID STRLIT

%type<idl>declaration
%type<isd>var_declaration func_declaration
%type<iv>var_spec vs_cont vs_cont_cont
%type<ivl>parameters p_cont
%type<tp>fd_cont type
%type<ifb>func_body
%type<ivosl>vars_and_statements
%type<ivos>vas_cont
%type<is>statement
%type<isl>st_cont st2_cont
%type<ip>st3_cont
%type<ie>expr maybe_expr
%type<ifi>func_invocation
%type<iel>maybe_exprs more_exprs
%type<iparse>parse_args
%type<nat>sig
%type<ot>comp
%type<iprogram>program

%union{
    float* real;
    int* intlit;
    char* str;
    is_dec_list* idl;
    is_dec* isd;
    is_vardec* iv;
    is_vardec_list* ivl;
    type tp;
    is_stat_list* isl;
    is_funbody* ifb;
    is_vos_list* ivosl;
    is_var_or_stat* ivos;
    is_stat* is;
    is_print* ip;
    is_expr* ie;
    is_fun_inv* ifi;
    is_expr_list* iel;
    is_parse* iparse;
    non_assoc_type nat;
    op_type ot;
    is_program* iprogram;
}

%right ASSIGN
%left MINUS PLUS
%left STAR DIV
%left MOD

%%
program: PACKAGE ID SEMICOLON declaration  {$$ = my_program = program($4, $2);}
       ;

declaration:    declaration var_declaration     {$$ = insert_dec($1, $2);}
           |    declaration func_declaration    {$$ = insert_dec($1, $2);}
           |    /*Nothing*/                     {$$ = NULL;}
           ;    

var_declaration:    VAR var_spec                        {$$ = $2;}
               |    VAR LPAR var_spec SEMICOLON RPAR    {$$ = $3;}
               ;

var_spec:   vs_cont type        {$$ = insert_vardec_type($1, $2);}
        ;

vs_cont:    vs_cont_cont ID  {$$ = insert_vardec_without_type($1, $2);}
       |    /*Nothing*/ {$$ = NULL;}
       ;    

vs_cont_cont:   vs_cont_cont ID COMMA   {$$ = insert_vardec_without_type($1, $2);}
            |   /*Nothing*/             {$$ = NULL;}
            ;

type:   INT     {$$ = d_integer;}
    |   FLOAT32 {$$ = d_float32;}
    |   BOOL    {$$ = d_bool;}
    |   STRING  {$$ = d_str;}
    ;

func_declaration:   FUNC ID LPAR parameters RPAR fd_cont func_body  {insert_fundec(insert_fun_header($4, $2, $6), $7);}
                ;

fd_cont:   type         {$$ = $1;}
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


vas_cont:   var_declaration {$$ = insert_var($1);}
        |   statement       {$$ = insert_stat($1);}
        |   /*Nothing*/     {$$ = NULL;}
        ;

statement:  ID ASSIGN expr                          {$$ = insert_assign($1, $3);}
         |  LBRACE st_cont RBRACE                   {$$ = insert_stat_stat_list($2);}
         |  IF expr LBRACE st_cont RBRACE st2_cont  {$$ = insert_if($2, $4, $6);}
         |  FOR maybe_expr LBRACE st_cont RBRACE    {$$ = insert_for($2, $4);}
         |  RETURN maybe_expr                       {$$ = insert_return($2);}
         |  func_invocation                         {$$ = insert_fun_invocation($1);}
         |  parse_args                              {$$ = insert_parse($1);}
         |  PRINT LPAR st3_cont RPAR                {$$ = insert_print($3);}
         ;

st_cont:    st_cont statement SEMICOLON {$$ = insert_stat_list($1, $2);}
       |    /*Nothing*/         {$$ = NULL;}

st2_cont:   ELSE LBRACE st_cont RBRACE  {$$ = $3;}
        |   /*Nothing*/                 {$$ = NULL;}
        ;

st3_cont:   expr    {$$ = print_expr($1);}
        |   STRLIT  {$$ = print_strlit($1);}
        ;

maybe_expr: expr        {$$ = $1;}    
          | /*Nothing*/ {$$ = NULL;}
          ;


func_invocation:    ID LPAR maybe_exprs RPAR {$$ = insert_fun_inv($1, $3);}
               ;

maybe_exprs:    more_exprs expr  {$$ = insert_expr_list($1, $2);}    
           |    /*Nothing*/     {$$ = NULL;}
           ;

more_exprs: more_exprs expr COMMA   {$$ = insert_expr_list($1, $2);}
          | /*Northing*/            {$$ = NULL;}
          ;

parse_args: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ expr RSQ RPAR {$$ = insert_parse_arg($1, $9);}
          ;

expr:   expr comp expr  {$$ = insert_math($2, $1, $3);}
    |   sig expr        {$$ = insert_non_assoc($1, $2);}
    |   INTLIT          {$$ = insert_int($1);}
    |   REALLIT         {$$ = insert_float($1);}
    |   ID              {$$ = insert_id($1);}
    |   func_invocation {$$ = insert_fun_inv_expr($1);}
    |   LPAR expr RPAR  {$$ = $2;}
    ;

sig:    MINUS   {$$ = d_minus;}
   |    PLUS    {$$ = d_plus;}
   |    NOT     {$$ = d_not;}
   ;

comp:   OR      {$$ = d_or;}
    |   AND     {$$ = d_and;}
    |   LT      {$$ = d_lt;}
    |   GT      {$$ = d_gt;}
    |   EQ      {$$ = d_eq;}
    |   NE      {$$ = d_ne;}
    |   LE      {$$ = d_le;}
    |   GE      {$$ = d_ge;}
    |   PLUS    {$$ = d_pl;}
    |   MINUS   {$$ = d_min;}
    |   STAR    {$$ = d_star;}
    |   DIV     {$$ = d_div;}
    |   MOD     {$$ = d_mod;}
    ;

%%
