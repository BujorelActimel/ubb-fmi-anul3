CC = gcc
CFLAGS = -Wall -g
LEX = flex
YACC = bison

TARGET = parser
LEX_SOURCE = lexer.l
YACC_SOURCE = parser.y
LEX_OUTPUT = lex.yy.c
YACC_OUTPUT = parser.tab.c
YACC_HEADER = parser.tab.h

all: $(TARGET)

$(TARGET): $(LEX_SOURCE) $(YACC_SOURCE)
	$(YACC) -d -v $(YACC_SOURCE)
	$(LEX) $(LEX_SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(YACC_OUTPUT) $(LEX_OUTPUT)

clean:
	rm -f $(TARGET) $(LEX_OUTPUT) $(YACC_OUTPUT) $(YACC_HEADER) parser.output
	rm -f output/*.txt

check-conflicts:
	@echo "Checking for conflicts"
	@if [ -f parser.output ]; then \
		echo "=== Parser State Machine ==="; \
		grep -A 5 "conflicts:" parser.output || echo "No conflicts found!"; \
	else \
		echo "Run 'make' first to generate parser.output"; \
	fi

.PHONY: all clean check-conflicts
