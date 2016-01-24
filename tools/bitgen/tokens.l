%{
#include <string>
#include "ast_node.h"
#include "parser.hpp"
#define SAVE_TOKEN yylval.string = new std::string(yytext, yyleng)
#define TOKEN(t) (yylval.token = t)
extern "C" int yywrap() { }
%}

%%

[a-zA-Z_][a-zA-Z0-9_]*  SAVE_TOKEN; return TIDENTIFIER;
"=="                    return TOKEN(TCEQ);
"!="                    return TOKEN(TCNE);
"&&"                    return TOKEN(TCAND);
"||"                    return TOKEN(TCOR);
"!"                     return TOKEN(TCNOT);
"("                     return TOKEN(TLPAREN);
")"                     return TOKEN(TRPAREN);
.                       printf("Unknown token!\n"); yyterminate();

%%