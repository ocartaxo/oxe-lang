%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h" // Header gerado pelo Bison

extern YYSTYPE yylval; // Variavel para comunicar valores ao Bison

extern FILE* output_file;

typedef enum yytokentype TokenType;

// --- Início da Tabela de Símbolos ---
#define MAX_SYMBOLS 100000        // Número máximo de identificadores na tabela
#define MAX_ID_LENGTH 256       // Tamanho máximo de um identificador
#define MAX_TYPE_LENGTH 128    // Tamanho máximo do tipo de um identificador


/* Estrutura para a tabela de símbolos */
typedef struct {
    char id[MAX_ID_LENGTH];
    char type[MAX_TYPE_LENGTH];
} Identifier;

Identifier identifiers[MAX_SYMBOLS];
int identifier_count = 0;

/* Procura um identificador na tabela de símbolos */
int find_identifier(char *id) {
    for (int i = 0; i < identifier_count; i++) {
        if (strcmp(identifiers[i].id, id) == 0)
            return i;
    }
    return -1;
}

/* Adiciona um identificador à tabela de símbolos */
void add_identifier(char *id, char *type) {
    int idx = find_identifier(id);
    if (idx == -1) {
        strcpy(identifiers[identifier_count].id, id);
        strcpy(identifiers[identifier_count].type, type);
        identifier_count++;
        fprintf(output_file, "<id, %d> ", identifier_count);
    } else {
        fprintf(output_file, "<id, %d> ", idx + 1);
    }
}

// Função para imprimir o tipo de token (para depuração)
void print_token(TokenType type, const char* yytext_val) {
    fprintf(output_file,"<T_");
    switch (type) {
        case T_INTEIRO: fprintf(output_file, "INTEIRO"); break;
        case T_FLUTUANTE: fprintf(output_file, "FLUTUANTE"); break;
        case T_LONGO: fprintf(output_file, "LONGO"); break;
        case T_VAR: fprintf(output_file, "VAR"); break;
        case T_CONST: fprintf(output_file, "CONST"); break;
        case T_OXE: fprintf(output_file, "OXE"); break;
        case T_OXENTE: fprintf(output_file, "OXENTE"); break;
        case T_BROCOU: fprintf(output_file, "BROCOU"); break;
        case T_PEGAVISAO: fprintf(output_file, "PEGAVISAO"); break;
        case T_PALETADA: fprintf(output_file, "PALETADA"); break;
        case T_BARRIL: fprintf(output_file, "BARRIL"); break;
        case T_SEPIQUE: fprintf(output_file, "SEPIQUE"); break;
        case T_SEPLANTE: fprintf(output_file, "SEPLANTE"); break;
        case T_VANESSA: fprintf(output_file, "VANESSA"); break;
        case T_NADA: fprintf(output_file, "NADA"); break;
        case T_FAZ: fprintf(output_file, "FAZ"); break;
        case T_ENQUANTO: fprintf(output_file, "ENQUANTO"); break;

        case T_PLUS: fprintf(output_file, "PLUS"); break;
        case T_MINUS: fprintf(output_file, "MINUS"); break;
        case T_MULTIPLY: fprintf(output_file, "MULTIPLY"); break;
        case T_DIVIDE: fprintf(output_file, "DIVIDE"); break;
        case T_MODULO: fprintf(output_file, "MODULO"); break;
        case T_BITWISE_AND: fprintf(output_file, "BITWISE_AND"); break;
        case T_BITWISE_OR: fprintf(output_file, "BITWISE_OR"); break;
        case T_BITWISE_NOT: fprintf(output_file, "BITWISE_NOT"); break;
        case T_BITWISE_XOR: fprintf(output_file, "BITWISE_XOR"); break;
        case T_EQUAL_EQUAL: fprintf(output_file, "EQUAL_EQUAL"); break;
        case T_NOT_EQUAL: fprintf(output_file,"NOT_EQUAL"); break;
        case T_LESS: fprintf(output_file, "LESS"); break;
        case T_GREATER: fprintf(output_file, "GREATER"); break;
        case T_LESS_EQUAL: fprintf(output_file, "LESS_EQUAL"); break;
        case T_GREATER_EQUAL: fprintf(output_file, "GREATER_EQUAL"); break;
        case T_ASSIGN: fprintf(output_file, "ASSIGN"); break;
        case T_POWER: fprintf(output_file, "POWER"); break;
        case T_INCREMENT: fprintf(output_file, "INCREMENT"); break;
        case T_DECREMENT: fprintf(output_file, "DECREMENT"); break;
        case T_PLUS_ASSIGN: fprintf(output_file, "PLUS_ASSIGN"); break;
        case T_MINUS_ASSIGN: fprintf(output_file, "MINUS_ASSIGN"); break;
        case T_MULTIPLY_ASSIGN: fprintf(output_file, "MULTIPLY_ASSIGN"); break;
        case T_DIVIDE_ASSIGN: fprintf(output_file, "DIVIDE_ASSIGN"); break;
        case T_MODULO_ASSIGN: fprintf(output_file, "MODULO_ASSIGN"); break;

        case T_LPAREN: fprintf(output_file, "LPAREN"); break;
        case T_RPAREN: fprintf(output_file, "RPAREN"); break;
        case T_LBRACE: fprintf(output_file," LBRACE"); break;
        case T_RBRACE: fprintf(output_file, "RBRACE"); break;
        case T_LBRACKET: fprintf(output_file, "LBRACKET"); break;
        case T_RBRACKET: fprintf(output_file, "RBRACKET"); break;
        case T_SEMICOLON: fprintf(output_file, "SEMICOLON"); break;
        case T_COMMA: fprintf(output_file, "COMMA"); break;

        case T_ID: add_identifier(yytext_val,  "UNKNOWN"); break;
        case T_NUM_LITERAL: fprintf(output_file, "NUMBER_LITERAL"); break;
        case T_FLOAT_LITERAL: fprintf(output_file, "FLOAT_LITERAL"); break;
        case T_CHAR_LITERAL: fprintf(output_file, "CHAR_LITERAL"); break;
        case T_STRING_LITERAL: fprintf(output_file, "STRING_LITERAL"); break;
        case T_INVALID: fprintf(output_file, "INVALID"); break;
        
        default: fprintf(output_file, "NOT_DEFINED"); break;
    }
    if (yytext_val) {
        fprintf(output_file, ", '%s'", yytext_val);
    }
    fprintf(output_file,"> ");
}

