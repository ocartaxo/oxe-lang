# Nome do compilador C
CC = gcc

# Flags do compilador C (W_all para todos os warnings, -g para informações de debug)
CFLAGS = -Wall -g

# Nome do Flex
FLEX = flex

# Bibliotecas a serem lincadas (a biblioteca do Flex é -lfl ou -ll)
# -lfl é mais comum em sistemas Linux modernos.
LDLIBS = -ll

# Bison
BISON = bison
BISON_FLG = -d -y

# Nome do seu arquivo fonte .l
SCANNER = lexer/scanner.l 
# Nome do arquivo fonte .y
PARSER = parser/parser.y

# Nome do arquivo C gerado pelo Flex (padrão é lex.yy.c)
FLEX_SRC = lex.yy.c
# Nome do arquivo C gerado pelo Bison
BISON_SRC = parser.tab.c

# Nome do executável final
TARGET_LEXER = lexer

TARGET_PARSER = gramma

TARGET = arvore_sintatica

# Alvo padrão: o que é construído quando você apenas digita "make"
all: $(TARGET)

# Regra para criar o executável final a partir do arquivo C gerado
# Ele depende do arquivo FLEX_SRC
$(TARGET): $(BINSON_SRC) $(FLEX_SRC)
	@$(CC) $(CFLAGS) -o $(TARGET) $(FLEX_SRC) $(LDLIBS)
	@rm $(FLEX_SRC)

$(BISON_SRC): $(PARSER)
	@$(BISON) $(BISON_FLG) $(BISON_SRC)


# Regra para criar o arquivo FLEX_SRC a partir do arquivo LEX_SRC
# Ele depende do seu arquivo .l
$(FLEX_SRC): $(SCANNER)
	 @$(FLEX) $(LDLIBS) $(LEX_SRC)


# Alvo "clean" para remover arquivos gerados
clean:
	@rm -f $(TARGET) $(FLEX_SRC) *.o

# Declarar alvos que não são nomes de arquivos
.PHONY: all clean
