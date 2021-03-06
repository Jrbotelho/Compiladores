/* João Ricardo Miranda Botelho 2019155348  */
/* José Pedro Silvério Braz     2017247538  */

#include "functions.h"
#include "symtable.h"
#include <string.h>
#include <stdlib.h>

node* noted_table = NULL;

node* add_next(node* head, node* ret){
    if (head == NULL) return ret;
    node* tmp = head;
    for(;tmp->next!=NULL;tmp=tmp->next);
    tmp->next = ret;
    return head;
}

node* add_down(node* head, node*ret){
    if (head == NULL) return ret;
    if (head->down != NULL) head->down = add_next(head->down, ret);
    else head->down = ret;
    return head;
}

node* create(char* val){
    node* ret = (node*)malloc(sizeof(node));
    if (ret == NULL) return NULL;
    ret->val = strdup(val);
    ret->down = NULL;
    ret->next = NULL;
    return ret;
}

int count_depth(node* root){
    int n = 0;
    for(; root != NULL; root = root->next) n++;
    return n;
}

char* trim_id(char* str){
    char* ret = strdup(str);
    ret = &ret[3];
    ret[strlen(ret)-1] = 0;
    return ret;
}

void print_tree(node* root, node* parent, int depth, FILE* out){
    if (root == NULL)return;
    for (int i = 0; i < depth; i++) fprintf(out, "..");
    if (root->val != NULL) fprintf(out, "%s\n", root->val);
    print_tree(root->down, root, depth+1, out);
    print_tree(root->next, parent, depth, out);
}

bool check_prefix(char* a, char* b){
    if (strlen(b) > strlen(a)) return false;
    for (int i = 0; i < strlen(b); i++)
        if (a[i] != b[i]) return false;
    return true;
}

char* type_priority(char* a, char* b){
    if (a == NULL) return "undef";
    if (b == NULL) return a;
    if (strcmp(b, "string") == 0) return b;
    if (strcmp(a, b) == 0) return a;
    if (strcmp(a, "float32") == 0) return a;
    if (strcmp(b, "float32") == 0) return b;
    if (strcmp(a, "int") == 0) return a;
    if (strcmp(b, "int") == 0) return b;
    return a;
}

char* check_type(node* n);

char* highest_priority(node* n){
    if (n == NULL) return "undef";
    char* first = check_type(n);
    for(;n->next != NULL;n=n->next)
        first = type_priority(first, check_type(n->next));
    return first;
}



char* func_params(table_el* n, node* k){
    char* ret = (char*)malloc(sizeof(100));
    char* aux;
    sprintf(ret, "(");
    char* errors[100];
    int i = 0;
    for (type_list* tmp = n->params; tmp != NULL; tmp = tmp->next){
        aux = strdup(ret);
        sprintf(ret, "%s%s,", aux, to_lower(tmp->type));
        if (strcmp(to_lower(tmp->type), check_type(k))!= 0)errors[i++] = strdup(check_type(k));
        if (k != NULL)k = k->next;
        free(aux);
    }
    if (strlen(ret) != 1) ret[strlen(ret)-1] = 0;
    aux = strdup(ret);
    sprintf(ret, "%s)", aux);
    for(int j = 0; j < i; j++){
        printf("Operator <%s> cannot be applied to types", errors[j]);
        int v = 0;
        for(type_list* tmp = n->params; tmp != NULL; tmp = tmp->next){
            if (v == 0)printf(" <%s>", to_lower(tmp->type));
            else printf(", <%s>", to_lower(tmp->type));
        }
        printf("\n");
    }
    free(aux);
    return ret;
}

char* check_type(node* n){
    if (n == NULL) return "undef";
    char* str = n->val;
    if (check_prefix(str, "IntLit")) return "int";
    if (check_prefix(str, "RealLit")) return "float32";
    if (check_prefix(str, "StrLit")) return "string"; 
    if (strcmp(str, "ParseArgs") == 0) return "int";
    char* bool_arr[] = {"Or", "And", "Eq", "Ne", "Lt", "Gt", "Le", "Ge", "Not"};
    for (int i = 0; i < 9; i++)
        if (strcmp(str, bool_arr[i]) == 0) return "bool";
    if (strcmp(str, "Mod") == 0) return "int";
    char* expr_arr[] = {"Add", "Div", "Mul", "Sub"};
    for (int i = 0; i < 4; i++)
        if (strcmp(str, expr_arr[i]) == 0) return highest_priority(n->down);
    if (strcmp(str, "Assign") == 0){
        if (strcmp(type_priority(check_type(n->down), check_type(n->down->next)), check_type(n->down)) != 0){
            printf("Operator <%s> cannot be applied to type <%s>\n", check_type(n->down->next), check_type(n->down));
            return "undef";
        }
        return check_type(n->down);
    } 
    if (check_prefix(str, "Id")){
        table_el* tmp = var_in_table(trim_id(str));
        if (tmp->is_func) return func_params(tmp, n->next);
        if (tmp != NULL) return to_lower(strdup(tmp->type));
        printf("Cannot find symbol <%s>\n", str);
        return "undef";
    }
    if (strcmp("Call", str) == 0){
        table_el* tmp = var_in_table(trim_id(n->down->val));
        return to_lower(tmp->type);
    }
    return "undef";
}

