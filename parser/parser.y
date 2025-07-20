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

%union {
  char* str;
  Node* node;
}
