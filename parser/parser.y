%code requires {
    /* Declaração antecipada para que o header conheça o tipo Node */
    typedef struct Node Node;
}
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define OUPUT_FILE "out.txt"

typedef struct Node {
  char name[50]; // podia ser ponteiro?
  char value[50];
  struct Node* left;
  struct Node* right;
} Node;

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

  // for (int i = 0; i < level; i++) 
  //       fprintf(out, "  ");

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
  printf("Ocorreu um erro: %s\n", s);
}

int yylex();
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
%token <str> T_INTEGER_LITERAL T_FLOAT_LITERAL T_CHAR_LITERAL T_STRING_LITERAL

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
%type <node> expression term factor primary_expression literal

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
