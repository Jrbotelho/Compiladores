/* João Ricardo Miranda Botelho 2019155348  */
/* José Pedro Silvério Braz     2017247538  */
/* C H */

letter                          ([a-zA-Z]|_)
num                             [0-9]
alphanum                        {letter}|{num}
id                              (_{alphanum}+)|([a-zA-Z]{alphanum}*)
hex                             [0-9a-fA-F]
expo                            [eE][+-]?{num}+
float_1                         {num}*\.{num}+{expo}?
float_2                         {num}+\.{num}*{expo}?
float_3                         {num}+{expo}
float                           {float_1}|{float_2}|{float_3}
whitespace                      [ \t\f]
invalid_escape                  \\[^nrft\\\"]
                                /*" */
valid_escape                    \\[nrft\\\"]
                                /*" */

%{
#include <ctype.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
int line = 1, column = 1;
int x = 0, y = 0;
int lx = 0, ly = 0;
bool mayprint = false;
char octal[1000];
char literal[1000];
int literalPos = 0;
int octalPos = 0;
bool octalError = false;
bool literror = false;

char* trim_whitespace(char* string){
  char* output =  (char*)malloc(strlen(string)*sizeof(char));
  int i = -1;
  while(!isspace(string[++i])) output[i] = string[i];
  output[i] = 0;
  return output;
}

char* atoupper(char* str){
    for (int i = 0; str[i] != 0; i++) str[i] = toupper(str[i]);
    return str;
}

void validOctal(char n){
   if (!octalError) octalError = !(n >= '0' && n <= '7');
}

void addOctal(char c){
  octal[octalPos++] = c;
}

void addLit(char c){
  literal[literalPos++] = c;
}

void addStrLit(char* c){
  for (int i = 0; c[i] != 0; i++) addLit(c[i]);
}
%}

%X STRLIT STRLITVALID LINE_COMMENT COMMENT SEMICHECK IN_COMMENT STRING
%%
                            /* Reserved declared    */

"return"                        {if(mayprint)fprintf(yyout, "RETURN\n"); column += yyleng; BEGIN SEMICHECK;}
("package")|("return")|("for")  |
("func")|("if")|("else")        |
("var")|("int")|("float32")     |
("bool")|("string")             {if(mayprint)fprintf(yyout, "%s\n", atoupper(yytext)); column += yyleng;}

                            /*  Reserved undeclared */

("break")|("default")|("case")  |
("interface")|("select")        |
("defer")|("go")|("map")        |
("struct")|("chan")|("goto")    |
("switch")|("const")|("import") |
("fallthrough")|("range")       |
("type")|("continue")           |
(\+\+)|(\-\-)                   {if(mayprint)fprintf(yyout, "RESERVED(%s)\n", yytext); column += yyleng;}

                            /*  Args and puncts */

"fmt.Println"                   {if(mayprint)fprintf(yyout, "PRINT\n"); column += yyleng;}
"strconv.Atoi"                  {if(mayprint)fprintf(yyout, "PARSEINT\n"); column += yyleng;}
"os.Args"                       {if(mayprint)fprintf(yyout, "CMDARGS\n"); column += yyleng;}
\,                              {if(mayprint)fprintf(yyout, "COMMA\n"); column += yyleng;}
_                               {if(mayprint)fprintf(yyout, "BLANKID\n"); column++;}
\;                              {if(mayprint)fprintf(yyout, "SEMICOLON\n"); column += yyleng;}
\=                              {if(mayprint)fprintf(yyout, "ASSIGN\n"); column += yyleng;}
\*                              {if(mayprint)fprintf(yyout, "STAR\n"); column += yyleng;}
\/                              {if(mayprint)fprintf(yyout, "DIV\n"); column += yyleng;}
\-                              {if(mayprint)fprintf(yyout, "MINUS\n"); column += yyleng;}
\+                              {if(mayprint)fprintf(yyout, "PLUS\n"); column += yyleng;}
\=\=                            {if(mayprint)fprintf(yyout, "EQ\n"); column += yyleng;}
\>\=                            {if(mayprint)fprintf(yyout, "GE\n"); column += yyleng;}
\>                              {if(mayprint)fprintf(yyout, "GT\n"); column += yyleng;}
\<\=                            {if(mayprint)fprintf(yyout, "LE\n"); column += yyleng;}
\<                              {if(mayprint)fprintf(yyout, "LT\n"); column += yyleng;}
\{                              {if(mayprint)fprintf(yyout, "LBRACE\n"); column += yyleng;}
\}                              {if(mayprint)fprintf(yyout, "RBRACE\n"); column += yyleng; BEGIN SEMICHECK;}
\[                              {if(mayprint)fprintf(yyout, "LSQ\n"); column += yyleng;}
\]                              {if(mayprint)fprintf(yyout, "RSQ\n"); column += yyleng; BEGIN SEMICHECK;}
\(                              {if(mayprint)fprintf(yyout, "LPAR\n"); column += yyleng;}
\)                              {if(mayprint)fprintf(yyout, "RPAR\n"); column += yyleng; BEGIN SEMICHECK;}
\%                              {if(mayprint)fprintf(yyout, "MOD\n"); column += yyleng;}
\!\=                            {if(mayprint)fprintf(yyout, "NE\n"); column += yyleng;}
\!                              {if(mayprint)fprintf(yyout, "NOT\n"); column += yyleng;}
\&\&                            {if(mayprint)fprintf(yyout, "AND\n"); column += yyleng;}
\|\|                            {if(mayprint)fprintf(yyout, "OR\n"); column += yyleng;}


\"                              {BEGIN STRING; x = column++; y = line;}


                            /* Comments */

\/\/.*                          {column += yyleng;}
\/\*                            {BEGIN COMMENT; x = column, y = line; column += yyleng;}

                            /*  Numbers and literals    */

{float}                         {if(mayprint)fprintf(yyout, "REALLIT(%s)\n", yytext); column += yyleng; BEGIN SEMICHECK;}
0[xX]{hex}+                  {
                                  if(mayprint)fprintf(yyout, "INTLIT(%s)\n", yytext);
                                  column += yyleng;
                                  BEGIN SEMICHECK;
                                }
0[0-7]+                         {
                                  if(mayprint)fprintf(yyout, "INTLIT(%s)\n", yytext); column += yyleng;
                                  BEGIN SEMICHECK;
                                }
0[0-9]*[89]+[0-9]*              {
                                  fprintf(yyout, "Line %d, column %d: invalid octal constant (%s)\n", line, column, yytext);
                                  column += yyleng;
                                }
{num}+                          {
                                  if(mayprint)fprintf(yyout, "INTLIT(%s)\n", yytext);
                                  column += yyleng; BEGIN SEMICHECK;
                                }
{id}                            {if(mayprint)fprintf(yyout, "ID(%s)\n", yytext); column += yyleng; BEGIN SEMICHECK;}

                            /*  Regular lines   */

{whitespace}                    {column+=yyleng;}
\n|(\r\n)                       {line++;column = 1;}
.                               {
                                  fprintf(yyout, "Line %d, column %d: illegal character (%c)\n",
                                          line, column, yytext[0]); column += yyleng;
                                }
<STRING>\"                      {
                                  column++;
                                  addLit(0);
                                  if(!literror){
                                    BEGIN SEMICHECK;
                                    if(mayprint)fprintf(yyout, "STRLIT(\"%s\")\n", literal);
                                  }
                                  else BEGIN 0;
                                  literror = false;
                                  literalPos = 0;
                                }
<STRING>\\\n                    {
                                  literror = true;
                                  fprintf(yyout, "Line %d, column %d: invalid escape sequence (\\)\n",
                                  line, column++);
                                  yyless(1);
                                }
<STRING>{invalid_escape}        {
                                  literror = true;
                                  fprintf(yyout, "Line %d, column %d: invalid escape sequence (%s)\n",
                                  line, column, yytext);
                                  column += yyleng;
                                }
<STRING>\\.                     {
                                  if(!literror)addStrLit(yytext); column+=yyleng;
                                }
<STRING>.                       {if(!literror)addLit(yytext[0]); column++;}
<STRING>\n                      {
                                  BEGIN 0;
                                  fprintf(yyout, "Line %d, column %d: unterminated string literal\n",
                                  y, x);
                                  yyless(0);
                                  literalPos = 0;
                                  literror = false;
                                }

                            /*  Comment */

<SEMICHECK>{whitespace}         {column++;}
<SEMICHECK>\/\/                 {if(mayprint)fprintf(yyout, "SEMICOLON\n"); BEGIN 0; yyless(0);}
<SEMICHECK>\/\*                 {BEGIN IN_COMMENT; x = column, y = line; column += yyleng;}
<SEMICHECK>\n                   {line++; column = 1; if(mayprint)fprintf(yyout, "SEMICOLON\n"); BEGIN 0;}
<SEMICHECK><<EOF>>              {if(mayprint)fprintf(yyout, "SEMICOLON\n"); BEGIN 0;}
<SEMICHECK>.                    {BEGIN 0; yyless(0); ECHO;}

<IN_COMMENT>\*\/                {BEGIN SEMICHECK; column += yyleng;}
<IN_COMMENT><<EOF>>             {
                                  fprintf(yyout, "Line %d, column %d: unterminated comment\n", y, x);
                                  BEGIN SEMICHECK; yyless(0);
                                }
<IN_COMMENT>.                   {column += yyleng;}
<IN_COMMENT>\n                  {line++; column = 1; if(mayprint)fprintf(yyout, "SEMICOLON\n"); BEGIN COMMENT;}


<COMMENT>\*\/                   {BEGIN 0; column += yyleng;}
<COMMENT><<EOF>>                {fprintf(yyout, "Line %d, column %d: unterminated comment\n", y, x); BEGIN 0;}
<COMMENT>.                      {column += yyleng;}
<COMMENT>\n                     {line++; column = 1;}
%%

int main(int argc, char *argv[]){
  if (argc == 2 && strcmp(argv[1], "-l") == 0) mayprint = 1;
  yylex();
  return 0;
}
int yywrap()
{
return 1;
}