%}

/* Definicoes de Expressoes Regulares (atalhos) */
DIGIT       [0-9]+
ID          [a-zA-Z_][a-zA-Z0-9]*
FLOAT       {DIGIT}+\.{DIGIT}+([Ee][+-]?{DIGIT}+)?
CHAR        '([^'\\\n]|\\.)'
STRING      \"([^"\\\n]|\\.)*\"
COMMENT     "//".* 
ML_COMMENT  "/*"([^*]|\*+[^*/])*\*+"/"
WHITESPACE  [ \t\n]+

%%
    /* --- REGRAS DO ANALISADOR LEXICO --- */
    /*
    Quando um padrao eh reconhecido, o codigo na acao correspondente eh executado.
    'yytext' eh um ponteiro para o texto que casou com o padrao.
    'strdup(yytext)' cria uma copia da string para que ela nao seja sobrescrita
    pelo proximo token. O parser sera responsavel por liberar essa memoria.
    */

    /* Palavras-chave */
"inteiro"        { print_token(T_INTEIRO, yytext); return T_INTEIRO; }
"flutuante"      { print_token(T_FLUTUANTE, yytext); return T_FLUTUANTE; }
"longo"          { print_token(T_LONGO, yytext); return T_LONGO; }
"var"            { print_token(T_VAR, yytext); return T_VAR; }
"const"          { print_token(T_CONST, yytext); return T_CONST; }
"oxe"            { print_token(T_OXE, yytext); return T_OXE; }
"oxente"         { print_token(T_OXENTE, yytext); return T_OXENTE; }
"brocou"         { print_token(T_BROCOU, yytext); return T_BROCOU; }
"pegaVisao"      { print_token(T_PEGAVISAO, yytext); return T_PEGAVISAO; }
"paletada"       { print_token(T_PALETADA, yytext); return T_PALETADA; }
"barril"         { print_token(T_BARRIL, yytext); return T_BARRIL; }
"sePique"        { print_token(T_SEPIQUE, yytext); return T_SEPIQUE; }
"sePlante"       { print_token(T_SEPLANTE, yytext); return T_SEPLANTE; }
"vaNessa"        { print_token(T_VANESSA, yytext); return T_VANESSA; }
"nada"           { print_token(T_NADA, yytext); return T_NADA; }
"faz"            { print_token(T_FAZ, yytext); return T_FAZ; }
"enquanto"       { print_token(T_ENQUANTO, yytext); return T_ENQUANTO; }

    /* Operadores de Atribuicao */
