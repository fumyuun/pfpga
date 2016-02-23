all: parser

clean:
	rm -f parser tokens.cpp parser.cpp parser.hpp

parser.cpp: parser.y ast_node.h
	bison -d -o parser.cpp parser.y

tokens.cpp: tokens.l ast_node.h
	lex -o tokens.cpp tokens.l

parser:	main.cpp parser.cpp tokens.cpp
	clang++ -o parser main.cpp parser.cpp tokens.cpp
