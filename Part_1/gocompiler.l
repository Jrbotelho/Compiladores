    /* João Ricardo Miranda Botelho 2019155348  */
    /* José Pedro Silvério Braz     2017247538  */

letter                          ([a-z]|[A-Z]|\_)
num                             [0-9]
alphanum                        {letter}|{num}
id                              {letter}{alphanum}*
hex                             [0-9a-fA-F]
expo                            [eE][+-]?{num}+
float_1                         {num}*\.{num}*({num}{expo})?
float_2                         {num}+{expo}
float                           {float_1}|{float_2}
num_finish                      " "|\)|\;|\{|\}|\]|\t|\,
operator                        [-+*/&|]
invalid_escape                  \\[^nrft\\\"]
whitespace                      [ \t\f\s]

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
    bool semicolon = false;

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

%X STRLIT STRLITVALID OCTAL HEX DEC LINE_COMMENT COMMENT
%%
                                /* Reserved declared    */

"return"{whitespace}*\n         {fprintf(yyout, "RETURN\nSEMICOLON\n"); yyless(yyleng-1);}
("package")|("return")|("for")  |
("func")|("if")|("else")        |
("var")|("int")|("float32")     |
("bool")|("string")             {fprintf(yyout, "%s\n", atoupper(yytext)); column += yyleng;}

("package"){whitespace}*\n?     |
("for"){whitespace}*\n?         |
("func"){whitespace}*\n?        |
("if"){whitespace}*\n?          |
("else"){whitespace}*\n?        |
("var"){whitespace}*\n?         |
("int"){whitespace}*\n?         |
("float32"){whitespace}*\n?     |
("bool"){whitespace}*\n?        |
("string"){whitespace}*\n?      {
                                    fprintf(yyout, "%s\n", atoupper(trim_whitespace(yytext))); column += yyleng;
                                    yyless(strlen(trim_whitespace(yytext)));
                                }

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

"default"{whitespace}*\n?       |
"case"{whitespace}*\n?          |
"interface"{whitespace}*\n?     |
"select"{whitespace}*\n?        |
"defer"{whitespace}*\n?         |
"go"{whitespace}*\n?            |
"map"{whitespace}*\n?           |
"struct"{whitespace}*\n?        |
"chan"{whitespace}*\n?          |
"goto"{whitespace}*\n?          |
"switch"{whitespace}*\n?        |
"const"{whitespace}*\n?         |
"import"{whitespace}*\n?        |
"fallthrough"{whitespace}*\n?   |
"range"{whitespace}*\n?         |
"type"{whitespace}*\n?          |
"continue"{whitespace}*\n?      |
"break"{whitespace}*\n?         {
                                  fprintf(yyout, "RESERVED(%s)\n", atoupper(trim_whitespace(yytext)));
                                  column += yyleng;
                                  yyless(strlen(trim_whitespace(yytext)));
                                }

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
\}{whitespace}*\n               {fprintf(yyout, "RBRACE\nSEMICOLON\n"); yyless(yyleng-1);}
\}                              {fprintf(yyout, "RBRACE\n"); column += yyleng;}
\[                              {fprintf(yyout, "LSQ\n"); column += yyleng;}
\]{whitespace}*\n               {fprintf(yyout, "RSQ\nSEMICOLON\n"); yyless(yyleng-1);}
\]                              {fprintf(yyout, "RSQ\n"); column += yyleng;}
\(                              {fprintf(yyout, "LPAR\n"); column += yyleng;}
\){whitespace}*\n               {fprintf(yyout, "RPAR\nSEMICOLON\n"); yyless(yyleng-1);}
\)                              {fprintf(yyout, "RPAR\n"); column += yyleng;}
\%                              {fprintf(yyout, "MOD\n"); column += yyleng;}
\!\=                            {fprintf(yyout, "NE\n"); column += yyleng;}
\!                              {fprintf(yyout, "NOT\n"); column += yyleng;}
\&\&                            {fprintf(yyout, "AND\n"); column += yyleng;}
\|\|                            {fprintf(yyout, "OR\n"); column += yyleng;}

                                /* Comments */

\/\/                            {BEGIN LINE_COMMENT; column += yyleng;}
\/\*                            {BEGIN COMMENT; in_comment = 1; x = column, y = line; column += yyleng;}

                                /*  Numbers and literals    */

\"                              {
                                    BEGIN STRLITVALID;
                                    column += yyleng;
                                    ly = line, lx = column;
                                }
