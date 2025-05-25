all: postfix

postfix.tab.c postfix.tab.h: postfix.y
	bison -d postfix.y

lex.yy.c: postfix.l
	flex -o lex.yy.c postfix.l

postfix: postfix.tab.c lex.yy.c
	g++ -o postfix postfix.tab.c lex.yy.c -lfl

clean:
	rm -f postfix postfix.tab.c postfix.tab.h lex.yy.c

