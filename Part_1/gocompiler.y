/* João Ricardo Miranda Botelho 2019155348  */
/* José Pedro Silvério Braz     2017247538  */

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "functions.h"
    #include "y.tab.h"
    int yylex (void);
    void yyerror(char* s);
    node* my_program;
    bool error_occ = false;
    bool pos_str_err = false;
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
%token STRNG
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
%token<text>REALLIT INTLIT ID STRLT

%type<no>DECLARATION VAR_DECLARATION FUNC_DECLARATION VAR_SPEC VS_CONT VS_CONT_CONT PARAMETERS P_CONT FD_CONT TYPE FUNC_BODY
%type<no>VARS_AND_STATEMENTS VAS_CONT STATEMENT ST_CONT ST2_CONT ST3_CONT EXPR MAYBE_EXPR FUNC_INVOCATION MAYBE_EXPRS MORE_EXPRS
%type<no>PROGRAM

%union{
    char* text;
    node* no;
}

%right ASSIGN
%left OR
%left AND
%left GT GE LT LE EQ NE
%left PLUS MINUS
%left STAR DIV MOD
%left UNARY

%%
PROGRAM: PACKAGE ID SEMICOLON DECLARATION  {my_program = create("Program"); $$ = add_down(my_program, $4);}
       ;

DECLARATION:    DECLARATION VAR_DECLARATION SEMICOLON   {$$ = add_next($1, $2);}
           |    DECLARATION FUNC_DECLARATION SEMICOLON  {node* tmp = create("FuncDecl"); add_down(tmp, $2); $$ = add_next($1, tmp);}
           |    /*Nothing*/                             {$$ = NULL;}
           ;    

VAR_DECLARATION:    VAR VAR_SPEC                        {$$ = $2;}
               |    VAR LPAR VAR_SPEC SEMICOLON RPAR    {$$ = $3;}
               ;

VAR_SPEC:   VS_CONT TYPE        {
                                    node* tmp = create("VarDecl");
                                    node* to_loop = $1;
                                    node* tp = $2;
                                    add_down(tmp, $2);
                                    add_down(tmp, create(to_loop->val));    
                                    to_loop = to_loop->next;
                                    node* tmp_2 = NULL;
                                    for(;to_loop != NULL; to_loop=to_loop->next){
                                        tmp_2 = create("VarDecl");
                                        add_down(tmp_2, create(tp->val));
                                        add_down(tmp_2, create(to_loop->val));
                                        add_next(tmp, tmp_2);
                                    }
                                    $$ = tmp;
                                }
        ;

VS_CONT:    VS_CONT_CONT ID {
                                char* aux = (char*)malloc(strlen($2)+5);
                                sprintf(aux, "Id(%s)", $2);
                                node* tmp = create(aux);
                                $$ = add_next($1, tmp);
                            }
       ;    

VS_CONT_CONT:   VS_CONT_CONT ID COMMA   {   
                                            char* aux = (char*)malloc(strlen($2)+5);
                                            sprintf(aux, "Id(%s)", $2);
                                            node* tmp = create(aux);
                                            $$ = add_next($1, tmp);
                                        }
            |   /*Nothing*/             {$$ = NULL;}
            ;

TYPE:   INT     {$$ = create("Int");}
    |   FLOAT32 {$$ = create("Float32");}
    |   BOOL    {$$ = create("Bool");}
    |   STRNG  {$$ = create("String");}
    ;

FUNC_DECLARATION:   FUNC ID LPAR PARAMETERS RPAR FD_CONT FUNC_BODY  {
                                                                        node* fheader = create("FuncHeader");
                                                                        node* fbody = create("FuncBody");
                                                                        char* aux = (char*)malloc(strlen($2)+5);
                                                                        sprintf(aux, "Id(%s)", $2);
                                                                        node* tmp = create(aux);
                                                                        add_down(fheader, tmp);
                                                                        add_down(fheader, $6);
                                                                        tmp = create("FuncParams");
                                                                        add_down(tmp, $4);
                                                                        add_down(fheader, tmp);
                                                                        add_down(fbody, $7);
                                                                        $$ = add_next(fheader, fbody);
                                                                        free(aux);
                                                                    }
                ;

FD_CONT:   TYPE         {$$ = $1;}
        |   /*Nothing*/ {$$ = NULL;}
        ;

PARAMETERS: P_CONT ID TYPE  {
                                char* aux = (char*)malloc(strlen($2)+5);
                                sprintf(aux, "Id(%s)", $2);
                                node* tmp = create(aux);
                                tmp = add_next($3, tmp);
                                node* param = create("ParamDecl");
                                add_down(param, tmp);
                                $$ = add_next($1, param);
                                free(aux);
                            }
          | /*Nothing*/     {$$ = NULL;}
          ; 


