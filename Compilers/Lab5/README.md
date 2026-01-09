# Lab 5: SLR Parser Implementation

## Step 1: Grammar Representation ✓ (CURRENT)

### What You Have
- **Grammar.kt**: Skeleton class for representing context-free grammars
- **Production.kt**: Data class for production rules (inside Grammar.kt)
- **Example grammars**: 3 test grammars in `grammars/` directory
- **Test inputs**: Sample input files in `inputs/` directory

### What You Need to Implement

#### 1. Grammar.parseGrammarFile() - src/main/kotlin/Grammar.kt:80
**Purpose**: Read and parse a grammar file with **automatic deduction** of terminals/non-terminals.

**NEW Input Format** (Productions only):
```
# Comments allowed (# or //)
E -> E + T
E -> T
T -> T * F
T -> F
F -> ( E )
F -> id
```

**Deduction Rules**:
- **Non-terminal**: Symbol starts with UPPERCASE letter (A-Z)
- **Terminal**: Everything else (operators, keywords, lowercase)
- **Start symbol**: LHS of the FIRST production

**Steps**:
1. Read all lines from file
2. For each line:
   - Trim whitespace
   - Skip if empty or starts with # or //
   - Split by "->" to get LHS and RHS, trim both
   - If first production: set `startSymbol = LHS`
   - Split RHS by whitespace into symbol list
   - Handle epsilon: empty/"epsilon"/"ε" → empty list
3. Classify each symbol:
   - If `symbol[0].isUpperCase()` → add to `nonTerminals`
   - Else (and not epsilon) → add to `terminals`
4. Create Production object and add to list

**Example**: Line "E -> E + T"
- LHS "E" → non-terminal (uppercase), set as start if first
- RHS: "E" → non-terminal, "+" → terminal, "T" → non-terminal

**Test**:
```kotlin
val grammar = Grammar("grammars/g1_simple.txt")
grammar.print()
// Should display all non-terminals, terminals, start symbol, productions
```

#### 2. Production.isEpsilon() - src/main/kotlin/Grammar.kt:155
**Purpose**: Check if production derives empty string.

**Logic**: Return `true` if:
- `rhs.isEmpty()` OR
- `rhs == listOf("epsilon")` OR
- `rhs == listOf("ε")`

**Test**:
```kotlin
Production("S", listOf()).isEpsilon() // true
Production("S", listOf("epsilon")).isEpsilon() // true
Production("S", listOf("a", "b")).isEpsilon() // false
```

#### 3. Grammar.isTerminal() - src/main/kotlin/Grammar.kt:90
**Purpose**: Check if symbol is a terminal.

**Logic**: `return symbol in terminals`

#### 4. Grammar.isNonTerminal() - src/main/kotlin/Grammar.kt:103
**Purpose**: Check if symbol is a non-terminal.

**Logic**: `return symbol in nonTerminals`

#### 5. Grammar.getProductionsFor() - src/main/kotlin/Grammar.kt:122
**Purpose**: Get all productions with specific non-terminal on LHS.

**Logic**: `return productions.filter { it.lhs == nonTerminal }`

#### 6. Grammar.augmentGrammar() - src/main/kotlin/Grammar.kt:142
**Purpose**: Add S' -> S production for LR parsing.

**Steps**:
1. Create new start symbol: `val newStart = startSymbol + "'"`
2. Add to non-terminals: `nonTerminals.add(newStart)`
3. Create augmented production: `Production(newStart, listOf(startSymbol))`
4. Insert at beginning: `productions.add(0, augmentedProduction)`
5. Update start: `startSymbol = newStart`

### Testing Step 1

Create a simple test in Main.kt:
```kotlin
fun main() {
    // Test grammar loading
    val grammar = Grammar("grammars/g2_arithmetic.txt")
    grammar.print()

    // Test production filtering
    println("\nProductions for E:")
    grammar.getProductionsFor("E").forEach { println(it) }

    // Test augmentation
    grammar.augmentGrammar()
    println("\nAugmented grammar:")
    grammar.print()
}
```

Run with: `./gradlew run`

---

## Step 2: FIRST Sets (Coming Next)

After completing Step 1, we'll implement:
- `FirstSets.kt`: Class for computing FIRST sets
- Non-recursive algorithm using worklist/fixed-point iteration
- Handle epsilon productions correctly

---

## Step 3: FOLLOW Sets (Coming Next)

---

## Step 4: LR(0) Items & Canonical Collection (Coming Next)

---

## Step 5: SLR Table Construction (Coming Next)

---

## Step 6: Parser Engine (Coming Next)

---

## Step 7: Integration & Testing (Coming Next)

---

## Building and Running

```bash
# Build project
./gradlew build

# Run
./gradlew run --args="grammars/g2_arithmetic.txt inputs/test2_arithmetic.txt"

# Or with specific mode
./gradlew run --args="--check-slr grammars/g2_arithmetic.txt"
./gradlew run --args="--first-follow grammars/g2_arithmetic.txt"
```

## Project Structure
```
Lab5/
├── build.gradle.kts           # Gradle build configuration
├── settings.gradle.kts        # Project settings
├── src/
│   └── main/
│       └── kotlin/
│           ├── Main.kt        # Entry point
│           ├── Grammar.kt     # Grammar representation (CURRENT)
│           ├── FirstSets.kt   # FIRST computation (TODO)
│           ├── FollowSets.kt  # FOLLOW computation (TODO)
│           ├── LRItems.kt     # LR(0) items (TODO)
│           ├── SLRTable.kt    # Parsing tables (TODO)
│           └── Parser.kt      # Parser engine (TODO)
├── grammars/                  # Test grammars
│   ├── g1_simple.txt
│   ├── g2_arithmetic.txt
│   └── g3_with_epsilon.txt
├── inputs/                    # Test inputs
│   ├── test1_simple.txt
│   └── test2_arithmetic.txt
└── outputs/                   # Parse results (generated)
```

## Tips for Implementation

1. **Test incrementally**: Implement one function, test it, move to next
2. **Use print statements**: Add debugging output to understand what's happening
3. **Start simple**: Test with g1_simple.txt before g2_arithmetic.txt
4. **Read the comments**: Each TODO has detailed algorithm steps
5. **Ask questions**: If any step is unclear, ask for clarification

## Next Steps

After completing Step 1:
1. Test all Grammar functions thoroughly
2. Verify with all 3 test grammars
3. Signal when ready for Step 2 (FIRST sets)
