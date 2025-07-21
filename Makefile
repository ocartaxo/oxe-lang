# Nome do compilador C
CC = gcc

# Flags do compilador C (W_all para todos os warnings, -g para informações de debug)
CFLAGS = -Wall -g

# Nome do Flex
LEX = flex

# Bibliotecas a serem lincadas (a biblioteca do Flex é -lfl ou -ll)
# -lfl é mais comum em sistemas Linux modernos.
LDLIBS = -ll

# Nome do seu arquivo fonte .l
LEX_SRC = lexer/scanner.l 
# Nome do arquivo fonte .y
SIN_SRC = parser/parser.y

# Nome do arquivo C gerado pelo Flex (padrão é lex.yy.c)
C_SRC = lex.yy.c

# Nome do executável final
TARGET = lexer

# Alvo padrão: o que é construído quando você apenas digita "make"
all: $(TARGET)

# Regra para criar o executável final a partir do arquivo C gerado
# Ele depende do arquivo C_SRC
$(TARGET): $(C_SRC)
	@$(CC) $(CFLAGS) -o $(TARGET) $(C_SRC) $(LDLIBS)
	@rm $(C_SRC)

# Regra para criar o arquivo C_SRC a partir do arquivo LEX_SRC
# Ele depende do seu arquivo .l
$(C_SRC): $(LEX_SRC)
	 @$(LEX) $(LDLIBS) $(LEX_SRC)


# Alvo "clean" para remover arquivos gerados
clean:
	@rm -f $(TARGET) $(C_SRC) *.o

# Declarar alvos que não são nomes de arquivos
.PHONY: all clean
