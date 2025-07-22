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
BISON_FLG = -d

# Nome do seu arquivo fonte .l
SCANNER = lexer/scanner.l 
# Nome do arquivo fonte .y
PARSER = parser/parser.y

# Nome do arquivo C gerado pelo Flex (padrão é lex.yy.c)
TARGET_LEXER = lex.yy.c
# Nome do arquivo C gerado pelo Bison
TARGET_PARSER = parser.tab.c

TARGET = arvore_sintatica

# Alvo padrão: o que é construído quando você apenas digita "make"
all: $(TARGET)

# Regra para criar o executável final a partir do arquivo C gerado
# Ele depende do arquivo TARGET_LEXER
$(TARGET): $(TARGET_PARSER) $(TARGET_LEXER)
	@$(CC) $(CFLAGS) -o $(TARGET) $(TARGET_PARSER) $(TARGET_LEXER) $(LDLIBS)
	@rm $(TARGET_LEXER)

$(TARGET_PARSER): $(PARSER)
	@$(BISON) $(BISON_FLG) $(PARSER)


# Regra para criar o arquivo TARGET_LEXER a partir do arquivo LEX_SRC
# Ele depende do seu arquivo .l
$(TARGET_LEXER): $(SCANNER)
	 @$(FLEX) $(LDLIBS) $(SCANNER)


# Alvo "clean" para remover arquivos gerados
clean:
	@rm -f $(TARGET) $(TARGET_LEXER) $(TARGET_PARSER) *.h *.o
	
# Declarar alvos que não são nomes de arquivos
.PHONY: all clean