P_CONT: P_CONT ID TYPE COMMA    {
                                    char* aux = (char*)malloc(strlen($2)+5);
                                    sprintf(aux, "Id(%s)", $2);
                                    node* tmp = create(aux);
                                    tmp = add_next($3, tmp);
                                    node* param = create("ParamDecl");
                                    add_down(param, tmp);
                                    $$ = add_next($1, param);
                                    free(aux);
                                }
      | /*Nothing*/             {$$ = NULL;}


FUNC_BODY:  LBRACE VARS_AND_STATEMENTS RBRACE   {$$ = $2;}
         ;


VARS_AND_STATEMENTS:    VARS_AND_STATEMENTS VAS_CONT SEMICOLON  {$$ = add_next($1, $2);}
                   |    /*Nothing*/                             {$$ = NULL;}
                   ;


VAS_CONT:   VAR_DECLARATION {$$ = $1;}
        |   STATEMENT       {$$ = $1;}
        |   /*Nothing*/     {$$ = NULL;}
        ;

STATEMENT:  ID ASSIGN EXPR                                                  {
                                                                                char* aux = (char*)malloc(strlen($1)+5);
                                                                                sprintf(aux, "Id(%s)", $1);
                                                                                node* tmp = create(aux);
                                                                                node* tmp_2 = create("Assign");
                                                                                tmp_2 = add_down(tmp_2, tmp);
                                                                                $$ = add_down(tmp_2, $3);
                                                                            }
         |  LBRACE ST_CONT RBRACE                                           {
                                                                                if (count_depth($2) < 2) $$ = $2;
                                                                                else{
                                                                                    node* tmp = create("Block"); 
                                                                                    $$ = add_down(tmp,$2);
                                                                                }
                                                                            }
         |  IF EXPR LBRACE ST_CONT RBRACE ST2_CONT                          {
                                                                                node* tmp = create("If"); 
                                                                                add_down(tmp, $2);
                                                                                node* tmp_2 = create("Block"); 
                                                                                add_down(tmp_2, $4);
                                                                                add_down(tmp, tmp_2);
                                                                                node* tmp_3 = create("Block");
                                                                                add_down(tmp_3, $6);
                                                                                $$ = add_down(tmp, tmp_3);
                                                                            }
         |  FOR MAYBE_EXPR LBRACE ST_CONT RBRACE                            {
                                                                                node* tmp = create("For"); 
                                                                                add_down(tmp, $2); 
                                                                                node* tmp_2 = create("Block");
                                                                                add_down(tmp_2, $4); 
                                                                                $$ = add_down(tmp, tmp_2);
                                                                            }
         |  RETURN MAYBE_EXPR                                               {node* tmp = create("Return"); $$ = add_down(tmp, $2);}
         |  FUNC_INVOCATION                                                 {node* tmp = create("Call"); $$ = add_down(tmp, $1);}
         |  ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ EXPR RSQ RPAR {
                                                                                char* aux = (char*)malloc(strlen($1)+5);
                                                                                sprintf(aux, "Id(%s)", $1);
                                                                                node* tmp = create(aux);
                                                                                add_next(tmp, $9);
                                                                                node* tmp_2 = create("ParseArgs");
                                                                                $$ = add_down(tmp_2, tmp);
                                                                            }
         |  ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR                {$$ = NULL; error_occ = true;}
         |  PRINT LPAR ST3_CONT RPAR                                        {node* tmp = create("Print"); $$ = add_down(tmp, $3);}
         |  error                                                           {$$ = NULL; error_occ = true;}
         ;

ST_CONT:    ST_CONT STATEMENT SEMICOLON {$$ = add_next($1, $2);}
       |    /*Nothing*/                 {$$ = NULL;}

ST2_CONT:   ELSE LBRACE ST_CONT RBRACE  {$$ = $3;}
        |   /*Nothing*/                 {$$ = NULL;}
        ;

ST3_CONT:   EXPR    {$$ = $1;}
        |   STRLT   {
                        char* aux = (char*)malloc(strlen($1)+9);
                        sprintf(aux, "StrLit(\"%s\")", $1);
                        $$ = create(aux);
                    }
        ;

MAYBE_EXPR: EXPR        {$$ = $1;}    
          | /*Nothing*/ {$$ = NULL;}
          ;


FUNC_INVOCATION:    ID LPAR MAYBE_EXPRS RPAR    {
                                                    char* aux = (char*)malloc(strlen($1)+5);
                                                    sprintf(aux, "Id(%s)", $1);
                                                    node* tmp = create(aux);
                                                    $$ = add_next(tmp, $3);
                                                }
               |    ID LPAR error RPAR          {$$ = NULL; error_occ = true;}
               ;

