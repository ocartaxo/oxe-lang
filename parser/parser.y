%code requires (
  typedef struct Node Node;
)
${
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
  if (newNode == null){
    fprintf(stderr, "Ocorreu um erro durante a alocação de memória");
    exit(1);
  }
  strcpy(newNode->name, name);
  if (value)
    strcpy(newNode->value, value);
  else
    newNode->value[0] = '\0';

  newNode->right = right;
  newNode->left  = left;
  return newNode;
}

void printToStd() {

}

}
