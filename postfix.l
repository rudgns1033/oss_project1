%option noyywrap
%{
#include "postfix.tab.h"
extern "C" int yylex();
extern "C" void yyerror(const char *);
extern double yylval;
%}
number    [0-9]+(\.[0-9]*)?([Ee][+-]?[0-9]+)?
%%
[ \t]+		;       
";"		{ return EOL; }     
{number}	   { sscanf(yytext, "%lf", &yylval); return NUMBER; }
.		{ return yytext[0]; }
%%
