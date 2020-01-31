%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <ctype.h> 
	#define YYERROR_VERBOSE 1

	extern FILE *yyin;

	int yylex(void);
	int yyerror(const char *s);
	
	int symbols[52];
	int symbolVal(char symbol);
	void updateSymTable(char symbol, int val);
	
	int nErrors = 0;
%}

%locations

/* Token and type definitions */
%union { int num; char id; }

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
stmt : LET assignlist IN exp { printf("Expression result = %d\n", $4); }
	 | LET error IN exp 	 { $$ = $4; printf("Expression result = %d\n", $4); }
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
	 | ID  		{ $$ = symbolVal($1); }
%%

int computeSymbolIndex(char token){
	int idx = -1;
	if(islower(token)){
		idx = token - 'a' + 26;
	} else if (isupper(token)){
		idx = token - 'A';
	}
	return idx;
}

int symbolVal(char symbol){
	return symbols[computeSymbolIndex(symbol)];
}

void updateSymTable(char symbol, int val){
	symbols[computeSymbolIndex(symbol)] = val;
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
	for (int i=0; i<52; i++){
		symbols[i]=0;
	}
	// Set Lex to read from the file, instead of STDIN
	yyin = myfile;

	printf("\n");
	int parseResult = yyparse();
	printf("\n");
	
	return parseResult;
}

// Error handling function
int yyerror(const char *s) {
	++nErrors;
	fprintf(stderr, "\nError %d (line %d, characters %d-%d):\n %s\n", nErrors, yylloc.first_line, yylloc.first_column, yylloc.last_column, s);
	
	return 0;
}
