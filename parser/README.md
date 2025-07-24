# Documentação do Analisador Sintático da Linguagem Oxelang

Este documento descreve o parser da linguagem de programação 'Oxe Lang', desenvolvido utilizando as ferramentas Lex (Flex) e Yacc (Bison). A linguagem 'Oxe Lang' é uma linguagem didática com sintaxe inspirada no português brasileiro, projetada para demonstrar conceitos de compiladores e processamento de linguagens.

## Visão Geral da Linguagem

A linguagem 'Oxe Lang' incorpora elementos de linguagens de programação tradicionais, mas com palavras-chave e estruturas adaptadas para o português. Ela suporta declaração de variáveis e constantes, diferentes tipos de dados, estruturas de controle de fluxo (condicionais e laços), definição e chamada de funções, e operações aritméticas e lógicas.

## Estrutura do Parser

O parser é construído com base em um arquivo de especificação Yacc (`parser.l`, que contém as regras gramaticais) e um arquivo de especificação Lex (`lexer.l`, que define os tokens). Juntos, eles formam a base para a análise sintática da linguagem.

### Tokens e Palavras-Chave

Os tokens são os menores elementos significativos da linguagem, reconhecidos pelo analisador léxico. As palavras-chave são identificadores reservados com significado especial.

| Categoria                  | Token/Palavra-Chave       | Descrição                                                |
| -------------------------- | ------------------------- | -------------------------------------------------------- |
| **Declaração**             | `T_VAR` (var)             | Declaração de variável                                   |
|                            | `T_CONST` (const)         | Declaração de constante                                  |
| **Tipos de Dados**         | `T_INTEIRO` (inteiro)     | Tipo de dado inteiro                                     |
|                            | `T_FLUTUANTE` (flutuante) | Tipo de dado de ponto flutuante                          |
|                            | `T_LONGO` (longo)         | Tipo de dado longo                                       |
|                            | `T_OXE` (oxe)             | Tipo de dado booleano (verdadeiro/falso)                 |
|                            | `T_OXENTE` (oxente)       | Tipo de dado de caractere                                |
|                            | `T_NADA` (nada)           | Tipo de retorno vazio (void) para funções                |
| **Estruturas de Controle** | `T_SEPIQUE` (sePique)     | Palavra-chave para retorno de função                     |
|                            | `T_BROCOU` (brocou)       | Palavra-chave para a função principal (main)             |
|                            | `T_SEPLANTE` (sePlante)   | Palavra-chave para a estrutura condicional `if`          |
|                            | `T_VANESSA` (vaNessa)     | Palavra-chave para a estrutura condicional `else`        |
|                            | `T_PALETADA` (paletada)   | Palavra-chave para o laço `for`                          |
|                            | `T_ENQUANTO` (enquanto)   | Palavra-chave para o laço `while`                        |
|                            | `T_FAZ` (faz)             | Palavra-chave para o laço `do-while`                     |
| **Funções**                | `T_BARRIL` (barril)       | Palavra-chave para declaração de função                  |
|                            | `T_PEGAVISAO` (pegaVisao) | Palavra-chave para instrução de impressão (print)        |
| **Literais**               | `T_ID`                    | Identificador (nomes de variáveis, funções, etc.)        |
|                            | `T_NUM_LITERAL`           | Literal numérico inteiro                                 |
|                            | `T_FLOAT_LITERAL`         | Literal numérico de ponto flutuante                      |
|                            | `T_CHAR_LITERAL`          | Literal de caractere                                     |
|                            | `T_STRING_LITERAL`        | Literal de string                                        |
| **Operadores**             | `T_ASSIGN` (=)            | Atribuição                                               |
|                            | `T_PLUS` (+)              | Adição                                                   |
|                            | `T_MINUS` (-)             | Subtração                                                |
|                            | `T_MULTIPLY` (*)          | Multiplicação                                            |
|                            | `T_DIVIDE` (/)            | Divisão                                                  |
|                            | `T_MODULO` (%)            | Módulo                                                   |
|                            | `T_POWER` (**)            | Potência                                                 |
|                            | `T_PLUS_ASSIGN` (+=)      | Atribuição com adição                                    |
|                            | `T_MINUS_ASSIGN` (-=)     | Atribuição com subtração                                 |
|                            | `T_MULTIPLY_ASSIGN` (*=)  | Atribuição com multiplicação                             |
|                            | `T_DIVIDE_ASSIGN` (/=)    | Atribuição com divisão                                   |
|                            | `T_MODULO_ASSIGN` (%=)    | Atribuição com módulo                                    |
|                            | `T_INCREMENT` (++)        | Incremento                                               |
|                            | `T_DECREMENT` (--)        | Decremento                                               |
|                            | `T_EQUAL_EQUAL` (==)      | Igualdade                                                |
|                            | `T_NOT_EQUAL` (!=)        | Diferença                                                |
|                            | `T_LESS` (<)              | Menor que                                                |
|                            | `T_GREATER` (>)           | Maior que                                                |
|                            | `T_LESS_EQUAL` (<=)       | Menor ou igual a                                         |
|                            | `T_GREATER_EQUAL` (>=)    | Maior ou igual a                                         |
|                            | `T_BITWISE_AND` (&)       | AND bit a bit                                            |
|                            | `T_BITWISE_OR` (          | )                                                        |
|                            | `T_BITWISE_XOR` (^)       | XOR bit a bit                                            |
|                            | `T_BITWISE_NOT` (~)       | NOT bit a bit                                            |
| **Delimitadores**          | `T_LPAREN` (()            | Parêntese esquerdo                                       |
|                            | `T_RPAREN` ())            | Parêntese direito                                        |
|                            | `T_LBRACE` ({)            | Chave esquerda                                           |
|                            | `T_RBRACE` (})            | Chave direita                                            |
|                            | `T_LBRACKET` ([)          | Colchete esquerdo                                        |
|                            | `T_RBRACKET` (])          | Colchete direito                                         |
|                            | `T_SEMICOLON` (;)         | Ponto e vírgula (terminador de instrução)                |
|                            | `T_COMMA` (,)             | Vírgula (separador)                                      |
|                            | `T_COLON` (:)             | Dois pontos (separador de tipo em declarações de função) |

