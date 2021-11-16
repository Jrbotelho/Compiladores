#ifndef FUNCTIONS_H
#define FUNCTIONS_H

#include "structures.h"

is_program* program(is_dec_list* u_decs, char* id);

is_dec_list* insert_dec(is_dec_list* head, is_dec* val);

is_dec* insert_vardec_without_type(is_dec* head, char* id);

is_dec* insert_vardec_type(is_dec* head, type disc);

is_vardec* insert_vardec(char* id, type disc);

is_vardec_list* insert_param(is_vardec_list* head, is_vardec* val);

is_funheader* insert_fun_header(is_vardec_list* params, char* id, type disc);

is_fundec* insert_fundec(is_funheader* header, is_funbody* body);

is_funbody* insert_funbody(is_vos_list* head);

is_vos_list* insert_vos_list(is_vos_list* head, is_var_or_stat* val);

is_var_or_stat* insert_var(is_dec* val);

is_var_or_stat* insert_stat(is_stat* val);

is_stat* insert_if(is_expr* expr, is_stat_list* stat_list, is_stat_list* d_else);

is_stat* insert_for(is_expr* expr, is_stat_list* stat_list);

is_stat* insert_return(is_expr* d_ret);

is_stat* insert_fun_invocation(is_fun_inv* val);

is_stat* insert_parse(is_parse* val);

is_stat* insert_print(is_print* val);

is_print* print_expr(is_expr* val);

is_print* print_strlit(char* strlit);

is_fun_inv* insert_fun_inv(char* id, is_expr_list* expr_list);

is_expr_list* insert_expr_list(is_expr_list* head, is_expr* to_add);

is_parse* insert_parse_arg(char* id, is_expr* expr);

is_expr* insert_math(op_type disc, is_expr* left_expr, is_expr* right_expr);

is_expr* insert_non_assoc(non_assoc_type disc, is_expr* right_expr);

is_expr* insert_int(int* val);

is_expr* insert_float(float* val);

is_expr* insert_id(char* id);

is_expr* insert_fun_inv_expr(is_fun_inv* val);

is_stat_list* insert_stat_list(is_stat_list* head, is_stat* val);

is_stat* insert_stat_stat_list(is_stat_list* val);

#endif