%{
    #include "ast_node.h"
    AST_Expression *root;

    extern int yylex();
    void yyerror(const char *s) { printf("ERROR: %s\n", s); }
%}

%union {
    AST_Node *node;
    AST_Expression *expr;
    AST_Identifier *ident;
    AST_BinaryExpression *bin_op;
    AST_UnaryExpression *un_op;
    std::string *string;
    int token;
}

%token <string> TIDENTIFIER
%token <token> TCEQ TCNE TCAND TCOR TCNOT
%token <token> TLPAREN TRPAREN

%type <ident> ident
%type <expr> expr
%type <expr> expr_

%left TCEQ TCNE
%left TCAND TCOR

%start program

%%

program : expr { root = $1; }
        ;

ident : TIDENTIFIER { $$ = new AST_Identifier(*$1); delete $1; }
      ;

expr : expr TCEQ expr_ { $$ = new AST_BinaryExpression(*$1, $2, *$3); }
     | expr TCNE expr_ { $$ = new AST_BinaryExpression(*$1, $2, *$3); }
     | expr TCAND expr_ { $$ = new AST_BinaryExpression(*$1, $2, *$3); }
     | expr TCOR expr_ { $$ = new AST_BinaryExpression(*$1, $2, *$3); }
     | TCNOT expr_ { $$ = new AST_UnaryExpression($1, *$2); }
     | expr_
     ;
expr_ : TLPAREN expr TRPAREN { $$ = $2; }
     | ident { $<ident>$ = $1; }
     ;

%%