### Regras Gramaticais (Produções)

As regras gramaticais definem a sintaxe da linguagem, ou seja, como os tokens podem ser combinados para formar construções válidas. Abaixo estão as principais regras gramaticais definidas no `parser.l`:

#### 1. Programa e Lista de Instruções

- `program`: O ponto de entrada do parser, que consiste em uma lista de instruções.
- `statement_list`: Uma sequência de uma ou mais instruções.
- `statement`: Uma instrução individual, que pode ser uma declaração, atribuição, estrutura de controle, chamada de função, etc.
- `block`: Um bloco de código delimitado por chaves `{}`.

#### 2. Declaração de Variáveis

- `declaration`: Define como variáveis e constantes são declaradas, incluindo o especificador (`var` ou `const`), o tipo e uma lista de declarações de variáveis.
- `var_specifier`: Indica se a declaração é de uma variável (`var`) ou constante (`const`).
- `type`: Especifica o tipo de dado da variável (`inteiro`, `flutuante`, `longo`, `oxe`, `oxente`).
- `var_declaration_list`: Uma lista de declarações de variáveis, separadas por vírgulas.
- `var_declaration`: Uma declaração de variável individual, que pode incluir uma inicialização ou ser uma declaração de array.
- `var_initializer`: A parte de inicialização de uma variável, usando o operador de atribuição `=`. 

#### 3. Atribuição

- `assignment`: Define como valores são atribuídos a variáveis, incluindo atribuições simples, atribuições com operadores compostos (ex: `+=`), e operações de incremento/decremento.
- `assignment_operator`: Os diferentes operadores de atribuição suportados.

#### 4. Estruturas de Controle

