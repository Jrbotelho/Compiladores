/* João Ricardo Miranda Botelho 2019155348  */
/* José Pedro Silvério Braz     2017247538  */

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
#include "structures.h"
#include "y.tab.h"
int line = 1, column = 1, old_column = 1, old_line = 1;
int x = 0, y = 0;
int lx = 0, ly = 0;
char literal[1000];
int literalPos = 0;
bool octalError = false;
bool literror = false;
bool mayprint = false;

char* atoupper(char* str){
    for (int i = 0; str[i] != 0; i++) str[i] = toupper(str[i]);
    return str;
}

FILE* supposed_file(){
  return yyout;
}

void validOctal(char n){
   if (!octalError) octalError = !(n >= '0' && n <= '7');
}

void addLit(char c){
  literal[literalPos++] = c;
}

void addStrLit(char* c){
  for (int i = 0; c[i] != 0; i++) addLit(c[i]);
}

void show(int n){
  if (mayprint)
    switch(n){
      case 'r':
        fprintf(yyout, "%s\n", atoupper(yytext));
        break;
      case 'R':
        fprintf(yyout, "RESERVED(%s)\n", yytext);
        break;
      case 's':
        fprintf(yyout, "STRLIT(\"%s\")\n", literal);
        break;
      case 'i':
        fprintf(yyout, "INTLIT(%s)\n", yytext);
        break;
      case 'f':
        fprintf(yyout, "REALLIT(%s)\n", yytext);
        break;
      case 'I':
        fprintf(yyout, "ID(%s)\n", yytext);
        break;
      default:
        fprintf(yyout, "SEMICOLON\n");
    }
}

void showStr(char* s){
    if (mayprint)fprintf(yyout, "%s\n", s);
}
%}

%X STRLIT STRLITVALID LINE_COMMENT COMMENT SEMICHECK IN_COMMENT STRING
%%
                            /* Reserved declared    */

"return"                        {show('r'); old_column = column; column += yyleng; BEGIN SEMICHECK; return RETURN;}
"package"                       {show('r'); old_column = column; column += yyleng;return PACKAGE;}
"for"                           {show('r'); column += yyleng;return FOR;}
"func"                          {show('r'); column += yyleng;return FUNC;}
"if"                            {show('r'); column += yyleng;return IF;}
"else"                          {show('r'); column += yyleng;return ELSE;}
"var"                           {show('r'); column += yyleng;return VAR;}
"int"                           {show('r'); column += yyleng;return INT;}
"float32"                       {show('r'); column += yyleng;return FLOAT32;}
"bool"                          {show('r'); column += yyleng;return BOOL;}
"string"                        {show('r'); column += yyleng;return STRNG;}

                            /*  Reserved undeclared */

("break")|("default")|("case")  |
("interface")|("select")        |
("defer")|("go")|("map")        |
("struct")|("chan")|("goto")    |
("switch")|("const")|("import") |
("fallthrough")|("range")       |
("type")|("continue")           |
(\+\+)|(\-\-)                   {show('R'); column += yyleng; return RESERVED;}

                            /*  Args and puncts */

"fmt.Println"                   {showStr("PRINT"); column += yyleng;return PRINT;}
"strconv.Atoi"                  {showStr("PARSEINT"); column += yyleng;return PARSEINT;}
"os.Args"                       {showStr("CMDARGS"); column += yyleng;return CMDARGS;}
\,                              {showStr("COMMA"); column += yyleng;return COMMA;}
_                               {showStr("BLANKID"); column++;return BLANKID;}
\;                              {showStr("SEMICOLON"); column += yyleng;return SEMICOLON;}
\=                              {showStr("ASSIGN"); column += yyleng;return ASSIGN;}
\*                              {showStr("STAR"); column += yyleng;return STAR;}
\/                              {showStr("DIV"); column += yyleng;return DIV;}
\-                              {showStr("MINUS"); column += yyleng;return MINUS;}
\+                              {showStr("PLUS"); column += yyleng;return PLUS;}
\=\=                            {showStr("EQ"); column += yyleng;return EQ;}
\>\=                            {showStr("GE"); column += yyleng;return GE;}
\>                              {showStr("GT"); column += yyleng;return GT;}
\<\=                            {showStr("LE"); column += yyleng;return LE;}
\<                              {showStr("LT"); column += yyleng;return LT;}
\{                              {showStr("LBRACE"); column += yyleng;return LBRACE;}
\}                              {showStr("RBRACE"); column += yyleng; BEGIN SEMICHECK;return RBRACE;}
\[                              {showStr("LSQ"); column += yyleng;return LSQ;}
\]                              {showStr("RSQ"); column += yyleng; BEGIN SEMICHECK;return RSQ;}
\(                              {showStr("LPAR"); column += yyleng;return LPAR;}
\)                              {showStr("RPAR"); column += yyleng; BEGIN SEMICHECK;return RPAR;}
\%                              {showStr("MOD"); column += yyleng;return MOD;}
\!\=                            {showStr("NE"); column += yyleng;return NE;}
\!                              {showStr("NOT"); column += yyleng;return NOT;}
\&\&                            {showStr("AND"); column += yyleng;return AND;}
\|\|                            {showStr("OR"); column += yyleng;return OR;}


