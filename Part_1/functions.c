#include "functions.h"
#include <stdlib.h>
#include <string.h>

program* insert_program(char* id, declaration* d_list){
    program* prog = (program*)malloc(sizeof(program));
    if (prog == NULL)return NULL;
    prog->d_list = d_list;    
    prog->id = (char*)strdup(id);
    return prog;
}

declaration_list* insert_declaration_list(declaration_list* head, declaration* val){
    declaration_list* dl = (declaration_list*)malloc(sizeof(declaration_list));
    if (dl == NULL) return head;
    dl->val = val;
    dl->next = NULL;

    if (head == NULL) return dl;

    declaration_list* aux = head;
    for(;aux->next!=NULL;aux=aux->next);
    aux->next = dl;

    return head;
}

declaration* insert_declaration(vardec* u_vardec){
    declaration* dec = (declaration*)malloc(sizeof(declaration));
    dec->disk = d_vardec;
    dec->data_dec.u_vardec = u_vardec;
    return dec;
}

id_list* insert_id_list(id_list* head, char* val){
    id_list* np = (id_list*)malloc(sizeof(id_list));
    if (np == NULL) return head;
    np->val = (char*)strdup(val);
    np->next = NULL;
    if (head == NULL) return np;
 
    id_list* tmp = head;
    for(; tmp->next!=NULL;tmp=tmp->next);
    tmp->next = np;

    return head;
}


vardec* insert_vardec(id_list* val, disc_vardec disk){
    vardec* ret = (vardec*)malloc(sizeof(vardec));
    ret->disk = disk;
    
    switch(disk){
        case d_int:
            ret->data_vardec.u_integer = insert_int_id_list(NULL, val);
            break;
        case d_float:
            ret->data_vardec.u_float = insert_float_id_List(NULL, val);
            break;
        case d_bool:
            ret->data_vardec.u_bool = insert_bool_id_list(NULL, val);
            break;
        case d_string:
            ret->data_vardec.u_string = insert_string_id_list(NULL, val);
            break;
        default:
            break;
    }
}

is_string_list* insert_string_id_list(is_string_list* head, id_list* id_head){
    for(;id_head!=NULL;id_head = id_head->next)
        head = insert_string_list(head, id_head->val);
    return head;
}

is_string_list* insert_string_list(is_string_list* head, char* val){
    is_string_list* ret = (is_string_list*)malloc(sizeof(is_string_list));
    if (ret == NULL) return head;
    
    ret->val->id = (char*)strdup(val);
    ret->val->value = NULL;
    ret->next = NULL;

    if (head == NULL) return ret;

    is_string_list* tmp = head;
    for(;tmp->next!=NULL;tmp=tmp->next);
    tmp->next = ret;
    return head;
}

is_bool_list* insert_bool_id_list(is_bool_list* head, id_list* id_head){
    for(;id_head!=NULL;id_head = id_head->next)
        head = insert_bool_list(head, id_head->val);
    return head;
}

is_bool_list* insert_bool_list(is_bool_list* head, char* val){
    is_bool_list* ret = (is_bool_list*)malloc(sizeof(is_bool_list));
    if (ret == NULL) return head;
    
    ret->val->id = (char*)strdup(val);
    ret->val->value = NULL;
    ret->next = NULL;

    if (head == NULL) return ret;

    is_bool_list* tmp = head;
    for(;tmp->next!=NULL;tmp=tmp->next);
    tmp->next = ret;
    return head;
}

is_float_list* insert_float_id_list(is_float_list* head, id_list* id_head){
    for(;id_head!=NULL;id_head = id_head->next)
        head = insert_float_list(head, id_head->val);
    return head;
}

is_float_list* insert_float_list(is_float_list* head, char* val){
    is_float_list* ret = (is_float_list*)malloc(sizeof(is_float_list));
    if (ret == NULL) return head;
    
    ret->val->id = (char*)strdup(val);
    ret->val->value = NULL;
    ret->next = NULL;

    if (head == NULL) return ret;

    is_float_list* tmp = head;
    for(;tmp->next!=NULL;tmp=tmp->next);
    tmp->next = ret;
    return head;
}

is_int_list* insert_int_id_list(is_int_list* head, id_list* id_head){
    for(;id_head!=NULL;id_head = id_head->next)
        head = insert_int_list(head, id_head->val);
    return head;
}

is_int_list* insert_int_list(is_int_list* head, char* val){
    is_int_list* ret = (is_int_list*)malloc(sizeof(is_int_list));
    if (ret == NULL) return head;
    
    ret->val->id = (char*)strdup(val);
    ret->val->value = NULL;
    ret->next = NULL;

    if (head == NULL) return ret;

    is_int_list* tmp = head;
    for(;tmp->next!=NULL;tmp=tmp->next);
    tmp->next = ret;
    return head;
}

