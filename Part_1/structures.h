#ifndef STRUCTURES_H
#define STRUCTURES_H

typedef enum {d_int, d_float, d_bool, d_string} disc_vardec;

typedef enum {d_vardec, d_fundec} disc_dec;

typedef enum {d_var, d_statement} disc_vas;


typedef struct{
    char* id;
    vardec* p_list;
    vardec* var_list;
    disc_vardec disc_return;
    union{
        is_int* u_integer;
        is_float* u_float;
        is_bool* u_bool;
        is_string* u_string;
    }data_return;
}fundec;

typedef struct{
    char* id;
    int* value;
}is_int;

typedef struct{
    char* id;
    float* value;
}is_float; 

typedef struct{
    char* id;
    char* value;
}is_bool;

typedef struct{
    char* id;
    char* value;
}is_string;

typedef struct l_6{
    is_bool* val;
    struct l6* next;
}is_bool_list;

typedef struct l_5{
    is_float* val;
    struct l5* next;
}is_float_list;

typedef struct l_4{
    is_int* val;
    struct l4* next;
}is_int_list;

typedef struct l_3{
    is_string* val;
    struct l3* next;
}is_string_list;

typedef struct{
    disc_vardec disk;
    union{
        is_int_list* u_integer;
        is_float_list* u_float;
        is_bool_list* u_bool;
        is_string_list* u_string;
    }data_vardec;
}vardec;

typedef struct id_list{
    char* val;
    struct id_list* next;
}id_list;

typedef struct{
    disc_dec disk;
    union{
        vardec* u_vardec;
        fundec* u_fundec;
    } data_dec;
}declaration;

typedef struct l_1{
    declaration* val;
    struct l_1* next;
}declaration_list;

typedef struct {
    char* id;
    declaration_list* d_list;
}program;

#endif