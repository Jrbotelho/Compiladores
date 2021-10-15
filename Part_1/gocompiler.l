    /* João Ricardo Miranda Botelho 2019155348  */

letter                          ([a-z]|[A-Z]|\_)
num                             [0-9]
alphanum                        {letter}|{num}
hex                             [0-9a-fA-F]
expo                            [Ee]{num}+([+-])?
float                           {num}*\.{num}*({num}{expo})?
num_finish                      " "|\)|\;|\{|\}|\]|\t|\,
operator                        [-+*/&|]
invalid_escape                  \\[^nrft\\\"]
whitespace                      [ \t\f\s]

%{
    #include <ctype.h>
    #include <stdbool.h>
    int line = 1, column = 1;
    int x = 0, y = 0;
    int lx = 0, ly = 0;
    bool in_comment = 0, in_literal = 0;
    char* atoupper(char* str){
        for (int i = 0; str[i] != 0; i++) str[i] = toupper(str[i]);
        return str;
    }
%}

%X STRLIT OCTAL HEX DEC LINE_COMMENT COMMENT
%%
                                /* Reserved declared    */

("package")|("return")|("for")  |
("func")|("if")|("else")        |
("var")|("int")|("float32")     |
("bool")|("string")             {fprintf(yyout, "%s\n", atoupper(yytext)); column += yyleng;}

                                /*  Reserved undeclared */

("break")|("default")|("case")  |
("interface")|("select")        |
("defer")|("go")|("map")        |
("struct")|("chan")|("goto")    |
("switch")|("const")            |
("fallthrough")|("range")       |
("type")|("continue")           |
(\&\=)|\||(\-\=)|(\|\=)         |
\^|(\*\=)|(\^\=)|(\<\-)         |
(\<\<)|(\>\>)|(\<\<\=)          |
(\:\=)|(\%\=)|(\>\>\=)          |
(\-\-)|(\.\.\.)|(\:)|(\&\^\=?)  {fprintf(yyout, "RESERVED\n"); column += yyleng;}

                                /*  Args and puncts */

"fmt.Println"                   {fprintf(yyout, "PRINT\n"); column += yyleng;}
"strconv.Atoi"                  {fprintf(yyout, "PARSEINT\n"); column += yyleng;}
"os.Args"                       {fprintf(yyout, "CMDARGS\n"); column += yyleng;}
\,                              {fprintf(yyout, "COMMA\n"); column += yyleng;}
[^{letter}]\_[^{letter}]        {fprintf(yyout, "BLANKID\n"); column += yyleng;}
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
\}                              {fprintf(yyout, "RBRACE\n"); column += yyleng;}
\[                              {fprintf(yyout, "LSQ\n"); column += yyleng;}
\]                              {fprintf(yyout, "RSQ\n"); column += yyleng;}
\(                              {fprintf(yyout, "LPAR\n"); column += yyleng;}
\)                              {fprintf(yyout, "RPAR\n"); column += yyleng;}
\%                              {fprintf(yyout, "MOD\n"); column += yyleng;}
\!\=                            {fprintf(yyout, "NE\n"); column += yyleng;}
\!                              {fprintf(yyout, "NOT\n"); column += yyleng;}
\&\&                            {fprintf(yyout, "AND\n"); column += yyleng;}
\|\|                            {fprintf(yyout, "OR\n"); column += yyleng;}

                                /* Comments */

\/\/                            {BEGIN LINE_COMMENT; column += yyleng;}
\/\*                            {BEGIN COMMENT; in_comment = 1; x = column, y = line;}

                                /*  Numbers and literals    */

\"                              {
                                    BEGIN STRLIT;
                                    fprintf(yyout, "STRLIT(");
                                    column += yyleng;
                                    in_literal = 1;
                                    ly = line, lx = column;
                                }
[+-]?0(X|x){hex}                {
                                    BEGIN HEX;
                                    fprintf(yyout, "INTLIT(%s0x", yytext[0] == '-'? "-" : "");
                                    column += yyleng-1; yyless(yyleng-1);}
[+-]?0[0-7]                     {
                                    BEGIN OCTAL;
                                    fprintf(yyout, "INTLIT(%s0", yytext[0] == '-' ? "-" : "");
                                    column += yyleng-1; yyless(yyleng-1);
                                }
[+-]?{num}                      {
                                    BEGIN DEC;
                                    fprintf(yyout, "INTLIT(%s", yytext[0] == '-' ? "-" : "");
                                    column += yyleng-1; yyless(yyleng-1);
                                }
{letter}{alphanum}*             {fprintf(yyout, "ID(%s)\n", yytext); column += yyleng;}
^{float}                        {fprintf(yyout, "REALINT(%s)\n", yytext); column += yyleng;}
" "{float}                      {fprintf(yyout, "REALINT(%s)\n", &yytext[1]); column += yyleng;}

                                /*  Regular lines   */

{whitespace}                    {ECHO; column ++;}
\n                              {line++;column = 1;}
.                               {printf("Line %d, column %d: illegal character (%d)\n", line, column++, yytext[0]);}

                                /*  Hex */

<HEX>{hex}                      {ECHO;column++;}
<HEX>{num_finish}|{operator}    {fprintf(yyout, ")\n"); BEGIN 0; yyless(0);}
<HEX>.                          {printf("Line %d, column %d: illegal hex constant (%c)\n", line, column++, yytext[0]);}

                                /*  Dec */

<DEC>{num}                      {ECHO; column++;}
<DEC>{num_finish}|{operator}    {fprintf(yyout, ")\n"); BEGIN 0; yyless(0);}
<DEC>.                          {printf("Line %d, column %d: illegal dec constant (%c)\n", line, column++, yytext[0]);}

                                /*  Octal   */

<OCTAL>[0-7]                    {ECHO;column++;}
<OCTAL>{num_finish}|{operator}  {fprintf(yyout, ")\n"); BEGIN 0; yyless(0);}
<OCTAL>.                        {printf("Line %d, column %d: illegal octal constant (%c)\n", line, column++, yytext[0]);
                                column += yyleng;}

                                /*  Str Literal */

<STRLIT>{invalid_escape}        {
                                    printf("Line %d, column %d: invalid escape sequence (%c)\n",
                                    line, column++, yytext[yyleng-1]);
                                }
<STRLIT>\\.                     {ECHO; column += yyleng;}
<STRLIT>\"                      {BEGIN 0; fprintf(yyout, ")\n"); column += yyleng; in_literal = 0;}
<STRLIT>\n                      {ECHO; line++;column = 1;}
<STRLIT>.                       {ECHO; column += yyleng;}

                                /* Line Comment */

<LINE_COMMENT>[^\n\r]           {column += yyleng;}
<LINE_COMMENT>\n              {BEGIN 0; column = 1; line++;}

                                /*  Comment */

<COMMENT>\*\/                   {BEGIN 0; column += yyleng; in_comment = 0;}
<COMMENT>.                      {column += yyleng;}
<COMMENT>\n                     {line++; column = 1;}
%%

int main()
{
//FILE* f2 = fopen("texto_output.txt", "w");
//yyout = f2;
yylex();
//fclose(f2);
if (in_literal) printf("Line %d, column %d: unterminated literal\n", ly, lx);
if (in_comment) printf("Line %d, column %d: unterminated comment\n", y, x);
return 0;
}
int yywrap()
{
return 1;
}
