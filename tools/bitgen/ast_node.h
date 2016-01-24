#include <iostream>
#include <vector>
#include <string>

enum AST_Type {
    AST_NODE,
    AST_EXP,
    AST_ID,
    AST_BEXP,
    AST_UEXP
};

struct AST_Node {
    virtual ~AST_Node() {}
    virtual std::string prettyPrint() {return "ERROR";}
    virtual AST_Type getType() {return AST_NODE;}
};

struct AST_Expression : public AST_Node {
    AST_Type getType() {return AST_EXP;};
};

struct AST_Identifier : public AST_Node {
    std::string name;
    AST_Identifier(const std::string name) : name(name) {}
    std::string prettyPrint() {return name;}
    AST_Type getType() {return AST_ID;}
};

struct AST_BinaryExpression : public AST_Expression {
    int op;
    AST_Expression& lhs;
    AST_Expression& rhs;
    AST_BinaryExpression(AST_Expression& lhs, int op, AST_Expression& rhs) :
        lhs(lhs), rhs(rhs), op(op) {}
    std::string prettyPrint() {return "(" + lhs.prettyPrint() + " op " + rhs.prettyPrint() + ")"; }
    AST_Type getType() {return AST_BEXP;};
};

struct AST_UnaryExpression : public AST_Expression {
    int op;
    AST_Expression& child;
    AST_UnaryExpression(int op, AST_Expression& child) :
        op(op), child(child) {}
    std::string prettyPrint() {return "op " + child.prettyPrint();}
    AST_Type getType() {return AST_UEXP;};
};
