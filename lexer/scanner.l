%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Definições de tokens (podem ser usadas por um parser como Yacc/Bison)
typedef enum {
    TOKEN_KEYWORD_INTEIRO = 1,
    TOKEN_KEYWORD_FLUTUANTE,
    TOKEN_KEYWORD_LONGO,
    TOKEN_KEYWORD_VAR,
    TOKEN_KEYWORD_CONST,
    TOKEN_KEYWORD_OXE,
    TOKEN_KEYWORD_OXENTE,
    TOKEN_KEYWORD_BROCOU,
    TOKEN_KEYWORD_PEGAVISAO,
    TOKEN_KEYWORD_PALETADA,
    TOKEN_KEYWORD_BARRIL,
    TOKEN_KEYWORD_SEPIQUE,
    TOKEN_KEYWORD_SEPLANTE,
    TOKEN_KEYWORD_VANESSA,
    TOKEN_KEYWORD_NADA, // Adicionado para tipo de retorno de função
    TOKEN_KEYWORD_FAZ,   // Adicionado para o do-while
    TOKEN_KEYWORD_ENQUANTO, // Adicionado para o while/do-while

    TOKEN_OPERATOR_PLUS,
    TOKEN_OPERATOR_MINUS,
    TOKEN_OPERATOR_MULTIPLY,
    TOKEN_OPERATOR_DIVIDE,
    TOKEN_OPERATOR_MODULO,
    TOKEN_OPERATOR_BITWISE_AND,
    TOKEN_OPERATOR_BITWISE_OR,
    TOKEN_OPERATOR_BITWISE_NOT,
    TOKEN_OPERATOR_BITWISE_XOR,
    TOKEN_OPERATOR_EQUAL_EQUAL,
    TOKEN_OPERATOR_NOT_EQUAL,
    TOKEN_OPERATOR_LESS,
    TOKEN_OPERATOR_GREATER,
    TOKEN_OPERATOR_LESS_EQUAL,
    TOKEN_OPERATOR_GREATER_EQUAL,
    TOKEN_OPERATOR_ASSIGN,
    TOKEN_OPERATOR_POWER, // Adicionado para **
    TOKEN_OPERATOR_INCREMENT, // Adicionado para ++
    TOKEN_OPERATOR_DECREMENT, // Adicionado para --
    TOKEN_OPERATOR_PLUS_ASSIGN, // Adicionado para +=
    TOKEN_OPERATOR_MINUS_ASSIGN, // Adicionado para -=
    TOKEN_OPERATOR_MULTIPLY_ASSIGN, // Adicionado para *=
    TOKEN_OPERATOR_DIVIDE_ASSIGN, // Adicionado para /=
    TOKEN_OPERATOR_MODULO_ASSIGN, // Adicionado para %=

    TOKEN_DELIMITER_LPAREN,
    TOKEN_DELIMITER_RPAREN,
    TOKEN_DELIMITER_LBRACE,
    TOKEN_DELIMITER_RBRACE,
    TOKEN_DELIMITER_LBRACKET,
    TOKEN_DELIMITER_RBRACKET,
    TOKEN_DELIMITER_SEMICOLON,
    TOKEN_DELIMITER_COMMA,
    TOKEN_DELIMITER_COLON, // Adicionado para parâmetros de função

    TOKEN_IDENTIFIER,
    TOKEN_INTEGER_LITERAL,
    TOKEN_FLOAT_LITERAL,
    TOKEN_CHAR_LITERAL,
    TOKEN_STRING_LITERAL,

    TOKEN_ERROR,
    TOKEN_EOF
} TokenType;

// --- Início da Tabela de Símbolos ---
#define MAX_SYMBOLS 100000        // Número máximo de identificadores na tabela
#define MAX_ID_LENGTH 256       // Tamanho máximo de um identificador

char symbol_table[MAX_SYMBOLS][MAX_ID_LENGTH]; // Array para armazenar os identificadores
int symbol_count = 0;                           // Contador de identificadores na tabela

