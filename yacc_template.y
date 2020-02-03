%{
	/*
	Author: Tony Malzhacker (1746803)
	Solution to Question 6.1 and 6.2
	
	!! IMPORTANT assumption was made:
	The evaluated expression following keyword `in` shall only
	contain identifiers of integer variables.

	Hence, the grammar does not allow mixing of integer literals and variables (IDs) for this rule! 
	
	To also allow integer literals and variables, the start rule has to be changed to:

	stmt : LET assignlist IN exp  { if(nErrors==0) printf("Expression result = %d\n", $4); }
	 	 | LET error IN exp 	  { ; }
	 	 ;

	*/

	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <ctype.h> 
	#define YYERROR_VERBOSE 1
	#define MAX_SYMBOLS 100

	extern FILE *yyin;

	int yylex(void);
	int yyerror(const char *s);
	
	/* Arrays used to store the names and corresponding values of IDs */
	char* symbolNames[MAX_SYMBOLS];
	int  symbolValues[MAX_SYMBOLS];

	/* Function prototypes for a kind of symbol table for IDs */
	void initSymTable();
	int symbolVal(char* id);
	void updateSymTable(char* symbol, int val);
	int symbolWasInitialised();

	/* Custom error function, called if ID was used before initialisation */
	void errorInitID(char* id);

	/* Used to track total number of errors */
	int nErrors = 0;
%}

%locations

/* Token and type definitions */
%union { int num; char* id; }

%token LET   "keyword `let`"
%token AND   "keyword `and`"
%token IN    "keyword `in`"
%token END 0 "end of file"

%token <num> NUMBER "`number`"
%token <id>  ID "`identifier`"

/* Types of non-terminals */
%type <num> stmt exp term id_exp
%type <id>  assign 

/* Precedence  and associativity defintions */
%left '+' '-'
%left '*'

%%
stmt : LET assignlist IN id_exp  { if(nErrors==0) printf("Expression result = %d\n", $4); }
	 | LET error IN id_exp 	  { ; }
	 ;

assignlist : assign 						
		   | assign AND assignlist 
		   | error  AND 
		   | assign error	
		   ;

assign  : ID '=' exp    { $$ = $1; updateSymTable($1,$3); }
		;

exp : term		    { $$ = $1; } 
	| exp '+' exp 	{ $$ = $1 + $3; }
	| exp '-' exp 	{ $$ = $1 - $3; }
	| exp '*' exp 	{ $$ = $1 * $3; }
	| '(' exp ')'	{ $$ = $2; }
	;

id_exp : ID		       	{ (symbolWasInitialised($1)) ? $$ = symbolVal($1) : errorInitID($1) ;} 
	| id_exp '+' id_exp { $$ = $1 + $3; }
	| id_exp '-' id_exp { $$ = $1 - $3; }
	| id_exp '*' id_exp { $$ = $1 * $3; }
	| '(' id_exp ')'	{ $$ = $2; }
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

// Error handling functions
void errorInitID(char* token){
	char* msg = "syntax error, identifier `%s` is used before it was initialised";
	char str[strlen(msg)+strlen(token)+2];
	sprintf(str, msg, token);
	yyerror(str);
}

int yyerror(const char *s) {
	++nErrors;
	fprintf(stderr, "Error %d (line %d, characters %d-%d):\n %s\n\n", nErrors, yylloc.first_line, yylloc.first_column, yylloc.last_column, s);
	
	return 0;
}
