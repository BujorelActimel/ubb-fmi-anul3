#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "codegen_x86.h"

extern FILE *yyin;
extern int yyparse();
extern ASTNode *root;
extern int error_count;

typedef struct {
    int dump_ast;
    char *output_file;
    char *input_file;
} CompilerOptions;

void print_usage(const char *program_name) {
    printf("Usage: %s [options] <input.go>\n", program_name);
    printf("\nOptions:\n");
    printf("  --dump-ast           Print AST after parsing\n");
    printf("  -o FILE              Output file (default: stdout)\n");
    printf("  -h, --help           Show this help message\n");
    printf("\nExamples:\n");
    printf("  %s test.go -o test.s\n", program_name);
    printf("  %s --dump-ast test.go\n", program_name);
}

void parse_arguments(int argc, char *argv[], CompilerOptions *options) {
    memset(options, 0, sizeof(CompilerOptions));
    options->output_file = NULL;
    options->input_file = NULL;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--dump-ast") == 0) {
            options->dump_ast = 1;
        } else if (strcmp(argv[i], "-o") == 0) {
            if (i + 1 < argc) {
                options->output_file = argv[++i];
            } else {
                fprintf(stderr, "Error: -o requires an output file name\n");
                exit(1);
            }
        } else if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            print_usage(argv[0]);
            exit(0);
        } else if (argv[i][0] != '-') {
            if (options->input_file == NULL) {
                options->input_file = argv[i];
            } else {
                fprintf(stderr, "Error: Multiple input files specified\n");
                exit(1);
            }
        } else {
            fprintf(stderr, "Error: Unknown option '%s'\n", argv[i]);
            print_usage(argv[0]);
            exit(1);
        }
    }

    if (options->input_file == NULL) {
        fprintf(stderr, "Error: No input file specified\n");
        print_usage(argv[0]);
        exit(1);
    }
}

int main(int argc, char *argv[]) {
    CompilerOptions options;
    parse_arguments(argc, argv, &options);

    FILE *input = fopen(options.input_file, "r");
    if (!input) {
        fprintf(stderr, "Error: Could not open file '%s'\n", options.input_file);
        return 1;
    }

    yyin = input;

    int parse_result = yyparse();

    fclose(input);

    if (parse_result != 0 || error_count > 0) {
        fprintf(stderr, "Parsing failed with %d error(s)\n", error_count);
        return 1;
    }

    if (options.dump_ast && root) {
        printf("\n========== AST ==========\n");
        print_ast(root, 0);
        printf("=========================\n\n");
    }

    FILE *output = stdout;
    if (options.output_file) {
        output = fopen(options.output_file, "w");
        if (!output) {
            fprintf(stderr, "Error: Could not open output file '%s'\n", options.output_file);
            return 1;
        }
    }

    generate_x86_code(root, output);

    if (options.output_file) {
        fclose(output);
        printf("Assembly written to %s\n", options.output_file);
    }

    if (root) {
        free_ast(root);
    }

    return 0;
}
