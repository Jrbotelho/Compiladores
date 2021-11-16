#include "functions.h"
#include "structures.h"
#include <strings.h>

is_program* program(is_dec_list* u_decs, char* id){
    is_program* ret = (is_program*)malloc(sizeof(is_program));
    if (ret == NULL) return NULL;
    ret-> id = strdup(id);
    ret->u_decs = u_decs;
    return ret;
}

is_dec_list* insert_dec(is_dec_list* head, is_dec* val){
    is_dec_list* new = (is_dec_list*)malloc(sizeof(is_dec_list));
    if (new == NULL) return head;
    new->val = val;
    new->next = NULL;
    if (head == NULL)return new;
    is_dec_list* tmp = head;
    for(;tmp->next!=NULL;tmp=tmp->next);
    tmp->next = new;
    return head;
}


is_vardec* insert_vardec_el_without_type(char* id){
    is_vardec* ret = (is_vardec*)malloc(sizeof(is_vardec));
    if (ret == NULL) return ret;
    ret->id = strdup(id);
    return ret;
}

is_dec* insert_vardec_without_type(is_dec* head, char* id){
    if (head == NULL) head = (is_dec*)malloc(sizeof(is_dec));
    is_vardec_list* new = (is_vardec_list*)malloc(sizeof(is_vardec_list));
    if (new == NULL)return head;
    new->val = insert_vardec_el_without_type(id);
    new->next = NULL;
    if (head->disc_data.u_vardec == NULL){
        head->disc_data.u_vardec = new;
        return head;
    }
    is_vardec_list* tmp = head->disc_data.u_vardec;
    for(; tmp->next != NULL; tmp=tmp->next);
    tmp->next = new;

    return head;
}

is_dec* insert_vardec_type(is_dec* head, type disc){
    if (head == NULL)return head;
    is_vardec_list* tmp = head->disc_data.u_vardec;
    for(; tmp != NULL; tmp=tmp->next)
        if (tmp->val != NULL)
            tmp->val->disc = disc;
    return head;
}

is_vardec_list* insert_param(is_vardec_list* head, is_vardec* val){
    is_vardec_list* ret = (is_vardec_list*)malloc(sizeof(is_vardec_list));
    ret -> val = val;
    ret -> next = NULL;

    if (head == NULL) return ret;
    is_vardec_list* tmp = head;
    for(; tmp -> next != NULL; tmp = tmp->next);
    tmp->next = ret;

    return head;
}

is_vardec* insert_vardec(char* id, type disc){
    is_vardec* ret = (is_vardec*)malloc(sizeof(is_vardec));
    ret->disc = disc;
    ret->id = strdup(id);
    return ret;
}

is_funheader* insert_fun_header(is_vardec_list* params, char* id, type disc){
    is_funheader* ret = (is_funheader*)malloc(sizeof(is_funheader));
    if (ret == NULL) return ret;
    ret->id = strdup(id);
    ret->params = params;
    ret->ret = disc;
    return ret;
}

is_fundec* insert_fundec(is_funheader* header, is_funbody* body){
    is_fundec* ret = (is_fundec*)malloc(sizeof(is_fundec));
    if (ret == NULL)return ret;
    ret->body = body;
    ret->header = header;
    return ret;
}

is_funbody* insert_funbody(is_vos_list* head){
   is_funbody* ret = (is_funbody*)malloc(sizeof(is_funbody));
   ret->vos_list = head;
   return ret; 
}

is_vos_list* insert_vos_list(is_vos_list* head, is_var_or_stat* val){
    is_vos_list* ret = (is_vos_list*)malloc(sizeof(is_vos_list));
    ret->next = NULL;
    ret->val = val;
    if (head == NULL) return ret;
    is_vos_list* tmp = head;
    for(;tmp->next!=NULL;tmp = tmp->next);
    tmp->next = ret;
    return head;
}

is_var_or_stat* insert_var(is_dec* val){
    is_var_or_stat* ret = (is_var_or_stat*)malloc(sizeof(is_var_or_stat));
    if (val->disc == d_vardec) ret->disc_data.d_vardec = val->disc_data.u_vardec->val;
    ret->disc = d_var;
    return ret;
}

is_var_or_stat* insert_stat(is_stat* val){
    is_var_or_stat* ret = (is_var_or_stat*)malloc(sizeof(is_var_or_stat));
    ret->disc = d_stat;
    ret->disc_data.d_stat = val;
    return ret;
}

is_stat_list* insert_stat_list(is_stat_list* head, is_stat* val){
    is_stat_list* ret = (is_stat_list*)malloc(sizeof(is_stat_list));
    ret->val = val;
    ret->next = NULL;
    if (head == NULL) return ret;
    is_stat_list* tmp = head;
    for(;tmp->next!=NULL;tmp=tmp->next);
    tmp->next = ret;
    return head;
}

is_stat* insert_assign(char* id, is_expr* expr){
    is_stat* ret = (is_stat*)malloc(sizeof(is_stat));
    is_assign* to_add = (is_assign*)malloc(sizeof(is_assign));
    to_add -> id = strdup(id);
    to_add -> expr = expr;
    ret->disc = d_assign;
    ret->disc_data.d_assign = to_add;
    return ret;
}