0(X|x){hex}                     {
                                    BEGIN HEX;
                                    char x = yytext[yyleng-1];
                                    yytext[yyleng-1] = 0;
                                    fprintf(yyout, "INTLIT(%s", yytext);
                                    yytext[yyleng-1] = x;
                                    column += yyleng-1; yyless(yyleng-1);}
{float}{whitespace}*\n          {
                                    fprintf(yyout, "REALLIT(%s)\nSEMICOLON\n",
                                            trim_whitespace(yytext));
                                    yyless(yyleng-1);}
{float}                         {fprintf(yyout, "REALLIT(%s)\n", yytext); column += yyleng;}
0{num}                          {
                                    BEGIN OCTAL;
                                    addOctal('0');
                                    column += yyleng-1; yyless(yyleng-1);
                                }
{num}                           {
                                    BEGIN DEC;
                                    fprintf(yyout, "INTLIT(");
                                    column += yyleng-1; yyless(yyleng-1);
                                }
{id}{whitespace}*\n             {
                                    yytext[yyleng-1] = 0;
                                    fprintf(yyout, "ID(%s)\nSEMICOLON\n", yytext);
                                    yytext[yyleng-1] = '\n'; yyless(yyleng-1);
                                }
{id}                            {fprintf(yyout, "ID(%s)\n", yytext); column += yyleng;}

                                /*  Regular lines   */

{whitespace}                    {column+=yyleng;}
\n|(\r\n)                       {line++;column = 1;}
.                               {
                                fprintf(yyout, "Line %d, column %d: illegal character (%c)\n",
                                        line, column+=yyleng, yytext[0]);
                                }

                                /*  Hex */

<HEX>{hex}{whitespace}*\n       {fprintf(yyout, "%c", yytext[0]); semicolon = true; yyless(yyleng-1);}
<HEX>{hex}                      {ECHO;column+=yyleng;}
<HEX>.|\n                       {
                                    fprintf(yyout, ")\n");
                                    if (semicolon) fprintf(yyout, "SEMICOLON\n");
                                    BEGIN 0; yyless(0);
                                    semicolon = false;
                                }

                                /*  Dec */

<DEC>{num}{whitespace}*\n       {fprintf(yyout, "%c", yytext[0]); semicolon = true; yyless(yyleng-1);}
<DEC>{num}                      {ECHO; column+=yyleng;}
<DEC>.|\n                       {
                                    fprintf(yyout, ")\n");
                                    if (semicolon) fprintf(yyout, "SEMICOLON\n");
                                    BEGIN 0; yyless(0);
                                    semicolon = false;
                                }

                                /*  Octal   */

<OCTAL>[0-9]{whitespace}*\n     {addOctal(yytext[0]); validOctal(yytext[0]); yyless(yyleng-1); semicolon = true; }
<OCTAL>[0-9]                    {addOctal(yytext[0]); validOctal(yytext[0]); column+=yyleng;}
<OCTAL>.|\n                     {
                                    octal[octalPos] = 0;
                                    if (octalError){
                                      fprintf(yyout, "Line %d, column %d: invalid octal constant (%s)\n",
                                             line, column - octalPos, octal);
                                      printf("%d - %d\n",column, octalPos);
                                      octalError = false;
                                    }else fprintf(yyout, "INTLIT(%s)\n", octal);
                                    if (semicolon)fprintf(yyout, "SEMICOLON\n");
                                    semicolon = false;
                                    octalPos = 0;
                                    BEGIN 0; yyless(0);
                                }

                                /*  Str Literal */

<STRLITVALID>[^\"]\n            {
                                    fprintf(yyout, "Line %d, column %d: unterminated literal\n", ly, lx);
                                    BEGIN 0;
                                    yyless(0);
                                }
<STRLITVALID>.                  {fprintf(yyout, "STRLIT(\""); BEGIN STRLIT; yyless(0);}
<STRLIT>{invalid_escape}        {
                                    fprintf(yyout, "\")\nLine %d, column %d: invalid escape sequence (%c)\n"
                                    "STRLIT(\"",
                                    line, (column+=yyleng)-1, yytext[yyleng-1]);
                                }
<STRLIT>\\.                     {ECHO; column += yyleng;}
<STRLIT>\"{whitespace}*\n       {BEGIN 0; fprintf(yyout, "\")\nSEMICOLON\n"); yyless(yyleng-1);}
<STRLIT>\"                      {BEGIN 0; fprintf(yyout, "\")\n"); column += yyleng;}
<STRLIT>.                       {ECHO; column += yyleng;}

                                /* Line Comment */

<LINE_COMMENT>[^\n\r]           {column += yyleng;}
<LINE_COMMENT>\n                {BEGIN 0; column = 1; line++;}

                                /*  Comment */

<COMMENT>\*\/                   {BEGIN 0; column += yyleng; in_comment = 0;}
<COMMENT>.                      {column += yyleng;}
<COMMENT>\n                     {line++; column = 1;}
%%

int main()
{
FILE* f = fopen("../testes/semicolons_1.dgo", "r");
FILE* f1 = fopen("../testes/semicolons_1.out", "r");
FILE* f2 = fopen("texto_output.txt", "w");
//yyin = f;
//yyout = f2;
yylex();
if (in_comment) fprintf(yyout, "Line %d, column %d: unterminated comment\n", y, x);
fclose(f2);
f2 = fopen("texto_output.txt", "r");
if (textComparer(f1, f2))printf("Works!\n");
else printf("?\n");
fclose(f2);
fclose(f);
fclose(f1);
return 0;
}
int yywrap()
{
return 1;
}