// Função para obter a posição de um identificador na tabela de símbolos
// Se o identificador já existe, retorna sua posição.
// Se não existe, adiciona-o e retorna a nova posição.
// Retorna -1 em caso de erro (tabela cheia).
int get_symbol_position(const char* id) {
    // Procura o identificador na tabela
    for (int i = 0; i < symbol_count; ++i) {
        if (strcmp(symbol_table[i], id) == 0) {
            return i; // Identificador encontrado, retorna sua posição
        }
    }

    // Se o identificador não foi encontrado, adiciona-o à tabela
    if (symbol_count < MAX_SYMBOLS) {
        strncpy(symbol_table[symbol_count], id, MAX_ID_LENGTH - 1);
        symbol_table[symbol_count][MAX_ID_LENGTH - 1] = '\0'; // Garante terminação nula
        return symbol_count++; // Retorna a nova posição e incrementa o contador
    } else {
        fprintf(stderr, "Erro: Tabela de símbolos cheia! Não foi possível adicionar '%s'\n", id);
        return -1; // Indica erro (tabela cheia)
    }
}

void print_identifier(const char* yytext_val) {
  printf("ID");
  int pos = get_symbol_position(yytext_val);
  if (pos != -1){
    printf(", %d", pos);
  }

}


// Função para imprimir o tipo de token (para depuração)
void print_token(TokenType type, const char* yytext_val) {
    printf("<TOKEN_");
    switch (type) {
        case TOKEN_KEYWORD_INTEIRO: printf("INTEIRO"); break;
        case TOKEN_KEYWORD_FLUTUANTE: printf("FLUTUANTE"); break;
        case TOKEN_KEYWORD_LONGO: printf("LONGO"); break;
        case TOKEN_KEYWORD_VAR: printf("VAR"); break;
        case TOKEN_KEYWORD_CONST: printf("CONST"); break;
        case TOKEN_KEYWORD_OXE: printf("OXE"); break;
        case TOKEN_KEYWORD_OXENTE: printf("OXENTE"); break;
        case TOKEN_KEYWORD_BROCOU: printf("BROCOU"); break;
        case TOKEN_KEYWORD_PEGAVISAO: printf("PEGAVISAO"); break;
        case TOKEN_KEYWORD_PALETADA: printf("PALETADA"); break;
        case TOKEN_KEYWORD_BARRIL: printf("BARRIL"); break;
        case TOKEN_KEYWORD_SEPIQUE: printf("SEPIQUE"); break;
        case TOKEN_KEYWORD_SEPLANTE: printf("SEPLANTE"); break;
        case TOKEN_KEYWORD_VANESSA: printf("VANESSA"); break;
        case TOKEN_KEYWORD_NADA: printf("NADA"); break;
        case TOKEN_KEYWORD_FAZ: printf("FAZ"); break;
        case TOKEN_KEYWORD_ENQUANTO: printf("ENQUANTO"); break;

        case TOKEN_OPERATOR_PLUS: printf("PLUS"); break;
        case TOKEN_OPERATOR_MINUS: printf("MINUS"); break;
        case TOKEN_OPERATOR_MULTIPLY: printf("MULTIPLY"); break;
        case TOKEN_OPERATOR_DIVIDE: printf("DIVIDE"); break;
        case TOKEN_OPERATOR_MODULO: printf("MODULO"); break;
        case TOKEN_OPERATOR_BITWISE_AND: printf("BITWISE_AND"); break;
        case TOKEN_OPERATOR_BITWISE_OR: printf("BITWISE_OR"); break;
        case TOKEN_OPERATOR_BITWISE_NOT: printf("BITWISE_NOT"); break;
        case TOKEN_OPERATOR_BITWISE_XOR: printf("BITWISE_XOR"); break;
        case TOKEN_OPERATOR_EQUAL_EQUAL: printf("EQUAL_EQUAL"); break;
        case TOKEN_OPERATOR_NOT_EQUAL: printf("NOT_EQUAL"); break;
        case TOKEN_OPERATOR_LESS: printf("LESS"); break;
        case TOKEN_OPERATOR_GREATER: printf("GREATER"); break;
        case TOKEN_OPERATOR_LESS_EQUAL: printf("LESS_EQUAL"); break;
        case TOKEN_OPERATOR_GREATER_EQUAL: printf("GREATER_EQUAL"); break;
        case TOKEN_OPERATOR_ASSIGN: printf("ASSIGN"); break;
        case TOKEN_OPERATOR_POWER: printf("POWER"); break;
        case TOKEN_OPERATOR_INCREMENT: printf("INCREMENT"); break;
        case TOKEN_OPERATOR_DECREMENT: printf("DECREMENT"); break;
        case TOKEN_OPERATOR_PLUS_ASSIGN: printf("PLUS_ASSIGN"); break;
        case TOKEN_OPERATOR_MINUS_ASSIGN: printf("MINUS_ASSIGN"); break;
        case TOKEN_OPERATOR_MULTIPLY_ASSIGN: printf("MULTIPLY_ASSIGN"); break;
        case TOKEN_OPERATOR_DIVIDE_ASSIGN: printf("DIVIDE_ASSIGN"); break;
        case TOKEN_OPERATOR_MODULO_ASSIGN: printf("MODULO_ASSIGN"); break;

        case TOKEN_DELIMITER_LPAREN: printf("LPAREN"); break;
        case TOKEN_DELIMITER_RPAREN: printf("RPAREN"); break;
        case TOKEN_DELIMITER_LBRACE: printf("LBRACE"); break;
        case TOKEN_DELIMITER_RBRACE: printf("RBRACE"); break;
        case TOKEN_DELIMITER_LBRACKET: printf("LBRACKET"); break;
        case TOKEN_DELIMITER_RBRACKET: printf("RBRACKET"); break;
        case TOKEN_DELIMITER_SEMICOLON: printf("SEMICOLON"); break;
        case TOKEN_DELIMITER_COMMA: printf("COMMA"); break;
        case TOKEN_DELIMITER_COLON: printf("COLON"); break;

        case TOKEN_IDENTIFIER: print_identifier(yytext_val); break;
        case TOKEN_INTEGER_LITERAL: printf("INTEGER_LITERAL"); break;
        case TOKEN_FLOAT_LITERAL: printf("FLOAT_LITERAL"); break;
        case TOKEN_CHAR_LITERAL: printf("CHAR_LITERAL"); break;
        case TOKEN_STRING_LITERAL: printf("STRING_LITERAL"); break;

        case TOKEN_ERROR: printf("ERROR"); break;
        case TOKEN_EOF: printf("EOF"); break;
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

DIGIT       [0-9]+
LETTER      [a-zA-Z]
ID          {LETTER}({LETTER}|{DIGIT}|_)*
INTEGER     {DIGIT}+
FLOAT       {DIGIT}+\.{DIGIT}+([Ee][+-]?{DIGIT}+)?
CHAR        '([^'\\\n]|\\.)'
STRING      \"([^"\\\n]|\\.)*\"
COMMENT     "//".* 
ML_COMMENT  "/*"([^*]|\*+[^*/])*\*+"/"
WHITESPACE  [ \t\n]+

