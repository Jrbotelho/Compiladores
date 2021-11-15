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
#endif