# Mini-Go Compiler Makefile
# Lab 6 - Compilers Course

# Compiler and tools
CC = gcc
CFLAGS = -Wall -Wextra -g -std=c11 -Isrc
FLEX = flex
BISON = bison
BISON_FLAGS = -d -v
NASM = nasm
NASM_FLAGS = -f elf64
LD = ld

# Directories
SRC_DIR = src
BUILD_DIR = build
TEST_DIR = tests
OUTPUT_DIR = output

# Source files
LEX_SRC = $(SRC_DIR)/lexer.l
YACC_SRC = $(SRC_DIR)/parser.y

# C source files (will be added as we implement)
C_SRCS = $(wildcard $(SRC_DIR)/*.c)
C_OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(C_SRCS))

# Generated files
LEX_C = $(BUILD_DIR)/lex.yy.c
YACC_C = $(BUILD_DIR)/parser.tab.c
YACC_H = $(BUILD_DIR)/parser.tab.h
YACC_OUTPUT = $(BUILD_DIR)/parser.output

# Compiler binary
TARGET = $(BUILD_DIR)/minigo

.PHONY: all clean test check-conflicts help dirs

# Default target
all: dirs $(TARGET)

# Create necessary directories
dirs:
	@mkdir -p $(BUILD_DIR) $(OUTPUT_DIR)

# Generate lexer
$(LEX_C): $(LEX_SRC) | dirs
	@echo "Generating lexer..."
	$(FLEX) -o $@ $<

# Generate parser
$(YACC_C) $(YACC_H) $(YACC_OUTPUT): $(YACC_SRC) | dirs
	@echo "Generating parser..."
	$(BISON) $(BISON_FLAGS) -o $(YACC_C) $<

# Compile C source files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c $(YACC_H) | dirs
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -I$(BUILD_DIR) -c $< -o $@

# Compile generated lexer
$(BUILD_DIR)/lex.yy.o: $(LEX_C) $(YACC_H) | dirs
	@echo "Compiling lexer..."
	$(CC) $(CFLAGS) -I$(BUILD_DIR) -Wno-unused-function -c $< -o $@

# Compile generated parser
$(BUILD_DIR)/parser.tab.o: $(YACC_C) $(YACC_H) | dirs
	@echo "Compiling parser..."
	$(CC) $(CFLAGS) -I$(BUILD_DIR) -c $< -o $@

# Link compiler
$(TARGET): $(BUILD_DIR)/lex.yy.o $(BUILD_DIR)/parser.tab.o $(C_OBJS)
	@echo "Linking compiler..."
	$(CC) $(CFLAGS) $^ -o $@
	@echo "Compiler built successfully: $(TARGET)"

# Check for grammar conflicts
check-conflicts: $(YACC_OUTPUT)
	@echo "Checking for grammar conflicts..."
	@if grep -q "conflict" $(YACC_OUTPUT); then \
		echo "❌ ERROR: Grammar has conflicts!"; \
		grep "conflict" $(YACC_OUTPUT); \
		exit 1; \
	else \
		echo "✓ SUCCESS: Grammar is conflict-free!"; \
	fi

# View parser output (for debugging)
grammar: $(YACC_OUTPUT)
	@cat $(YACC_OUTPUT)

# Run tests
test: $(TARGET)
	@echo "Running test suite..."
	@bash $(TEST_DIR)/test_runner.sh

# Compare with Go compiler
compare: $(TARGET)
	@echo "Comparing with Go compiler..."
	@bash $(TEST_DIR)/compare_with_go.sh

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR) $(OUTPUT_DIR)
	@rm -f $(TEST_DIR)/*.asm $(TEST_DIR)/*.o $(TEST_DIR)/*.out
	@echo "Clean complete."

# Clean everything including generated sources
distclean: clean
	@rm -f $(SRC_DIR)/lex.yy.c $(SRC_DIR)/parser.tab.* $(SRC_DIR)/parser.output
	@echo "Deep clean complete."

# Help target
help:
	@echo "Mini-Go Compiler Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all              Build the compiler (default)"
	@echo "  clean            Remove build artifacts"
	@echo "  distclean        Remove all generated files"
	@echo "  check-conflicts  Verify grammar is conflict-free"
	@echo "  grammar          Display parser state machine"
	@echo "  test             Run test suite"
	@echo "  compare          Compare output with Go compiler"
	@echo "  help             Show this help message"
	@echo ""
	@echo "Usage:"
	@echo "  make             # Build compiler"
	@echo "  make test        # Run tests"
	@echo "  make clean       # Clean build"