%%

"inteiro"   { print_token(TOKEN_KEYWORD_INTEIRO, yytext); return TOKEN_KEYWORD_INTEIRO; }
"flutuante" { print_token(TOKEN_KEYWORD_FLUTUANTE, yytext); return TOKEN_KEYWORD_FLUTUANTE; }
"longo"     { print_token(TOKEN_KEYWORD_LONGO, yytext); return TOKEN_KEYWORD_LONGO; }
"var"    { print_token(TOKEN_KEYWORD_VAR, yytext); return TOKEN_KEYWORD_VAR; }
"const"     { print_token(TOKEN_KEYWORD_CONST, yytext); return TOKEN_KEYWORD_CONST; }
"oxe"       { print_token(TOKEN_KEYWORD_OXE, yytext); return TOKEN_KEYWORD_OXE; }
"oxente"    { print_token(TOKEN_KEYWORD_OXENTE, yytext); return TOKEN_KEYWORD_OXENTE; }
"brocou"    { print_token(TOKEN_KEYWORD_BROCOU, yytext); return TOKEN_KEYWORD_BROCOU; }
"pegaVisao"      { print_token(TOKEN_KEYWORD_PEGAVISAO, yytext); return TOKEN_KEYWORD_PEGAVISAO; }
"paletada"  { print_token(TOKEN_KEYWORD_PALETADA, yytext); return TOKEN_KEYWORD_PALETADA; }
"barril"    { print_token(TOKEN_KEYWORD_BARRIL, yytext); return TOKEN_KEYWORD_BARRIL; }
"sePique"  { print_token(TOKEN_KEYWORD_SEPIQUE, yytext); return TOKEN_KEYWORD_SEPIQUE; }
"sePlante" { print_token(TOKEN_KEYWORD_SEPLANTE, yytext); return TOKEN_KEYWORD_SEPLANTE; }
"vaNessa"  { print_token(TOKEN_KEYWORD_VANESSA, yytext); return TOKEN_KEYWORD_VANESSA; }
"nada"      { print_token(TOKEN_KEYWORD_NADA, yytext); return TOKEN_KEYWORD_NADA; }
"faz"        { print_token(TOKEN_KEYWORD_FAZ, yytext); return TOKEN_KEYWORD_FAZ; }
"enquanto"     { print_token(TOKEN_KEYWORD_ENQUANTO, yytext); return TOKEN_KEYWORD_ENQUANTO; }

