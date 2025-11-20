CC = gcc
CFLAGS = -Wall -g
LEX = flex

TARGET = lexer
LEX_SOURCE = lexer.l
LEX_OUTPUT = lex.yy.c
SOURCES = symboltable.c
OBJECTS = $(SOURCES:.c=.o)

all: $(TARGET)

$(TARGET): $(LEX_SOURCE) $(OBJECTS)
	$(LEX) $(LEX_SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(LEX_OUTPUT) $(OBJECTS) -lfl

symboltable.o: symboltable.c symboltable.h
	$(CC) $(CFLAGS) -c symboltable.c

clean:
	rm -f $(TARGET) $(LEX_OUTPUT) $(OBJECTS)
	rm -f output/*.csv

.PHONY: all clean
