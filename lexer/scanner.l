%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h" // Header gerado pelo Bison

extern YYSTYPE yylval; // Variavel para comunicar valores ao Bison

extern FILE* output_file;


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

//TODO alterar prinf para fprintf (imprimir no arquivo de saida)
// Função para imprimir o tipo de token (para depuração)
void print_token(TokenType type, const char* yytext_val) {
    printf("<T_");
    switch (type) {
        case T_INTEIRO: printf("INTEIRO"); break;
        case T_FLUTUANTE: printf("FLUTUANTE"); break;
        case T_LONGO: printf("LONGO"); break;
        case T_VAR: printf("VAR"); break;
        case T_CONST: printf("CONST"); break;
        case T_OXE: printf("OXE"); break;
        case T_OXENTE: printf("OXENTE"); break;
        case T_BROCOU: printf("BROCOU"); break;
        case T_PEGAVISAO: printf("PEGAVISAO"); break;
        case T_PALETADA: printf("PALETADA"); break;
        case T_BARRIL: printf("BARRIL"); break;
        case T_SEPIQUE: printf("SEPIQUE"); break;
        case T_SEPLANTE: printf("SEPLANTE"); break;
        case T_VANESSA: printf("VANESSA"); break;
        case T_NADA: printf("NADA"); break;
        case T_FAZ: printf("FAZ"); break;
        case T_ENQUANTO: printf("ENQUANTO"); break;

        case T_PLUS: printf("PLUS"); break;
        case T_MINUS: printf("MINUS"); break;
        case T_MULTIPLY: printf("MULTIPLY"); break;
        case T_DIVIDE: printf("DIVIDE"); break;
        case T_MODULO: printf("MODULO"); break;
        case T_BITWISE_AND: printf("BITWISE_AND"); break;
        case T_BITWISE_OR: printf("BITWISE_OR"); break;
        case T_BITWISE_NOT: printf("BITWISE_NOT"); break;
        case T_BITWISE_XOR: printf("BITWISE_XOR"); break;
        case T_EQUAL_EQUAL: printf("EQUAL_EQUAL"); break;
        case T_NOT_EQUAL: printf("NOT_EQUAL"); break;
        case T_LESS: printf("LESS"); break;
        case T_GREATER: printf("GREATER"); break;
        case T_LESS_EQUAL: printf("LESS_EQUAL"); break;
        case T_GREATER_EQUAL: printf("GREATER_EQUAL"); break;
        case T_ASSIGN: printf("ASSIGN"); break;
        case T_POWER: printf("POWER"); break;
        case T_INCREMENT: printf("INCREMENT"); break;
        case T_DECREMENT: printf("DECREMENT"); break;
        case T_PLUS_ASSIGN: printf("PLUS_ASSIGN"); break;
        case T_MINUS_ASSIGN: printf("MINUS_ASSIGN"); break;
        case T_MULTIPLY_ASSIGN: printf("MULTIPLY_ASSIGN"); break;
        case T_DIVIDE_ASSIGN: printf("DIVIDE_ASSIGN"); break;
        case T_MODULO_ASSIGN: printf("MODULO_ASSIGN"); break;

        case T_LPAREN: printf("LPAREN"); break;
        case T_RPAREN: printf("RPAREN"); break;
        case T_LBRACE: printf("LBRACE"); break;
        case T_RBRACE: printf("RBRACE"); break;
        case T_LBRACKET: printf("LBRACKET"); break;
        case T_RBRACKET: printf("RBRACKET"); break;
        case T_SEMICOLON: printf("SEMICOLON"); break;
        case T_COMMA: printf("COMMA"); break;

        case T_ID: add_identifier(yytext_val, "unknown"); break;
        case T_NUM_LITERAL: printf("NUMBER_LITERAL"); break;
        case T_FLOAT_LITERAL: printf("FLOAT_LITERAL"); break;
        case T_CHAR_LITERAL: printf("CHAR_LITERAL"); break;
        case T_STRING_LITERAL: printf("STRING_LITERAL"); break;

        case T_ERROR: printf("ERROR"); break;
        case T_EOF: printf("EOF"); break;
        default: printf("UNKNOWN"); break;
    }
    if (yytext_val) {
        printf(", '%s'", yytext_val);
    }
    printf(">\n");
}

%}

%option noyywrap
%option yylineno

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
.           { printf(output_file, "<invalido, %s> ", yytext); return T_ERROR; }

%%


int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Não foi possível abrir o arquivo");
            return 1;
        }
    } else {
        printf("Uso: %s <arquivo_fonte>\n", argv[0]);
        return 1;
    }

    while(yylex() != 0) {}

    if (yyin != stdin && yyin != NULL) {
        fclose(yyin);
    }

    print_token(T_EOF, NULL); // Sinaliza o fim do arquivo
    return 0;
}
