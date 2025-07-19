%code requires (
  typedef struct Node Node;
)

${
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Node {
  char name[50]; // podia ser ponteiro?
  char value[50];
  struct Node* left;
  struct Node* right;
} Node;



}
