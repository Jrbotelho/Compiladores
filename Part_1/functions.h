/* João Ricardo Miranda Botelho 2019155348  */
/* José Pedro Silvério Braz     2017247538  */

#ifndef FUNCTIONS_H
#define FUNCTIONS_H

#include "structures.h"

#include "symtable.h"


node* add_next(node* head, node* ret);

node* add_down(node* head, node* ret);

node* create(char* val);

void print_tree(node* root, node* parent, int depth, FILE* out);

int count_depth(node* root);

void build_symtab(node* root, node* parent_node, table* parent_tab);

void print_noted_tree(node* root, node* parent, int depth, FILE* out);

#endif