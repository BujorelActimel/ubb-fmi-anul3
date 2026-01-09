# Grammar Files

This directory contains test grammars for the SLR parser.

## Grammar File Format

```
N: <non-terminals separated by spaces>
T: <terminals separated by spaces>
S: <start symbol>
P:
<production 1>
<production 2>
...
```

### Production Format
- Left side and right side separated by `->`
- Right side symbols separated by spaces
- Epsilon productions: use `epsilon` or `ε` or leave empty after `->`

### Example
```
N: E T F
T: + * id
S: E
P:
E -> E + T
E -> T
T -> id
```

## Test Grammars

1. **g1_simple.txt** - Simple balanced grammar (a^n b^n)
   - Good for basic testing
   - Small number of productions

2. **g2_arithmetic.txt** - Arithmetic expressions
   - Classic expression grammar with operator precedence
   - Tests shift/reduce conflict resolution

3. **g3_with_epsilon.txt** - Grammar with epsilon productions
   - Tests FIRST/FOLLOW with nullable non-terminals
   - Important for epsilon handling

## Adding New Grammars

When creating test grammars:
1. Start simple and test thoroughly
2. Verify the grammar is SLR (no conflicts)
3. Create corresponding test input files in `inputs/` directory
4. Document expected output in comments
