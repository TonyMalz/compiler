a1: yacc_template.y
	yacc -d yacc_template.y
	lex lex_template.lex
	gcc -o IntEval y.tab.c lex.yy.c

