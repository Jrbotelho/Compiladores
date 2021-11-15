#include "functions.h"

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
    for(tmp; tmp->next != NULL; tmp=tmp->next);
    tmp->next = new;

    return head;
}

is_vardec* insert_vardec_el_without_type(char* id){
    is_vardec* ret = (is_vardec*)malloc(sizeof(is_vardec));
    if (ret == NULL) return ret;
    ret->id = strdup(id);
    return ret;
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

is_var_or_stat* insert_var(is_vardec* val){
    is_var_or_stat* ret = (is_var_or_stat*)malloc(sizeof(is_var_or_stat));
    return ret;
}

is_var_or_stat* insert_stat(){

}