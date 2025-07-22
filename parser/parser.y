%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TOKEN_NAME_LENGTH 256
#define TOKEN_VALUE_LENGTH 128

/* Prototipo da funcao do analisador lexico */
int yylex();
/* Prototipo da funcao de erro */
void yyerror(const char* s);

/* Estrutura do no da Arvore Sintatica Abstrata (AST) */
typedef struct Node {
  char name[TOKEN_NAME_LENGTH];
  char value[TOKEN_VALUE_LENGTH];
  struct Node* left;
  struct Node* right;
} Node;

/* Prototipos das funcoes da AST */
Node* createNode(char* name, char* value, Node* left, Node* right);
void printTreeInFile(Node* root, FILE* out, int level);
void printTreeInStd(int level, Node* root)
void freeTree(Node* root);

/* Raiz da arvore sintatica */
Node* root = NULL;
/* Arquivo de saída */
FILE* output_file;

%}


/* A uniao (union) define os tipos de dados que podem ser associados
  aos simbolos terminais (tokens) e nao-terminais da gramatica.
  'str' sera usado para tokens que carregam um valor de string (como T_ID e literais).
  'node' sera usado para simbolos nao-terminais que representam nos na AST.
*/
%union {
  char* str;
  Node* node;
}


/* Declaracao dos TOKENS (simbolos terminais)
  Esses nomes devem corresponder aos que sao retornados pelo analisador lexico (Flex).
  '<str>' indica que o token tem um valor associado do tipo 'char*' da union.
*/

/* Palavras-chave */
%token <str> T_VAR T_CONST
%token <str> T_INTEIRO T_FLUTUANTE T_LONGO T_OXE T_OXENTE T_NADA
%token <str> T_BARRIL T_SEPIQUE T_BROCOU
%token <str> T_SEPLANTE T_VANESSA
%token <str> T_PALETADA T_ENQUANTO T_FAZ
%token <str> T_PEGAVISAO

/* Literais e Identificador */
%token <str> T_ID
%token <str> T_NUM_LITERAL T_FLOAT_LITERAL T_CHAR_LITERAL T_STRING_LITERAL

/* Operadores */
%token <str> T_ASSIGN T_PLUS T_MINUS T_MULTIPLY T_DIVIDE T_MODULO T_POWER
%token <str> T_PLUS_ASSIGN T_MINUS_ASSIGN T_MULTIPLY_ASSIGN T_DIVIDE_ASSIGN T_MODULO_ASSIGN
%token <str> T_INCREMENT T_DECREMENT
%token <str> T_EQUAL_EQUAL T_NOT_EQUAL T_LESS T_GREATER T_LESS_EQUAL T_GREATER_EQUAL
%token <str> T_BITWISE_AND T_BITWISE_OR T_BITWISE_XOR T_BITWISE_NOT

/* Delimitadores */
%token <str> T_LPAREN T_RPAREN T_LBRACE T_RBRACE T_LBRACKET T_RBRACKET
%token <str> T_SEMICOLON T_COMMA T_COLON

/* Declaracao dos tipos para os simbolos NAO-TERMINAIS
  '<node>' indica que o simbolo nao-terminal tera um valor associado do tipo 'Node*' da union.
*/
%type <node> program statement_list statement block
%type <node> declaration var_specifier type var_declaration_list var_declaration var_initializer
%type <node> assignment assignment_operator
%type <node> if_statement else_part
%type <node> while_loop do_while_loop for_loop for_init for_condition for_increment
%type <node> function_definition function_call param_list params return_type arg_list args
%type <node> print_statement return_statement
%type <node> expression primary_expression literal

/* Precedencia e Associatividade dos Operadores
  Define como expressoes complexas sao avaliadas.
  Comeca do nivel mais baixo de precedencia para o mais alto.
*/
%right T_ASSIGN T_PLUS_ASSIGN T_MINUS_ASSIGN T_MULTIPLY_ASSIGN T_DIVIDE_ASSIGN T_MODULO_ASSIGN
%left T_BITWISE_OR
%left T_BITWISE_XOR
%left T_BITWISE_AND
%left T_EQUAL_EQUAL T_NOT_EQUAL
%left T_LESS T_GREATER T_LESS_EQUAL T_GREATER_EQUAL
%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE T_MODULO
%right T_POWER
%right T_BITWISE_NOT T_DECREMENT T_INCREMENT /* Operadores unarios */
%left T_LPAREN T_RPAREN T_LBRACKET T_RBRACKET /* Chamada de funcao e acesso a array */