\"                              {BEGIN STRING; x = column++; y = line;}


                            /* Comments */

\/\/.*                          {;}
\/\*                            {BEGIN COMMENT; x = column, y = line; column += yyleng;}

                            /*  Numbers and literals    */

{float}                         {show('f'); column += yyleng; yylval.text = strdup(yytext); BEGIN SEMICHECK;return REALLIT;}
0[xX]{hex}+                     {show('i'); column += yyleng; BEGIN SEMICHECK;return INTLIT; yylval.text = strdup(yytext);}
0[0-7]+                         {show('i'); column += yyleng; BEGIN SEMICHECK;return INTLIT; yylval.text = strdup(yytext);}
0[0-9]*[89]+[0-9]*              {
                                  fprintf(yyout, "Line %d, column %d: invalid octal constant (%s)\n", line, column, yytext);
                                  column += yyleng;
                                }
{num}+                          {
                                  show('i'); column += yyleng; BEGIN SEMICHECK;yylval.text = strdup(yytext);return INTLIT;
                                }
{id}                            show('I'); column += yyleng; BEGIN SEMICHECK;yylval.text = strdup(yytext);return ID;
{whitespace}                    {column+=yyleng;}
\n|(\r\n)                       {old_line = line;line++;old_column = column; column = 1;}
.                               {
                                  fprintf(yyout, "Line %d, column %d: illegal character (%c)\n",
                                          line, column, yytext[0]); column += yyleng;
                                }

                            /*  Regular lines   */

<STRING>\"                      {
                                  column++;
                                  addLit(0);
                                  if(!literror){
                                    BEGIN SEMICHECK;show('s');yylval.text = strdup(literal); 
                                  }
                                  else BEGIN 0;
                                  literror = false;literalPos = 0;
                                  if (!literror) return STRLT;
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

                                /*  Check the need for Semicolons */

<SEMICHECK>{whitespace}         {column++;}
<SEMICHECK>\/\/                 {show(-1); BEGIN 0; yyless(0); return SEMICOLON;}
<SEMICHECK>\/\*                 {BEGIN IN_COMMENT; x = column, y = line; column += yyleng;}
<SEMICHECK>\n                   {old_line = line;line++; old_column = column; column = 1; show(-1); BEGIN 0; return SEMICOLON;}
<SEMICHECK><<EOF>>              {show(-1); BEGIN 0; return SEMICOLON;}
<SEMICHECK>.                    {BEGIN 0; yyless(0);}

                                /*  Comment within Semicolon Check*/

<IN_COMMENT>\*\/                {BEGIN SEMICHECK; column += yyleng;}
<IN_COMMENT><<EOF>>             {
                                  fprintf(yyout, "Line %d, column %d: unterminated comment\n", y, x);
                                  BEGIN SEMICHECK; yyless(0);
                                }
<IN_COMMENT>.                   {column += yyleng;}
<IN_COMMENT>\n                  {old_line = line;line++; old_column = column; column = 1; show(-1); BEGIN COMMENT; return SEMICOLON;}

                                /* Multiple Line Comment */

<COMMENT>\*\/                   {BEGIN 0; column += yyleng;}
<COMMENT><<EOF>>                {fprintf(yyout, "Line %d, column %d: unterminated comment\n", y, x); BEGIN 0;}
<COMMENT>.                      {column += yyleng;}
<COMMENT>\n                     {old_line = line;line++; old_column = column; column = 1;}

%%

int yywrap()
{
return 1;
}

void yyerror(char *msg) {
    int cl = 0;
    if (old_line == line + 1 && column == 1){
      if (yytext[0] == '\"'){
      cl = old_column - (strlen(literal) + 2);
      printf("Line %d, column %d: %s: \"%s\"\n", old_line, cl > 0? cl : 1, msg, literal);
      }
      else {
        cl = old_column-(int)yyleng;
        printf("Line %d, column %d: %s: %s\n", old_line, cl > 0? cl : 1, msg, yytext);
      }
    }
    else{
      if (yytext[0] == '\"'){
        cl = column - (strlen(literal) + 2);
        printf("Line %d, column %d: %s: \"%s\"\n", line, cl > 0? cl : 1, msg, literal);
      }
      else {
        cl = column-(int)yyleng;
        printf("Line %d, column %d: %s: %s\n", line, cl > 0? cl : 1, msg, yytext);
      }
    }
    
    error_occ = 1;
}