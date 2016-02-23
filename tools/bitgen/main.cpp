#include "ast_node.h"
#include "parser.hpp"
#include <iostream>
#include <map>
#include <list>

extern AST_Expression *root;
extern int yyparse();

typedef std::map<std::string, std::list<AST_Identifier*> > IdMap;
typedef std::map<std::string, bool> ValueMap;

void find_identifiers(AST_Expression &exp, IdMap &idmap);
void find_identifiers(AST_BinaryExpression &exp, IdMap &idmap);
void find_identifiers(AST_UnaryExpression &exp, IdMap &idmap);
void find_identifiers(AST_Identifier &exp, IdMap &idmap);

bool evaluate(AST_Expression &exp, ValueMap &valmap);
bool evaluate(AST_BinaryExpression &exp, ValueMap &valmap);
bool evaluate(AST_UnaryExpression &exp, ValueMap &valmap);
bool evaluate(AST_Identifier &exp, ValueMap &valmap);

ValueMap valmap_bind(IdMap &idmap, bool *vals);
ValueMap valmap_bind(IdMap &id, unsigned int code);

int main(int argc, char **argv)
{
    IdMap idmap;
    ValueMap valmap;
    int permutations_size = 0;

    yyparse();
    if (root == NULL) {
        return 1;
    }

    std::cout << root->prettyPrint() << std::endl;
    find_identifiers(*root, idmap);
    std::cout << "Found " << idmap.size() << " unique identifiers" << std::endl;
    for (auto it = idmap.begin(); it != idmap.end(); ++it) {
        std::cout << it->first << ": " << it->second.size() << " occurrences" << std::endl;
    }

    if (idmap.size() <= 2) {
        permutations_size = 2;
    } else if (idmap.size() <= 4) {
        permutations_size = 4;
    } else {
        std::cout << "More than 4 identifiers not supported yet." << std::endl;
        return 2;
    }
    std::cout << "Generating a lut" << permutations_size << "." << std::endl;

    std::cout << "0";
    for(unsigned int i = 0; i < permutations_size * permutations_size; ++i) {
        valmap = valmap_bind(idmap, i);
        std::cout << evaluate(*root, valmap);
    }
    std::cout << std::endl;


    return 0;
}

void find_identifiers(AST_Expression &exp, IdMap &idmap) {
    switch(exp.getType()) {
        case AST_BEXP:  find_identifiers((AST_BinaryExpression&)exp, idmap); break;
        case AST_UEXP:  find_identifiers((AST_UnaryExpression&)exp,  idmap); break;
        case AST_ID:    find_identifiers((AST_Identifier&)exp,       idmap); break;
        default: std::cout << "Error?" << std::endl;
    }
}

void find_identifiers(AST_BinaryExpression &exp, IdMap &idmap) {
    find_identifiers(exp.lhs, idmap);
    find_identifiers(exp.rhs, idmap);
}

void find_identifiers(AST_UnaryExpression &exp, IdMap &idmap) {
    find_identifiers(exp.child, idmap);
}

void find_identifiers(AST_Identifier &exp, IdMap &idmap) {
    idmap[exp.name].push_back(&exp);
}

bool evaluate(AST_Expression &exp, ValueMap &valmap) {
    switch(exp.getType()) {
        case AST_BEXP:  return evaluate((AST_BinaryExpression&)exp, valmap);
        case AST_UEXP:  return evaluate((AST_UnaryExpression&)exp,  valmap);
        case AST_ID:    return evaluate((AST_Identifier&)exp,       valmap);
        default: std::cout << "Error?" << std::endl;
    }
    return false;
}

bool evaluate(AST_BinaryExpression &exp, ValueMap &valmap) {
    switch(exp.op) {
        case TCEQ:  return evaluate(exp.lhs, valmap) == evaluate(exp.rhs, valmap);
        case TCNE:  return evaluate(exp.lhs, valmap) != evaluate(exp.rhs, valmap);
        case TCAND: return evaluate(exp.lhs, valmap) && evaluate(exp.rhs, valmap);
        case TCOR:  return evaluate(exp.lhs, valmap) || evaluate(exp.rhs, valmap);
        default: std::cout << "Error?" << std::endl;
    }
    return false;
}

bool evaluate(AST_UnaryExpression &exp, ValueMap &valmap) {
    switch(exp.op) {
        case TCNOT:  return !evaluate(exp.child, valmap);
        default: std::cout << "Error?" << std::endl;
    }
    return false;
}

bool evaluate(AST_Identifier &exp, ValueMap &valmap) {
    if (valmap.find(exp.name) != valmap.end()) {
        return valmap[exp.name];
    }
    return false;
}

ValueMap valmap_bind(IdMap &id, bool *vals) {
    ValueMap valmap;
    for (auto it = id.begin(); it != id.end(); ++it) {
        valmap[it->first] = *vals++;
    }
    return valmap;
}

ValueMap valmap_bind(IdMap &id, unsigned int code) {
    ValueMap valmap;
    unsigned int mask = 1;
    for (auto it = id.begin(); it != id.end(); ++it, mask <<= 1) {
        valmap[it->first] = (code & mask) == mask;
    }
    return valmap;
}
