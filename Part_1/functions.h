#ifndef FUNCTIONS_H
#define FUNCTIONS_H

#include "structures.h"

program* insert_program(char* id, declaration* d_list);

declaration_list* insert_declaration_list(declaration_list* head, declaration* val);

declaration* insert_declaration(vardec* u_vardec);

id_list* insert_id_list(id_list* head, char* val);

vardec* insert_vardec(id_list* val, disc_vardec disk);

is_string_list* insert_string_id_list(is_string_list* head, id_list* id_head);

is_string_list* insert_string_list(is_string_list* head, char* val);

is_bool_list* insert_bool_id_list(is_bool_list* head, id_list* id_head);

is_bool_list* insert_bool_list(is_bool_list* head, char* val);

is_float_list* insert_float_id_list(is_float_list* head, id_list* id_head);

is_float_list* insert_float_list(is_float_list* head, char* val);

is_int_list* insert_int_id_list(is_int_list* head, id_list* id_head);

is_int_list* insert_int_list(is_int_list* head, char* val);

#endif