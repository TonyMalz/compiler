%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <ctype.h> 
	#define YYERROR_VERBOSE 1
	#define MAX_SYMBOLS 100

	extern FILE *yyin;

	int yylex(void);
	int yyerror(const char *s);
	
	char* symbolNames[MAX_SYMBOLS];
	int  symbolValues[MAX_SYMBOLS];

	void initSymTable();
	int symbolVal(char* id);
	void updateSymTable(char* symbol, int val);
	int symbolWasInitialised();

	void errorInitID(char* id);

	int nErrors = 0;
%}

%locations

/* Token and type definitions */
%union { int num; char* id; }

%token LET   "keyword `let`"
%token AND   "keyword `and`"
%token IN    "keyword `in`"
%token END 0 "end of file"

%token <num> NUMBER "number"
%token <id>  ID "identifier"

/* Types of non-terminals */
%type <num> stmt exp term
%type <id>  assign 

/* Precedence  and associativity defintions */
%left '+' '-'
%left '*'

%%
stmt : LET assignlist IN exp { if(nErrors==0) printf("Expression result = %d\n", $4); }
	 | LET error IN exp 	 { ; }
	 ;

assignlist : assign
		   | assign error
		   | assign AND assignlist
		   | assign error AND assignlist
		   ;

assign  : ID '=' exp { $$ = $1; updateSymTable($1,$3); }
		| ID error   { $$ = $1; }
		;

exp : term		    { $$ = $1; } 
	| exp '+' exp 	{ $$ = $1 + $3; }
	| exp '-' exp 	{ $$ = $1 - $3; }
	| exp '*' exp 	{ $$ = $1 * $3; }
	| '(' exp ')'	{ $$ = $2; }
	;

term : NUMBER	{ $$ = $1; }
	 | ID  		{ (symbolWasInitialised($1)) ? $$ = symbolVal($1) : errorInitID($1) ; }
%%

void initSymTable(){
	for (int i=0; i<MAX_SYMBOLS; i++){
		symbolNames[i] = NULL;
		symbolValues[i] = 0;
	}
}

int symbolWasInitialised(char* symbol){
	int found = 0;
	for (int i=0; i<MAX_SYMBOLS; ++i){
		if (symbolNames[i] == NULL) {
			break;
		}
		// if strings are equal => symbol was initialised before
		if (strcmp(symbolNames[i],symbol) == 0){
			found = 1;
			break;
		}
	}
	return found;
}

int computeSymbolIndex(char* token){
	int idx = -1;
	for (int i=0; i<MAX_SYMBOLS; ++i){
		if (symbolNames[i] == NULL) {
			idx = i;
			// add token to symbol table
			symbolNames[i] = malloc(strlen(token)+1);
			strcpy(symbolNames[i],token);
			break;
		}
		// if strings are equal
		if (strcmp(symbolNames[i],token) == 0){
			idx = i;
			break;
		}
	}
	return idx;
}

int symbolVal(char* symbol){
	return symbolValues[computeSymbolIndex(symbol)];
}

void updateSymTable(char* symbol, int val){
	symbolValues[computeSymbolIndex(symbol)] = val;
}

// Main function to parse from a file, specified as a parameter
int main (int argc, char *argv[]) {
	// Open a file handle to the user's specified file
	FILE *myfile = fopen(argv[1], "r");
	
	// Check that the file can be opened
	if (!myfile) {
		printf("I cannot open %s!\n", argv[1]);
		return -1;
	}
	initSymTable();
	// Set Lex to read from the file, instead of STDIN
	yyin = myfile;

	printf("\n");
	int parseResult = yyparse();
	printf("\n");
	
	return parseResult;
}

void errorInitID(char* token){
	char* msg = "syntax error, identifier `%s` is used before it was initialised";
	char str[strlen(msg)+strlen(token)+2];
	sprintf(str, msg, token);
	yyerror(str);
}
// Error handling function
int yyerror(const char *s) {
	++nErrors;
	fprintf(stderr, "Error %d (line %d, characters %d-%d):\n %s\n\n", nErrors, yylloc.first_line, yylloc.first_column, yylloc.last_column, s);
	
	return 0;
}