MAYBE_EXPRS:    MORE_EXPRS EXPR {$$ = add_next($1, $2);}    
           |    /*Nothing*/     {$$ = NULL;}
           ;

MORE_EXPRS: MORE_EXPRS EXPR COMMA   {$$ = add_next($1, $2);}
          | /*Northing*/            {$$ = NULL;}
          ;

EXPR:   EXPR OR EXPR                {node* tmp = create("Or");add_down(tmp, $1); $$ = add_down(tmp, $3);}
    |   EXPR LT EXPR                {node* tmp = create("Lt");add_down(tmp, $1); $$ = add_down(tmp, $3);}
    |   EXPR GT EXPR                {node* tmp = create("Gt");add_down(tmp, $1); $$ = add_down(tmp, $3);}
    |   EXPR EQ EXPR                {node* tmp = create("Eq");add_down(tmp, $1); $$ = add_down(tmp, $3);}
    |   EXPR NE EXPR                {node* tmp = create("Ne");add_down(tmp, $1); $$ = add_down(tmp, $3);}
    |   EXPR LE EXPR                {node* tmp = create("Le");add_down(tmp, $1); $$ = add_down(tmp, $3);}
    |   EXPR GE EXPR                {node* tmp = create("Ge");add_down(tmp, $1); $$ = add_down(tmp, $3);}
    |   EXPR AND EXPR               {node* tmp = create("And");add_down(tmp, $1); $$ = add_down(tmp, $3);}
    |   EXPR PLUS EXPR              {node* tmp = create("Add");add_down(tmp, $1); $$ = add_down(tmp, $3);}
    |   EXPR MINUS EXPR             {node* tmp = create("Sub");add_down(tmp, $1); $$ = add_down(tmp, $3);}
    |   EXPR STAR EXPR              {node* tmp = create("Mul");add_down(tmp, $1); $$ = add_down(tmp, $3);}
    |   EXPR DIV EXPR               {node* tmp = create("Div");add_down(tmp, $1); $$ = add_down(tmp, $3);}
    |   EXPR MOD EXPR               {node* tmp = create("Mod");add_down(tmp, $1); $$ = add_down(tmp, $3);}
    |   MINUS EXPR %prec UNARY      {node* tmp = create("Minus"); $$ = add_down(tmp, $2);}
    |   PLUS EXPR %prec UNARY       {node* tmp = create("Plus"); $$ = add_down(tmp, $2);}
    |   NOT EXPR %prec UNARY        {node* tmp = create("Not"); $$ = add_down(tmp, $2);}
    |   INTLIT                      {
                                        char* aux = (char*)malloc(strlen($1)+9);
                                        sprintf(aux, "IntLit(%s)", $1);
                                        $$ = create(aux);          
                                        free(aux);                        
                                    }
    |   REALLIT                     {
                                        char* aux = (char*)malloc(strlen($1)+10);
                                        sprintf(aux, "RealLit(%s)", $1);
                                        $$ = create(aux);
                                        free(aux);                                  
                                    }
    |   ID                          {
                                        char* aux = (char*)malloc(strlen($1)+5);
                                        sprintf(aux, "Id(%s)", $1);
                                        $$ = create(aux); 
                                        free(aux);                                 
                                    }
    |   FUNC_INVOCATION             {node* tmp = create("Call"); $$ = add_down(tmp, $1);}
    |   LPAR EXPR RPAR              {$$ = $2;}
    |   LPAR error RPAR             {$$ = NULL; error_occ = true;}
    ;

%%

int main(int argc, char *argv[]){
  if ((argc >= 2 && strcmp(argv[1], "-l") == 0)||
      (argc >= 3 && strcmp(argv[2], "-l") == 0)|| 
      (argc >= 4 && strcmp(argv[3], "-l"))) mayprint = 1;
  yyparse();
  build_symtab(my_program, NULL, NULL);
  build_noted_tree(NULL, my_program, NULL);
  print_table();
  if ((argc >= 2 && strcmp(argv[1], "-t") == 0)||
      (argc >= 3 && strcmp(argv[2], "-t") == 0)||
      (argc >= 4 && strcmp(argv[3], "-t"))) if (!error_occ)print_tree(my_program, NULL, 0, supposed_file());
  if ((argc >= 2 && strcmp(argv[1], "-s") == 0)||
      (argc >= 3 && strcmp(argv[2], "-s") == 0)||
      (argc >= 4 && strcmp(argv[3], "-s"))) if (!error_occ) print_noted_tree();
  return 0;
}