#ifndef STRUCTURES_H
#define STRUCTURES_H

#include <stdlib.h>

typedef enum{d_vardec, d_fundec}dec_type;

typedef enum{d_int, d_float, d_bool, d_str, d_no_type}type;

typedef enum{d_var, d_stat}vod_type;

typedef enum{d_plus, d_minus, d_star, d_div, d_mod, d_lt, d_gt, d_eq, d_ne, d_le, d_ge}op_type;

typedef enum{d_assign, d_if, d_for, d_return, d_func, d_parse, d_print}stat_type;

typedef enum{d_not, d_minus, d_plus}non_assoc_type;

typedef enum{d_math, d_non_assoc, d_fun_inv, d_int, d_float, d_char}expr_type;


typedef struct declaration{
    dec_type disc;
    union{
        is_vardec_list* u_vardec;
        is_fundec* u_fundec;
    }disc_data;
}is_dec;

typedef struct declarations{
    is_dec* val;
    struct declarations* next;
}is_dec_list;

typedef struct vardec{
    type disc;
    char* id;
    union{
        int* u_int;
        float* u_float;
        bool* u_bool;
        char* u_str;
    }disc_data;
}is_vardec;

typedef struct fundec{
    is_funheader* header;
    is_funbody* body;
}is_fundec;

typedef struct funheader{
    char* id;
    type ret;
    is_vardec_list* params;
}is_funheader;

typedef struct vardec_list{
    is_vardec* val;
    struct vardec_list* next;
}is_vardec_list;

typedef struct funbody{
    is_vos_list* vos_list;
}is_funbody;

typedef struct var_or_stat{
    vod_type disc;
    union{
        is_vardec* d_vardec;
        is_stat* d_stat;
    }disc_data;
}is_var_or_stat;

typedef struct statement{
    stat_type disc;
    union{
        is_assign* d_assign;
        is_if* d_if;
        is_for* d_for;
        is_expr * d_ret;
        is_fun_inv* d_fun_inv;
        is_parse* d_parse;
        is_print* d_print;
    }disc_data;
}is_stat;

typedef struct statement_list{
    is_stat* val;
    struct statement_list* next;
}is_stat_list;

typedef struct assign{
    char* id;
    is_expr* expr;
}is_assign;

typedef struct is_if{
    is_expr* expr;
    is_stat_list* stat_list;
    is_stat_list* d_else;
}is_if;

typedef struct is_for{
    is_expr* expr;
    is_stat_list* stat_list;
}is_for;

typedef struct fun_invocation{
    char* id;
    is_expr_list* expr_list;
}is_fun_inv;

typedef struct parse{
    char* id;
    is_expr* expr;
}is_parse;

typedef struct is_print{
    is_expr* expr;
    char* strlit;

}is_print;

typedef struct expression_list{
    is_expr* val;
    struct expression_list* next;
}is_expr_list;

typedef struct expression{
    expr_type disc;
    union{
        is_math_expr* u_math;
        is_non_assoc* u_non_assoc;
        is_fun_inv* u_fun_inv;
        int* u_int_lit;
        float* u_real_lit;
        char* u_id;
    }disc_data;
}is_expr;

typedef struct {
    char* id;
    is_expr* expr;
}is_funciv;

typedef struct math_expr{
    op_type disc;
    is_expr* left_expr;
    is_expr* right_expr;
}is_math_expr;

typedef struct nonassoc{
    non_assoc_type disc;
    is_expr* right_expr;
}is_non_assoc;

typedef struct var_or_stat_list{
    is_var_or_stat* val;
    struct var_or_stat_list* next;
}is_vos_list;

typedef struct program{
    char* id;
    is_dec_list* u_decs;
}is_program;

#endif