is_stat* insert_if(is_expr* expr, is_stat_list* stat_list, is_stat_list* d_else){
    is_stat* ret = (is_stat*)malloc(sizeof(is_stat));
    is_if* to_add = (is_if*)malloc(sizeof(is_if));
    to_add->expr = expr;
    to_add->stat_list = stat_list;
    to_add->d_else = d_else;
    ret->disc = d_if;
    ret->disc_data.d_if = to_add;
    return ret;
}

is_stat* insert_for(is_expr* expr, is_stat_list* stat_list){
    is_stat* ret = (is_stat*)malloc(sizeof(is_stat));
    is_for* to_add = (is_for*)malloc(sizeof(is_for));
    to_add->expr = expr;
    to_add->stat_list = stat_list;
    ret->disc = d_for;
    ret->disc_data.d_for = to_add;
    return ret;
}

is_stat* insert_return(is_expr* d_ret){
    is_stat* ret = (is_stat*)malloc(sizeof(is_stat));
    ret->disc = d_return;
    ret->disc_data.d_ret = d_ret;
    return ret;
}

is_stat* insert_fun_invocation(is_fun_inv* val){
    is_stat* ret = (is_stat*)malloc(sizeof(is_stat));
    ret->disc = d_func;
    ret->disc_data.d_fun_inv = val;
    return ret;
}

is_stat* insert_parse(is_parse* val){
    is_stat* ret = (is_stat*)malloc(sizeof(is_stat));
    ret->disc = d_parse;
    ret->disc_data.d_parse = val;
    return ret;
}

is_stat* insert_print(is_print* val){
    is_stat* ret = (is_stat*)malloc(sizeof(is_stat));
    ret->disc = d_print;
    ret->disc_data.d_print = val;
    return ret;
}

is_print* print_expr(is_expr* val){
    is_print* ret = (is_print*)malloc(sizeof(is_print));
    ret->disc = d_expr;
    ret->disc_data.expr = val;
    return ret;
}

is_print* print_strlit(char* strlit){
    is_print* ret = (is_print*)malloc(sizeof(is_print));
    ret->disc = d_strlit;
    ret->disc_data.strlit = strdup(strlit);
    return ret;
}

is_fun_inv* insert_fun_inv(char* id, is_expr_list* expr_list){
    is_fun_inv* ret = (is_fun_inv*)malloc(sizeof(is_fun_inv));
    ret->id = strdup(id);
    ret->expr_list = expr_list;
    return ret;
}

is_expr_list* insert_expr_list(is_expr_list* head, is_expr* to_add){
    is_expr_list* ret = (is_expr_list*)malloc(sizeof(is_expr_list));
    ret->val = to_add;
    ret->next = NULL;
    if (head == NULL) return ret;
    is_expr_list* tmp = head;
    for(; tmp->next!=NULL; tmp = tmp->next);
    tmp->next = ret;
    return head;
}

is_parse* insert_parse_arg(char* id, is_expr* expr){
    is_parse* ret = (is_parse*)malloc(sizeof(is_parse));
    ret->id = strdup(id);
    ret->expr = expr;
    return ret;
}

is_expr* insert_math(op_type disc, is_expr* left_expr, is_expr* right_expr){
    is_expr* ret = (is_expr*)malloc(sizeof(is_expr));
    is_math_expr* to_add = (is_math_expr*)malloc(sizeof(is_math_expr));
    to_add->disc = disc;
    to_add->left_expr = left_expr;
    to_add->right_expr = right_expr;
    ret->disc = d_math;
    ret->disc_data.u_math = to_add;
    return ret;
}

is_expr* insert_non_assoc(non_assoc_type disc, is_expr* right_expr){
    is_expr* ret = (is_expr*)malloc(sizeof(is_expr));
    is_non_assoc* to_add = (is_non_assoc*)malloc(sizeof(is_non_assoc));
    to_add->disc = disc;
    to_add->right_expr = right_expr;
    ret->disc = d_non_assoc;
    ret->disc_data.u_non_assoc = to_add;
    return ret;
}

is_expr* insert_int(int* val){
    is_expr* ret = (is_expr*)malloc(sizeof(is_expr));
    ret->disc = d_int;
    ret->disc_data.u_int_lit = val;
    return ret;
}

is_expr* insert_float(float* val){
    is_expr* ret = (is_expr*)malloc(sizeof(is_expr));
    ret->disc = d_float;
    ret->disc_data.u_real_lit = val;
    return ret;
}

is_expr* insert_id(char* id){
    is_expr* ret = (is_expr*)malloc(sizeof(is_expr));
    ret->disc = d_char;
    ret->disc_data.u_id = strdup(id);
    return ret;
}

is_expr* insert_fun_inv_expr(is_fun_inv* val){
    is_expr* ret = (is_expr*)malloc(sizeof(is_expr));
    ret->disc = d_fun_inv;
    ret->disc_data.u_fun_inv = val;
    return ret;
}

is_stat* insert_stat_stat_list(is_stat_list* val){
    is_stat* ret = (is_stat*)malloc(sizeof(is_stat));
    ret->disc = d_stat_list;
    ret->disc_data.d_stat = val;
    return ret;
}