bool mark_check(node* root,  node* parent){
    if (strcmp(parent->val, "VarDecl") == 0 || strcmp(parent->val, "ParamDecl") == 0 || strcmp(parent->val, "FuncHeader") == 0) return false;
    char* check_list[] = {"Call", "IntLit", "RealLit", "StrLit", "Or", "And", "Eq", "Ne", "Lt", "Gt", "Le", "Ge", "Not", "Add", "Div", "Mul", "Sub", "Id", "Assign", "ParseArgs", NULL};
    for (int i = 0; check_list[i] != NULL; i++)
        if (check_prefix(root->val, check_list[i])) return true;
    return false;
}

bool check_statement(node* n){
    if (strcmp(n->val, "For") == 0) return true;
    if (strcmp(n->val, "If") == 0) return true;
    return false;
}

void stat_error(node* n){
    if (!check_statement(n)) return;
    if (strcmp(check_type(n->down), "bool") == 0) return;
    printf("Incompatible type <%s> in <%s> statement\n", check_type(n->down), to_lower(n->val));
}

void build_noted_tree(node* head, node* root, node* parent){
    if (root == NULL)return;
    if (head == NULL){
        noted_table = (node*)malloc(sizeof(node));
        head = noted_table;
    }
    head->val = (char*)malloc(100);
    if (root->val == NULL);
    else if (parent == NULL || !mark_check(root, parent)) sprintf(head->val, "%s", root->val);
    else snprintf(head->val, 100, "%s - %s", root->val, check_type(root));
    if (root->down != NULL) head->down = (node*)malloc(sizeof(node));
    if (root->next != NULL) head->next = (node*)malloc(sizeof(node));
    stat_error(root);
    build_noted_tree(head->down, root->down, root);
    build_noted_tree(head->next, root->next, parent);
}

void print_noted_tree(){
    print_tree(noted_table, NULL, 0, supposed_file());
}

bool add_vardecl(node* root, node* parent_node, table* parent_tab){
    table_el* v = create_el(trim_id(root->down->next->val), root->down->val, 0, NULL, 0);
    if (add_to_scope(parent_tab, v) == NULL) return 0;
    build_symtab(root->next, parent_node, parent_tab);
    return 1;
}

void add_fundecl(node* root, node* parent_node, table* parent_tab){
    node* funheader = root->down;
    if (funheader == NULL) return;
    node* funparams = funheader->down;
    for(; funparams != NULL && strcmp("FuncParams", funparams->val) != 0; funparams = funparams->next);
    if (funparams == NULL) return; 
    table* scope = add_scope(trim_id(root->down->down->val), FUN);
    if (scope == NULL) return;
    char* type = strcmp(funheader->down->next->val, "FuncParams") == 0 ? "none" : funheader->down->next->val; 
    table_el* ret = create_el("return", type, 0, NULL, 0);
    if (add_to_scope(scope, ret) == NULL) return;
    node* tmp = funparams->down;
    type_list* param_list = NULL;
    for(; tmp != NULL; tmp = tmp->next){
        param_list = add_type(param_list, tmp->down->val);
        ret = create_el(trim_id(tmp->down->next->val), tmp->down->val, 1, NULL, 0);
        add_to_scope(scope, ret);
    }
    table_el* el = create_el(trim_id(root->down->down->val), type, 0, param_list, 1);
    if(add_to_scope(parent_tab, el) == NULL) return;
    build_symtab(root->down->next->down, root, scope);
    build_symtab(root->next, parent_node, parent_tab);
}

void build_symtab(node* root, node* parent_node, table* parent_tab){
    if (root == NULL) return;
    if (parent_tab == NULL){
        table* aux = add_scope("Global", GLOB);
        build_symtab(root->down, root, aux);
    }
    else if (strcmp(root->val, "VarDecl") == 0) add_vardecl(root, parent_node, parent_tab);
    else if (strcmp(root->val, "FuncDecl") == 0) add_fundecl(root, parent_node, parent_tab);
    else build_symtab(root->next, parent_node, parent_tab);
}