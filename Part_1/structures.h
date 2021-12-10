/* João Ricardo Miranda Botelho 2019155348  */
/* José Pedro Silvério Braz     2017247538  */

#ifndef STRUCTURES_H
#define STRUCTURES_H

#include <stdio.h>
#include <stdbool.h>

extern bool mayprint, error_occ;

extern FILE* supposed_file();

extern int line, column, old_column;

typedef struct node{
    char* val;
    struct node* next;
    struct node* down;
}node;

#endif