/* Simbolo inicial da gramatica */
%start program

%%
  /* REGRAS DA GRAMATICA (PRODUCOES) */
  program:
    statement_list { 
        printf("Árvore Sintática:\n");
        printTree($1, 0);
        /* Abre o arquivo output_sin.txt para gravar a árvore sintática */
        FILE *sin_file = fopen("output_sin.txt", "w");
        if (sin_file == NULL) {
            fprintf(stderr, "Erro ao abrir output_sin.txt\n");
            exit(1);
        }
        printTreeToFile($1, 0, sin_file);
        fclose(sin_file);
        freeTree($1);
    }
    ;

statement_list:
    statement { $$ = createNode("statement_list", NULL, $1, NULL); }
    | statement_list statement { $$ = createNode("statement_list", NULL, $1, $2); }
    ;

statement:
    declaration { $$ = $1; }
    | assignment T_SEMICOLON { $$ = $1; }
    | if_statement { $$ = $1; }
    | while_loop { $$ = $1; }
    | do_while_loop T_SEMICOLON { $$ = $1; }
    | for_loop { $$ = $1; }
    | function_definition { $$ = $1; }
    | function_call T_SEMICOLON { $$ = createNode("function_call_statement", NULL, $1, NULL); }
    | print_statement T_SEMICOLON { $$ = $1; }
    | return_statement T_SEMICOLON { $$ = $1; }
    | T_SEMICOLON { $$ = createNode("empty_statement", NULL, NULL, NULL); }
    ;

block:
    T_LBRACE statement_list T_RBRACE { $$ = createNode("block", NULL, $2, NULL); }
    | T_LBRACE T_RBRACE { $$ = createNode("block", NULL, NULL, NULL); }
    ;

/* --- Declaracao de Variaveis --- */
declaration:
    var_specifier type var_declaration_list T_SEMICOLON { $$ = createNode("declaration", NULL, $1, createNode("type", NULL, $2, $3)); }
    ;

var_specifier:
    T_VAR { $$ = createNode("var_specifier", $1, NULL, NULL); }
    | T_CONST { $$ = createNode("var_specifier", $1, NULL, NULL); }
    ;

type:
    T_INTEIRO { $$ = createNode("type", $1, NULL, NULL); }
    | T_FLUTUANTE { $$ = createNode("type", $1, NULL, NULL); }
    | T_LONGO { $$ = createNode("type", $1, NULL, NULL); }
    | T_OXE { $$ = createNode("type", $1, NULL, NULL); }
    | T_OXENTE { $$ = createNode("type", $1, NULL, NULL); }
    ;

var_declaration_list:
    var_declaration { $$ = createNode("var_declaration_list", NULL, $1, NULL); }
    | var_declaration_list T_COMMA var_declaration { $$ = createNode("var_declaration_list", NULL, $1, $3); }
    ;

var_declaration:
    T_ID { $$ = createNode("var_declaration", $1, NULL, NULL); }
    | T_ID var_initializer { $$ = createNode("var_declaration", $1, $2, NULL); }
    | T_ID T_LBRACKET T_RBRACKET { $$ = createNode("array_declaration", $1, NULL, NULL); }
    | T_ID T_LBRACKET expression T_RBRACKET { $$ = createNode("array_declaration_sized", $1, $3, NULL); }
    | T_ID T_LBRACKET T_RBRACKET T_ASSIGN T_LBRACE arg_list T_RBRACE { $$ = createNode("array_initialized", $1, $6, NULL); }
    ;

var_initializer:
    T_ASSIGN expression { $$ = createNode("initializer", NULL, $2, NULL); }
    ;

/* --- Atribuicao --- */
assignment:
    T_ID assignment_operator expression { $$ = createNode("assignment", $1, $2, $3); }
    | T_ID T_LBRACKET expression T_RBRACKET assignment_operator expression { $$ = createNode("array_assignment", $1, $3, createNode("assignment_op", NULL, $5, $6)); }
    | T_ID T_INCREMENT { $$ = createNode("post_increment", $1, NULL, NULL); }
    | T_ID T_DECREMENT { $$ = createNode("post_decrement", $1, NULL, NULL); }
    | T_INCREMENT T_ID { $$ = createNode("pre_increment", $2, NULL, NULL); }
    | T_DECREMENT T_ID { $$ = createNode("pre_decrement", $2, NULL, NULL); }
    ;

