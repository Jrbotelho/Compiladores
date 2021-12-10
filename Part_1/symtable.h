#ifndef SYMTABLE_H
#define SYMTABLE_H

#include "stdbool.h"

#define MAX_STR 1000

#define GLOB 0
#define FUN 1

typedef struct s_2{
    char* type;
    struct s_2* next;
}type_list;

typedef struct{
    char* name;
    char* type;
    type_list* params;
    bool is_param;
    bool is_func;
}table_el;

typedef struct s_1{
    table_el* val;
    struct s_1* next;
}el_list;

typedef struct scope{
    char* scope;
    int type;
    el_list* val;
    struct scope* next;
}table;

table_el* create_el(char* name, char* type, bool is_param, type_list* params, bool is_func);

type_list* add_type(type_list* head, char* type);

void print_table();

el_list* add_to_scope(table* scope, table_el* val);

table* add_scope(char* scope, int type);

table_el* var_in_table(char* name);

#endif