"+"         { print_token(TOKEN_OPERATOR_PLUS, yytext); return TOKEN_OPERATOR_PLUS; }
"-"         { print_token(TOKEN_OPERATOR_MINUS, yytext); return TOKEN_OPERATOR_MINUS; }
"*"         { print_token(TOKEN_OPERATOR_MULTIPLY, yytext); return TOKEN_OPERATOR_MULTIPLY; }
"/"         { print_token(TOKEN_OPERATOR_DIVIDE, yytext); return TOKEN_OPERATOR_DIVIDE; }
"%"         { print_token(TOKEN_OPERATOR_MODULO, yytext); return TOKEN_OPERATOR_MODULO; }
"&"         { print_token(TOKEN_OPERATOR_BITWISE_AND, yytext); return TOKEN_OPERATOR_BITWISE_AND; }
"|"         { print_token(TOKEN_OPERATOR_BITWISE_OR, yytext); return TOKEN_OPERATOR_BITWISE_OR; }
"~"         { print_token(TOKEN_OPERATOR_BITWISE_NOT, yytext); return TOKEN_OPERATOR_BITWISE_NOT; }
"^"         { print_token(TOKEN_OPERATOR_BITWISE_XOR, yytext); return TOKEN_OPERATOR_BITWISE_XOR; }
"=="        { print_token(TOKEN_OPERATOR_EQUAL_EQUAL, yytext); return TOKEN_OPERATOR_EQUAL_EQUAL; }
"!="        { print_token(TOKEN_OPERATOR_NOT_EQUAL, yytext); return TOKEN_OPERATOR_NOT_EQUAL; }
"<"         { print_token(TOKEN_OPERATOR_LESS, yytext); return TOKEN_OPERATOR_LESS; }
">"         { print_token(TOKEN_OPERATOR_GREATER, yytext); return TOKEN_OPERATOR_GREATER; }
"<="        { print_token(TOKEN_OPERATOR_LESS_EQUAL, yytext); return TOKEN_OPERATOR_LESS_EQUAL; }
">="        { print_token(TOKEN_OPERATOR_GREATER_EQUAL, yytext); return TOKEN_OPERATOR_GREATER_EQUAL; }
"="         { print_token(TOKEN_OPERATOR_ASSIGN, yytext); return TOKEN_OPERATOR_ASSIGN; }
"**"        { print_token(TOKEN_OPERATOR_POWER, yytext); return TOKEN_OPERATOR_POWER; }
"++"        { print_token(TOKEN_OPERATOR_INCREMENT, yytext); return TOKEN_OPERATOR_INCREMENT; }
"--"        { print_token(TOKEN_OPERATOR_DECREMENT, yytext); return TOKEN_OPERATOR_DECREMENT; }
"+="        { print_token(TOKEN_OPERATOR_PLUS_ASSIGN, yytext); return TOKEN_OPERATOR_PLUS_ASSIGN; }
"-="        { print_token(TOKEN_OPERATOR_MINUS_ASSIGN, yytext); return TOKEN_OPERATOR_MINUS_ASSIGN; }
"*="        { print_token(TOKEN_OPERATOR_MULTIPLY_ASSIGN, yytext); return TOKEN_OPERATOR_MULTIPLY_ASSIGN; }
"/="        { print_token(TOKEN_OPERATOR_DIVIDE_ASSIGN, yytext); return TOKEN_OPERATOR_DIVIDE_ASSIGN; }
"%="        { print_token(TOKEN_OPERATOR_MODULO_ASSIGN, yytext); return TOKEN_OPERATOR_MODULO_ASSIGN; }

