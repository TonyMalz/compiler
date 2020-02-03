%{
	/*
	Author: Tony Malzhacker (1746803)
	Solution to Question 6.1 and 6.2
	*/
	
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
[ \t]       { ++pos; }
\n          { pos=1; ++line; }
"let"		{ calcTokenLocation(); return LET; }
"and"		{ calcTokenLocation(); return AND; }
"in"		{ calcTokenLocation(); return IN; }
[-+=*()]	{ calcTokenLocation(); return yytext[0]; }
[a-zA-Z]+[^ =\ta-zA-Z]+/[ =\t]  { calcTokenLocation(); printError(); }
[0-9]+		{ calcTokenLocation(); yylval.num = atoi(yytext); return NUMBER; }	
[a-zA-Z]+ 	{ calcTokenLocation(); yylval.id = malloc(yyleng); strcpy(yylval.id, yytext); return ID; }
.			{ calcTokenLocation(); printError(); }
%%

void calcTokenLocation(){
	yylloc.first_line = yylloc.last_line = line;
	yylloc.first_column=pos;
	pos+=yyleng;
	yylloc.last_column=pos-1;
}

void printError(){
	char* msg = "lexical error, unrecognized input string `%s`";
	int lenMsg = strlen(msg);
	char str[lenMsg+yyleng];

	sprintf(str, msg, yytext);
	yyerror(str);
}