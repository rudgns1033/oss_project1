%{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
using namespace std;

extern "C" int yylex();
void yyerror(const char *s);

%}

%define api.value.type {double}
%token NUMBER
%token EOL
%left '+' '-'
%left '*' '/'
%right UMINUS

%%
input
    : 
    | input expr EOL { printf("%g\n", $2); }
    ;

expr
    : expr '+' expr { $$ = $1 + $3; }
    | expr '-' expr { $$ = $1 - $3; }
    | expr '*' expr { $$ = $1 * $3; }
    | expr '/' expr { if ($3 == 0) { cerr<<"error\n"; exit(1);} $$ = $1 / $3; }
    | '(' expr ')'  { $$ = $2; }
    | '-' expr %prec UMINUS { $$ = -$2; }
    | NUMBER        { $$ = $1; }
    ;
%%

void yyerror(const char *s){
	cerr <<"error\n";
	exit(1);
}

int main() {
    return yyparse();
}
