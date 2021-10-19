/* João Ricardo Miranda Botelho 2019155348  */
/* José Pedro Silvério Braz     2017247538  */

letter                          ([a-z]|[A-Z]|\_)
num                             [0-9]
alphanum                        {letter}|{num}
id                              {letter}{alphanum}*
hex                             [0-9a-fA-F]
expo                            [eE][+-]?{num}+
float_1                         {num}*\.{num}*{expo}?
float_2                         {num}+{expo}
float                           {float_1}|{float_2}
num_finish                      " "|\)|\;|\{|\}|\]|\t|\,
operator                        [-+*/&|]
invalid_escape                  \\[^nrft\\\"]
valid_escape                    \\[nrft\\\"]
whitespace                      [ \t\f]

%{
#include <ctype.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
int line = 1, column = 1;
int x = 0, y = 0;
int lx = 0, ly = 0;

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

bool in_comment = 0;
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

bool textComparer(FILE* f1, FILE* f2){
  int pos = 0;
  char a = 0, b = 0;
  printf("started comparing...\n");
  while(a != EOF && b != EOF){
    a = fgetc(f1);
    b = fgetc(f2);
    if (a != b){
      printf("ERROR ON POS %d\na = %c\tb = %c\n", pos, a, b);
      return 0;
    }
    pos++;
  }
  return (a == EOF && b == EOF);
}
%}

%X STRLIT STRLITVALID LINE_COMMENT COMMENT SEMICHECK IN_COMMENT STRING
%%
                            /* Reserved declared    */

"return"                        {fprintf(yyout, "RETURN\n"); column += yyleng; BEGIN SEMICHECK;}
("package")|("return")|("for")  |
("func")|("if")|("else")        |
("var")|("int")|("float32")     |
("bool")|("string")             {fprintf(yyout, "%s\n", atoupper(yytext)); column += yyleng;}

                            /*  Reserved undeclared */

("break")|("default")|("case")  |
("interface")|("select")        |
("defer")|("go")|("map")        |
("struct")|("chan")|("goto")    |
("switch")|("const")|("import") |
("fallthrough")|("range")       |
("type")|("continue")           |
(\&\=)|\||(\-\=)|(\|\=)         |
\^|(\*\=)|(\^\=)|(\<\-)|\&      |
(\<\<)|(\>\>)|(\<\<\=)|(\+\+)   |
(\:\=)|(\%\=)|(\>\>\=)|(\+\=)   |
(\/\=)|(\:)                     |
(\-\-)|(\.\.\.)|(\&\^\=?)       {fprintf(yyout, "RESERVED(%s)\n", yytext); column += yyleng;}

                            /*  Args and puncts */

"fmt.Println"                   {fprintf(yyout, "PRINT\n"); column += yyleng;}
"strconv.Atoi"                  {fprintf(yyout, "PARSEINT\n"); column += yyleng;}
"os.Args"                       {fprintf(yyout, "CMDARGS\n"); column += yyleng;}
\,                              {fprintf(yyout, "COMMA\n"); column += yyleng;}
\_[^{letter}]                   {fprintf(yyout, "BLANKID\n"); column++; yyless(1);}
\;                              {fprintf(yyout, "SEMICOLON\n"); column += yyleng;}
\=                              {fprintf(yyout, "ASSIGN\n"); column += yyleng;}
\*                              {fprintf(yyout, "STAR\n"); column += yyleng;}
\/                              {fprintf(yyout, "DIV\n"); column += yyleng;}
\-                              {fprintf(yyout, "MINUS\n"); column += yyleng;}
\+                              {fprintf(yyout, "PLUS\n"); column += yyleng;}
\=\=                            {fprintf(yyout, "EQ\n"); column += yyleng;}
\>\=                            {fprintf(yyout, "GE\n"); column += yyleng;}
\>                              {fprintf(yyout, "GT\n"); column += yyleng;}
\<\=                            {fprintf(yyout, "LE\n"); column += yyleng;}
\<                              {fprintf(yyout, "LT\n"); column += yyleng;}
\{                              {fprintf(yyout, "LBRACE\n"); column += yyleng;}
\}                              {fprintf(yyout, "RBRACE\n"); column += yyleng; BEGIN SEMICHECK;}
\[                              {fprintf(yyout, "LSQ\n"); column += yyleng;}
\]                              {fprintf(yyout, "RSQ\n"); column += yyleng; BEGIN SEMICHECK;}
\(                              {fprintf(yyout, "LPAR\n"); column += yyleng;}
\)                              {fprintf(yyout, "RPAR\n"); column += yyleng; BEGIN SEMICHECK;}
\%                              {fprintf(yyout, "MOD\n"); column += yyleng;}
\!\=                            {fprintf(yyout, "NE\n"); column += yyleng;}
\!                              {fprintf(yyout, "NOT\n"); column += yyleng;}
\&\&                            {fprintf(yyout, "AND\n"); column += yyleng;}
\|\|                            {fprintf(yyout, "OR\n"); column += yyleng;}


\"                              {BEGIN STRING; x = column++; y = line;}


                            /* Comments */

\/\/.*                          {column += yyleng;}
\/\*                            {BEGIN COMMENT; in_comment = 1; x = column, y = line; column += yyleng;}

                            /*  Numbers and literals    */

{float}                         {fprintf(yyout, "REALLIT(%s)\n", yytext); column += yyleng; BEGIN SEMICHECK;}
0[xX]{hex}*                     {
                                  fprintf(yyout, "INTLIT(%s)\n", yytext);
                                  column += yyleng;
                                  BEGIN SEMICHECK;
                                }
0[0-7]+                         {
                                  fprintf(yyout, "INTLIT(%s)\n", yytext); column += yyleng;
                                  BEGIN SEMICHECK;
                                }
0[0-9]*[89]+[0-9]*              {
                                  fprintf(yyout, "Line %d, column %d: invalid octal constant (%s)\n", line, column, yytext);
                                  column += yyleng;
                                }
{num}+                          {
                                  fprintf(yyout, "INTLIT(%s)\n", yytext);
                                  column += yyleng; BEGIN SEMICHECK;
                                }
{id}                            {fprintf(yyout, "ID(%s)\n", yytext); column += yyleng; BEGIN SEMICHECK;}

                            /*  Regular lines   */

{whitespace}                    {column+=yyleng;}
\n|(\r\n)                       {line++;column = 1;}
.                               {
                                  fprintf(yyout, "Line %d, column %d: illegal character (%c)\n",
                                          line, column, yytext[0]); column += yyleng;
                                }

<STRING>\\\n                    {
                                  literror = true;
                                  fprintf(yyout, "Line %d, column %d: invalid escape sequence (\\)\n",
                                  line, column++);
                                  yyless(1);
                                }
<STRING>\"                      {
                                  column++;
                                  addLit(0);
                                  if(!literror){
                                    BEGIN SEMICHECK;
                                    fprintf(yyout, "STRLIT(\"%s\")\n", literal);
                                  }
                                  else BEGIN 0;
                                  literror = false;
                                  literalPos = 0;
                                }
<STRING>{invalid_escape}        {
                                  literror = true;
                                  fprintf(yyout, "Line %d, column %d: invalid escape sequence (%s)\n",
                                  line, column++, yytext);
                                }
<STRING>{valid_escape}          {
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
<SEMICHECK>\/\/                 {fprintf(yyout, "SEMICOLON\n"); BEGIN 0; yyless(0);}
<SEMICHECK>\/\*                 {BEGIN IN_COMMENT; in_comment = 1; x = column, y = line; column += yyleng;}
<SEMICHECK>\n                   {line++; column = 1; fprintf(yyout, "SEMICOLON\n"); BEGIN 0;}
<SEMICHECK><<EOF>>              {fprintf(yyout, "SEMICOLON\n");}
<SEMICHECK>.                    {BEGIN 0; yyless(0); ECHO;}

<IN_COMMENT>\*\/                {BEGIN SEMICHECK; column += yyleng; in_comment = 0;}
<IN_COMMENT>.                   {column += yyleng;}
<IN_COMMENT>\n                  {line++; column = 1; fprintf(yyout, "SEMICOLON\n"); BEGIN COMMENT;}


<COMMENT>\*\/                   {BEGIN 0; column += yyleng; in_comment = 0;}
<COMMENT>.                      {column += yyleng;}
<COMMENT>\n                     {line++; column = 1;}
%%

int main(){
  if (in_comment) fprintf(yyout, "Line %d, column %d: unterminated comment\n", y, x);
  yylex();
  return 0;
}
int yywrap()
{
return 1;
}