- `if_statement`: A estrutura condicional `sePlante` (if), que pode incluir uma parte `vaNessa` (else) opcional.
- `else_part`: A parte opcional `vaNessa` (else) de uma instrução `sePlante`.
- `while_loop`: O laço `enquanto` (while).
- `do_while_loop`: O laço `faz...enquanto` (do-while).
- `for_loop`: O laço `paletada` (for), com suas partes de inicialização, condição e incremento.

#### 5. Funções

- `function_definition`: Define a estrutura de uma função, incluindo o nome, lista de parâmetros, tipo de retorno e o corpo da função.
- `return_type`: O tipo de retorno da função, que pode ser um tipo de dado ou `nada` (void).
- `param_list`: A lista de parâmetros de uma função.
- `params`: Parâmetros individuais de uma função, com seu nome e tipo.
- `function_call`: A chamada de uma função, com seu nome e lista de argumentos.
- `arg_list`: A lista de argumentos passados para uma função.
- `args`: Argumentos individuais de uma função.
- `print_statement`: A instrução `pegaVisao` para imprimir valores.
- `return_statement`: A instrução `sePique` para retornar um valor de uma função.

#### 6. Expressões

- `expression`, `term`, `factor`, `primary_expression`: Regras que definem a hierarquia e a avaliação de expressões aritméticas e lógicas, seguindo a precedência e associatividade dos operadores.
- `literal`: Representa valores literais como números inteiros, flutuantes, caracteres e strings.

### Precedência e Associatividade dos Operadores

O parser define a precedência e associatividade dos operadores para garantir a correta avaliação das expressões. A precedência é definida da menor para a maior:

- **Atribuição**: `T_ASSIGN`, `T_PLUS_ASSIGN`, `T_MINUS_ASSIGN`, `T_MULTIPLY_ASSIGN`, `T_DIVIDE_ASSIGN`, `T_MODULO_ASSIGN` (associatividade à direita)
- **Operadores Bit a Bit**: `T_BITWISE_OR`, `T_BITWISE_XOR`, `T_BITWISE_AND` (associatividade à esquerda)
- **Igualdade e Relacionais**: `T_EQUAL_EQUAL`, `T_NOT_EQUAL`, `T_LESS`, `T_GREATER`, `T_LESS_EQUAL`, `T_GREATER_EQUAL` (associatividade à esquerda)
- **Adição/Subtração**: `T_PLUS`, `T_MINUS` (associatividade à esquerda)
- **Multiplicação/Divisão/Módulo**: `T_MULTIPLY`, `T_DIVIDE`, `T_MODULO` (associatividade à esquerda)
- **Potência**: `T_POWER` (associatividade à direita)
- **Unários**: `T_BITWISE_NOT`, `T_DECREMENT`, `T_INCREMENT` (associatividade à direita)
- **Chamada de Função/Acesso a Array**: `T_LPAREN`, `T_RPAREN`, `T_LBRACKET`, `T_RBRACKET` (associatividade à esquerda)

## Como Compilar e Usar

Para compilar e usar este parser, você precisará ter o GCC, Flex (Lex) e o Bison (Yacc) instalados em seu sistema. Os passos gerais são:

1. **Buildar o analisador_sintatico**: Execute o comando make abaixo a partir da pasta raiz.
    ```bash
    make
    ````
    
2. **Executar o compilador**: Execute o binário gerado, passando o código fonte da linguagem 'Oxe Lang' como entrada.

   ```bash
   ./arvore_sintatica < input/exemplo-input.txt
   ```

Será impresso tanto no terminal como no arquivo `output/output.txt` a árvore sintática;
   
## Exemplo de Código 'Oxe Lang'

```oxe
// Este é um arquivo de exemplo para testar o analisador sintático da linguagem "Oxelang"

barril brocou(): nada {
    pegaVisao("Olá, Mundo!");
}

```
**Saída**:
```bash
 statement_list
 main_function
  body
   type
   block
    statement_list
     print
      string_literal ("Olá, Mundo!")

```