assignment_operator:
    T_ASSIGN { $$ = createNode("assign_op", $1, NULL, NULL); }
    | T_PLUS_ASSIGN { $$ = createNode("assign_op", $1, NULL, NULL); }
    | T_MINUS_ASSIGN { $$ = createNode("assign_op", $1, NULL, NULL); }
    | T_MULTIPLY_ASSIGN { $$ = createNode("assign_op", $1, NULL, NULL); }
    | T_DIVIDE_ASSIGN { $$ = createNode("assign_op", $1, NULL, NULL); }
    | T_MODULO_ASSIGN { $$ = createNode("assign_op", $1, NULL, NULL); }
    ;

/* --- Estruturas de Controle --- */
if_statement:
    T_SEPLANTE T_LPAREN expression T_RPAREN block else_part { $$ = createNode("if", NULL, $3, createNode("body", NULL, $5, $6)); }
    ;

else_part:
    /* Vazio */ { $$ = NULL; }
    | T_VANESSA block { $$ = createNode("else", NULL, $2, NULL); }
    | T_VANESSA if_statement { $$ = createNode("else", NULL, $2, NULL); } /* else if */
    ;

while_loop:
    T_ENQUANTO T_LPAREN expression T_RPAREN block { $$ = createNode("while", NULL, $3, $5); }
    ;

do_while_loop:
    T_FAZ block T_ENQUANTO T_LPAREN expression T_RPAREN { $$ = createNode("do_while", NULL, $5, $2); }
    ;

for_loop:
    T_PALETADA T_LPAREN for_init T_SEMICOLON for_condition T_SEMICOLON for_increment T_RPAREN block { $$ = createNode("for", NULL, $3, createNode("for_parts", NULL, $5, createNode("for_parts", NULL, $7, $9))); }
    ;

for_init:
    declaration { $$ = $1; }
    | assignment { $$ = $1; }
    | /* Vazio */ { $$ = createNode("empty_for_init", NULL, NULL, NULL); }
    ;

for_condition:
    expression { $$ = $1; }
    | /* Vazio */ { $$ = createNode("empty_for_cond", NULL, NULL, NULL); }
    ;

for_increment:
    assignment { $$ = $1; }
    | /* Vazio */ { $$ = createNode("empty_for_inc", NULL, NULL, NULL); }
    ;

/* --- Funcoes --- */
function_definition:
    T_BARRIL T_ID T_LPAREN param_list T_RPAREN T_COLON return_type block { $$ = createNode("function_definition", $2, $4, createNode("return_type", NULL, $7, $8)); }
    | T_BARRIL T_BROCOU T_LPAREN T_RPAREN T_COLON return_type block { $$ = createNode("main_function", $2, $6, $7); } /* Funcao principal 'brocou' */
    ;

return_type:
    type { $$ = $1; }
    | T_NADA { $$ = createNode("type", $1, NULL, NULL); }
    ;

param_list:
    /* Vazio */ { $$ = NULL; }
    | params { $$ = $1; }
    ;

params:
    T_ID T_COLON type { $$ = createNode("param", $1, $3, NULL); }
    | params T_COMMA T_ID T_COLON type { $$ = createNode("param_list", NULL, $1, createNode("param", $3, $5, NULL)); }
    ;

function_call:
    T_ID T_LPAREN arg_list T_RPAREN { $$ = createNode("function_call", $1, $3, NULL); }
    ;

arg_list:
    /* Vazio */ { $$ = NULL; }
    | args { $$ = $1; }
    ;

args:
    expression { $$ = createNode("arg_list", NULL, $1, NULL); }
    | args T_COMMA expression { $$ = createNode("arg_list", NULL, $1, $3); }
    ;

print_statement:
    T_PEGAVISAO T_LPAREN expression T_RPAREN { $$ = createNode("print", NULL, $3, NULL); }
    ;

return_statement:
    T_SEPIQUE expression { $$ = createNode("return", NULL, $2, NULL); }
    ;