"("         { print_token(TOKEN_DELIMITER_LPAREN, yytext); return TOKEN_DELIMITER_LPAREN; }
")"         { print_token(TOKEN_DELIMITER_RPAREN, yytext); return TOKEN_DELIMITER_RPAREN; }
"{"         { print_token(TOKEN_DELIMITER_LBRACE, yytext); return TOKEN_DELIMITER_LBRACE; }
"}"         { print_token(TOKEN_DELIMITER_RBRACE, yytext); return TOKEN_DELIMITER_RBRACE; }
"["         { print_token(TOKEN_DELIMITER_LBRACKET, yytext); return TOKEN_DELIMITER_LBRACKET; }
"]"         { print_token(TOKEN_DELIMITER_RBRACKET, yytext); return TOKEN_DELIMITER_RBRACKET; }
";"         { print_token(TOKEN_DELIMITER_SEMICOLON, yytext); return TOKEN_DELIMITER_SEMICOLON; }
","         { print_token(TOKEN_DELIMITER_COMMA, yytext); return TOKEN_DELIMITER_COMMA; }
":"         { print_token(TOKEN_DELIMITER_COLON, yytext); return TOKEN_DELIMITER_COLON; }

{FLOAT}     { print_token(TOKEN_FLOAT_LITERAL, yytext); return TOKEN_FLOAT_LITERAL; }
{INTEGER}   { print_token(TOKEN_INTEGER_LITERAL, yytext); return TOKEN_INTEGER_LITERAL; }
{CHAR}      { print_token(TOKEN_CHAR_LITERAL, yytext); return TOKEN_CHAR_LITERAL; }
{STRING}    { print_token(TOKEN_STRING_LITERAL, yytext); return TOKEN_STRING_LITERAL; }

{ID}        { print_token(TOKEN_IDENTIFIER, yytext); return TOKEN_IDENTIFIER; }

{COMMENT}   { /* Ignora comentários de linha única */ }
{ML_COMMENT} { /* Ignora comentários de multiplas linhas */ }
{WHITESPACE}  { /* Ignora espaços em branco, tabs, novas linhas e retornos de carro */ }

.           { print_token(TOKEN_ERROR, yytext); return TOKEN_ERROR; }

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

    print_token(TOKEN_EOF, NULL); // Sinaliza o fim do arquivo
    return 0;
}
