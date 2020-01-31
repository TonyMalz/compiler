%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h> 
	#include "y.tab.h"

	extern int yyerror(const char *s);
	
	int pos = 1;
	int line = 1;
	void calcTokenLocation();
	void printError();
%}

%option noyywrap

%%
"let"		{ calcTokenLocation(); return LET; }
"and"		{ calcTokenLocation(); return AND; }
"in"		{ calcTokenLocation(); return IN; }
[0-9]+		{ calcTokenLocation(); yylval.num = atoi(yytext); return NUMBER; }	
[a-zA-Z] 	{ calcTokenLocation(); yylval.id = yytext[0]; return ID; }
[ \t]	    { ++pos; }
\n          { pos=1; ++line; }
[-+=*()]	{ calcTokenLocation(); return yytext[0]; }
.			{ calcTokenLocation(); printError(); }
%%

void calcTokenLocation(){
	yylloc.first_line = yylloc.last_line = line;
	yylloc.first_column=pos;
	pos+=yyleng;
	yylloc.last_column=pos-1;
}

void printError(){
	char msg[] = "lexical error, unrecognized input string `%s`";
	char lenMsg = strlen(msg);
	char str[lenMsg+yyleng];
	
	sprintf(str,"lexical error, unrecognized input string `%s`", yytext);
	yyerror(str);
}