/* --- Expressoes --- */
expression:
    primary_expression { $$ = $1; }
    | expression T_PLUS expression { $$ = createNode("binary_op", "+", $1, $3); }
    | expression T_MINUS expression { $$ = createNode("binary_op", "-", $1, $3); }
    | expression T_MULTIPLY expression { $$ = createNode("binary_op", "*", $1, $3); }
    | expression T_DIVIDE expression { $$ = createNode("binary_op", "/", $1, $3); }
    | expression T_MODULO expression { $$ = createNode("binary_op", "%", $1, $3); }
    | expression T_POWER expression { $$ = createNode("binary_op", "**", $1, $3); }
    | expression T_EQUAL_EQUAL expression { $$ = createNode("binary_op", "==", $1, $3); }
    | expression T_NOT_EQUAL expression { $$ = createNode("binary_op", "!=", $1, $3); }
    | expression T_LESS expression { $$ = createNode("binary_op", "<", $1, $3); }
    | expression T_GREATER expression { $$ = createNode("binary_op", ">", $1, $3); }
    | expression T_LESS_EQUAL expression { $$ = createNode("binary_op", "<=", $1, $3); }
    | expression T_GREATER_EQUAL expression { $$ = createNode("binary_op", ">=", $1, $3); }
    | expression T_BITWISE_AND expression { $$ = createNode("binary_op", "&", $1, $3); }
    | expression T_BITWISE_OR expression { $$ = createNode("binary_op", "|", $1, $3); }
    | expression T_BITWISE_XOR expression { $$ = createNode("binary_op", "^", $1, $3); }
    | T_MINUS expression %prec T_BITWISE_NOT { $$ = createNode("unary_op", "-", $2, NULL); } /* Negacao unaria */
    | T_BITWISE_NOT expression { $$ = createNode("unary_op", "~", $2, NULL); }
    ;

primary_expression:
    T_ID { $$ = createNode("identifier", $1, NULL, NULL); }
    | literal { $$ = $1; }
    | T_LPAREN expression T_RPAREN { $$ = $2; }
    | function_call { $$ = $1; }
    | T_ID T_LBRACKET expression T_RBRACKET { $$ = createNode("array_access", $1, $3, NULL); }
    ;

literal:
    T_NUM_LITERAL { $$ = createNode("integer_literal", $1, NULL, NULL); }
    | T_FLOAT_LITERAL { $$ = createNode("float_literal", $1, NULL, NULL); }
    | T_CHAR_LITERAL { $$ = createNode("char_literal", $1, NULL, NULL); }
    | T_STRING_LITERAL { $$ = createNode("string_literal", $1, NULL, NULL); }
    ;

%%

/* Codigo C auxiliar */

/* Funcao para criar um novo no da AST */
Node* createNode(char* name, char* value, Node* left, Node* right) {
  Node* newNode = (Node*)malloc(sizeOf(Node));
  if (!newNode) {
    fprintf(stderr, "Ocorreu um erro durante a alocação de memória!");
    exit(1);
  }
  strcpy(newNode->name, name);
  if (value)
    strcpy(newNode->value, value);
  else
    newNode->value[0] = '\0';

  newNode->left = left;
  newNode->right = right;

  return newNode;

}


/*
  Imprime a árvore sintática (com identação) na saída padrão
  Quando o nó for "expr_item", ele será tratado como transparente.
*/
void printTreeInStd(int level, Node* root) {
  if (root == null) return;

  if(str_cmp(root->name, "expr_item") == 0) {
    printTreeInStd(root->left, level);
    return;
  }

  /*
  printf("%*s", level, " "); <----- utilizando o padding do printf
  for(int i = 0; i < level, i++)
    printf(" ");
  */

  printf("%*s", level, " "); // <----- utilizando o padding do printf
  if(strlen(root->value) > 0)
    printf("%s (%s)\n",root->name, root->value);
  else
    printf("%s\n", root->name);

  printTreeInStd(root->left, level + 1);
  printTreeInStd(root->right, level + 1);
}

void printTreeInFile(Node* root, FILE* out, int level) {
  if (root == null) return;

  if(str_cmp(root->name, "expr_item") == 0) {
    printTreeInFile(root->left, out, level);
    return;
  }

  /*
   for (int i = 0; i < level; i++)
         fprintf(out, "  ");
  */
  
  fprintf(out, "%*s", level, " "); // <----- utilizando o padding do printf
  if(strlen(root->value) > 0)
    fprintf(out, "%s (%s)\n",root->name, root->value);
  else
    fprintf(out, "%s\n", root->name);

  printTreeToFile(root->left, level + 1, out);
  printTreeToFile(root->right, level + 1, out);
}

void freeTree(Node* root) {
  if root(root == NULL) return;
  freeTree(root->left);
  freeTree(root->right);
  free(root);
}

void yyerror(const char* s) {
  extern int yylineno;
  fprintf(stderr, "Erro de sintaxe na linha %d: %s\n", yylineno, s);
}


int yydebug = 0;

int main(void) {
  output_file = fopen("output.txt", "w+");
  if(!output_file) {
    fprintf(stderr, "Erro ao abrir arquivo de saída!");
    exit(1);
  }

  yydebug = 1;
  yyparse();
  fclose(output_file);
  return 0;
}