"="         { print_token(T_ASSIGN, yytext); return T_ASSIGN; }
"+="        { print_token(T_PLUS_ASSIGN, yytext); return T_PLUS_ASSIGN; }
"-="        { print_token(T_MINUS_ASSIGN, yytext); return T_MINUS_ASSIGN; }
"*="        { print_token(T_MULTIPLY_ASSIGN, yytext); return T_MULTIPLY_ASSIGN; }
"/="        { print_token(T_DIVIDE_ASSIGN, yytext); return T_DIVIDE_ASSIGN; }
"%="        { print_token(T_MODULO_ASSIGN, yytext); return T_MODULO_ASSIGN; }

    /* Operadores Aritmeticos e de Potencia */
"+"         { print_token(T_PLUS, yytext); return T_PLUS; }
"-"         { print_token(T_MINUS, yytext); return T_MINUS; }
"*"         { print_token(T_MULTIPLY, yytext); return T_MULTIPLY; }
"/"         { print_token(T_DIVIDE, yytext); return T_DIVIDE; }
"%"         { print_token(T_MODULO, yytext); return T_MODULO; }
"**"        { print_token(T_POWER, yytext); return T_POWER; }

    /* Operadores de Incremento e Decremento */
"++"        { print_token(T_INCREMENT, yytext); return T_INCREMENT; }
"--"        { print_token(T_DECREMENT, yytext); return T_DECREMENT; }

    /* Operadores Relacionais */
"=="        { print_token(T_EQUAL_EQUAL, yytext); return T_EQUAL_EQUAL; }
"!="        { print_token(T_NOT_EQUAL, yytext); return T_NOT_EQUAL; }
"<"         { print_token(T_LESS, yytext); return T_LESS; }
">"         { print_token(T_GREATER, yytext); return T_GREATER; }
"<="        { print_token(T_LESS_EQUAL, yytext); return T_LESS_EQUAL; }
">="        { print_token(T_GREATER_EQUAL, yytext); return T_GREATER_EQUAL; }

    /* Operadores Bitwise */
"&"         { print_token(T_BITWISE_AND, yytext); return T_BITWISE_AND; }
"|"         { print_token(T_BITWISE_OR, yytext); return T_BITWISE_OR; }
"~"         { print_token(T_BITWISE_NOT, yytext); return T_BITWISE_NOT; }
"^"         { print_token(T_BITWISE_XOR, yytext); return T_BITWISE_XOR; }

    /* Delimitadores */
"("         { print_token(T_LPAREN, yytext); return T_LPAREN; }
")"         { print_token(T_RPAREN, yytext); return T_RPAREN; }
"{"         { print_token(T_LBRACE, yytext); return T_LBRACE; }
"}"         { print_token(T_RBRACE, yytext); return T_RBRACE; }
"["         { print_token(T_LBRACKET, yytext); return T_LBRACKET; }
"]"         { print_token(T_RBRACKET, yytext); return T_RBRACKET; }
";"         { print_token(T_SEMICOLON, yytext); return T_SEMICOLON; }
","         { print_token(T_COMMA, yytext); return T_COMMA; }
":"         { print_token(T_COLON, yytext); return T_COLON; }


    /* Literais */
{DIGIT}   {
              yylval.str = strdup(yytext);
              print_token(T_NUM_LITERAL, yytext);
              return T_NUM_LITERAL;
          }
{FLOAT}   {
              yylval.str = strdup(yytext);
              print_token(T_FLOAT_LITERAL, yytext);
              return T_FLOAT_LITERAL;
          }
{STRING}  {
              yylval.str = strdup(yytext);
              print_token(T_STRING_LITERAL, yytext);
              return T_STRING_LITERAL;
          }
{CHAR}    {
              yylval.str = strdup(yytext);
              print_token(T_CHAR_LITERAL, yytext);
              return T_CHAR_LITERAL;
          }
    /* Identificador */
{ID}      {
              yylval.str = strdup(yytext);
              print_token(T_ID, yytext);
              return T_ID;
          }
    /* Ignorar comentarios e espacos em branco */
{COMMENT}     { /* Ignora comentários de linha única */ }
{ML_COMMENT}  { /* Ignora comentários de multiplas linhas */ }
{WHITESPACE}  { /* Ignora espaços em branco, tabs, novas linhas e retornos de carro */ }

    /* Tratamento de erro para caracteres invalidos */
.           { print_token(T_INVALID, yytext); return T_INVALID; }

%%

