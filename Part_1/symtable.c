#include "symtable.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

table* symtab = NULL;

table_el* create_el(char* name, char* type, bool is_param, type_list* params, bool is_func){
    table_el* ret = (table_el*)malloc(sizeof(table_el));
    if (ret == NULL) return NULL;
    ret->name = strdup(name);
    ret->type = strdup(type);
    ret->is_param = is_param;
    ret->params = params;
    ret->is_func = is_func;
    return ret;
}

type_list* add_type(type_list* head, char* type){
    type_list* ret = (type_list*)malloc(sizeof(type_list));
    if (ret == NULL) return NULL;
    ret->next = NULL;
    ret->type = strdup(type);
    if (head == NULL) return ret;
    type_list* tmp = head;
    for(; tmp -> next != NULL; tmp = tmp->next);
    tmp->next = ret;
    return head;
}

table_el* var_in_table(char* name){
    table* tmp = symtab;
    table_el* ret = NULL;
    for (; tmp != NULL; tmp = tmp->next)
        for(el_list* vars = tmp->val; vars != NULL; vars = vars->next)
            if (strcmp(vars->val->name, name) == 0) return vars->val;
    return NULL;
}

bool scope_in_symtab(char* scope){
    table* tmp = symtab;
    for(; tmp != NULL && strcmp(scope, tmp->scope) != 0; tmp = tmp->next);
    return tmp != NULL;
}

bool var_in_scope(char* var, table* scope){
    el_list* tmp = scope->val;
    for(;tmp != NULL && strcmp(var, tmp->val->name) != 0; tmp = tmp->next);
    return tmp != NULL;
}

bool var_in_global(char* var){
    if (symtab == NULL || strcmp(symtab->scope, "Global") != 0) return 0;
    el_list* tmp = symtab->val;
    for (; tmp != NULL && strcmp(var, tmp->val->name) != 0; tmp = tmp -> next);
    return tmp != NULL;
}

table* add_scope(char* scope, int type){
    if (scope_in_symtab(scope)) return NULL;
    table* ret = (table*)malloc(sizeof(table));
    if (ret == NULL) return NULL;
    ret -> scope = strdup(scope);
    ret->type = type;
    ret->next = NULL;
    ret->val = NULL;
    if (symtab == NULL) {symtab = ret; return ret;}
    table* tmp = symtab;
    for(; tmp -> next != NULL; tmp = tmp->next);
    tmp->next = ret;
    return ret;
}

el_list* add_to_scope(table* scope, table_el* val){
    if (scope == NULL || scope_in_symtab(val->name) || var_in_scope(val->name, scope) || var_in_global(val->name)) return NULL;
    el_list* ret = (el_list*)malloc(sizeof(el_list));
    if (ret == NULL) return NULL;
    ret->val = val;
    ret->next = NULL;
    if (scope->val == NULL) {scope->val = ret; return ret;}
    el_list* tmp = scope->val;
    for(; tmp -> next != NULL; tmp = tmp->next);
    tmp -> next = ret;
    return ret;
}

char* print_param(table* tab){
    char* ret = (char*)malloc(sizeof(MAX_STR));
    el_list* tmp = tab->val;
    for(; tmp != NULL; tmp=tmp->next){
        if (tmp->val->is_param)
            snprintf(ret, MAX_STR-1, "%s%s,", ret, tmp->val->type);
    }
    ret[strlen(ret)-1 > 0 ? strlen(ret)-1 : 0] = 0;
    char* real_ret = strndup(ret, strlen(ret));
    free(ret);
    return real_ret;
}

char* print_param_list(table_el* el){
    char* ret = (char*)malloc(sizeof(MAX_STR));
    if (ret == NULL) return NULL;
    sprintf(ret, "(");
    type_list* tmp = el->params;
    for(; tmp != NULL; tmp = tmp->next)
        snprintf(ret, MAX_STR-2, "%s%s,", ret, tmp->type);
    if (strlen(ret) > 1)ret[strlen(ret)-1] = 0;
    snprintf(ret, MAX_STR, "%s)", ret);
    char* real_ret = strndup(ret, strlen(ret));
    free(ret);
    return real_ret;
}

void print_body(table* tab){
    el_list* tmp = tab->val;
    for (;tmp != NULL; tmp = tmp->next)
    {
        table_el* v = tmp->val;
        char* aux = NULL;
        if (v -> is_func)
            aux = print_param_list(v);
        printf("%s\t%s\t%s%s\n", v->name, aux != NULL ? aux : "", v->type, v->is_param ? "\tparam":"");
    }
}

void print_table(){
    table* tmp = symtab;
    for(;tmp!=NULL;tmp = tmp->next){
        if (tmp->type == GLOB)
            printf("===== %s Symbol Table =====\n", tmp->scope);
        else if (tmp->type == FUN)
            printf("==== Function %s(%s) Symbol Table =====\n", tmp->scope, print_param(tmp));
        if (tmp->type == GLOB || tmp->type == FUN) print_body(tmp);
    }   
}
