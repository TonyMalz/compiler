%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h> 
	#include "y.tab.h"

	extern int yyerror(const char *s);
	//extern void yyerror(YYLTYPE *loc, char const *msg);
	int pos = 1;
	char str[100];
	void calcTokenLocation();
	void printError();
%}

%option noyywrap

%%
"let"		{calcTokenLocation(); return LET;}
"and"		{calcTokenLocation(); return AND;}
"in"		{calcTokenLocation(); return IN;}
[0-9]+		{calcTokenLocation(); yylval.num = atoi(yytext); return NUMBER;}	
[a-zA-Z] 	{calcTokenLocation(); yylval.id = yytext[0]; return ID;}
[ \t]	    {++pos;}
\n          {pos=0;}
[-+=*()]	{calcTokenLocation(); return yytext[0];}
.			{calcTokenLocation(); printError();}
%%

void calcTokenLocation(){
	yylloc.first_column=pos;
	pos+=yyleng;
	yylloc.last_column=pos-1;
}

void printError(){
	char msg[] = "lexical error, unrecognized input string `%s`";
	char lenMsg = strlen(msg);
	char str[lenMsg+yyleng];
	sprintf(str,"lexical error, unrecognized input string `%s`",yytext);
	yyerror(str);
}