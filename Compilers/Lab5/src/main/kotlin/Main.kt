/**
 * Main entry point for the SLR Parser implementation.
 *
 * This program implements an SLR (Simple LR) parser for syntax analysis.
 * It can:
 * 1. Parse an input sequence using a given CFG
 * 2. Verify if a grammar is SLR
 * 3. Generate parse trees or production sequences
 */

fun main(args: Array<String>) {
    println("=== SLR Parser - Tema 5 ===\n")

    // If no arguments, run Step 1 tests
    if (args.isEmpty()) {
        runStep1Tests()
        return
    }

    // Command-line mode selection
    when {
        args[0] == "--test-step1" -> {
            runStep1Tests()
        }
        args[0] == "--test-step2" -> {
            runStep2Tests()
        }
        args[0] == "--check-slr" -> {
            // TODO: Check if grammar is SLR
            // checkIfSLR(args[1])
        }
        args[0] == "--first-follow" -> {
            if (args.size >= 2) {
                showFirstFollow(args[1])
            } else {
                println("Error: Missing grammar file argument")
                printUsage()
            }
        }
        args.size >= 2 -> {
            // TODO: Parse input sequence
            // parseInput(args[0], args[1])
        }
        else -> {
            printUsage()
        }
    }
}

/**
 * Step 1: Test Grammar class implementation
 */
fun runStep1Tests() {
    println("╔═══════════════════════════════════════════╗")
    println("║   STEP 1: Grammar Implementation Tests   ║")
    println("╚═══════════════════════════════════════════╝\n")

    var passedTests = 0
    var totalTests = 0

    // Test 1: Simple grammar (g1)
    println("━━━ Test 1: Simple Grammar (a^n b^n) ━━━")
    totalTests++
    try {
        val g1 = Grammar("grammars/g1_simple.txt")
        g1.print()

        // Verify deduction
        println("✓ Verification:")
        println("  Non-terminals: ${g1.nonTerminals}")
        println("  Terminals: ${g1.terminals}")
        println("  Start symbol: ${g1.startSymbol}")

        // Test symbol classification
        assert(g1.isNonTerminal("S")) { "S should be non-terminal" }
        assert(g1.isTerminal("a")) { "a should be terminal" }
        assert(g1.isTerminal("b")) { "b should be terminal" }
        assert(!g1.isTerminal("S")) { "S should NOT be terminal" }
        assert(!g1.isNonTerminal("a")) { "a should NOT be non-terminal" }
        println("  ✓ Symbol classification works correctly")

        // Test getProductionsFor
        val sProductions = g1.getProductionsFor("S")
        println("  Productions for S: ${sProductions.size}")
        sProductions.forEach { println("    - $it") }
        assert(sProductions.size == 2) { "S should have 2 productions" }
        println("  ✓ getProductionsFor() works correctly")

        println("✅ Test 1 PASSED\n")
        passedTests++
    } catch (e: Exception) {
        println("❌ Test 1 FAILED: ${e.message}\n")
        e.printStackTrace()
    }

    // Test 2: Arithmetic expression grammar (g2)
    println("━━━ Test 2: Arithmetic Expression Grammar ━━━")
    totalTests++
    try {
        val g2 = Grammar("grammars/g2_arithmetic.txt")
        g2.print()

        // Verify correct classification
        val expectedNonTerminals = setOf("E", "T", "F")
        val expectedTerminals = setOf("+", "*", "(", ")", "id")

        println("✓ Verification:")
        println("  Expected non-terminals: $expectedNonTerminals")
        println("  Found non-terminals: ${g2.nonTerminals}")
        println("  Expected terminals: $expectedTerminals")
        println("  Found terminals: ${g2.terminals}")

        assert(g2.nonTerminals == expectedNonTerminals) {
            "Non-terminals mismatch! Expected $expectedNonTerminals, got ${g2.nonTerminals}"
        }
        assert(g2.terminals == expectedTerminals) {
            "Terminals mismatch! Expected $expectedTerminals, got ${g2.terminals}"
        }
        assert(g2.startSymbol == "E") { "Start symbol should be E" }

        println("  ✓ All symbols classified correctly")

        // Test each non-terminal's productions
        println("\n  Productions by non-terminal:")
        for (nt in expectedNonTerminals.sorted()) {
            val prods = g2.getProductionsFor(nt)
            println("    $nt: ${prods.size} production(s)")
            prods.forEach { println("      - $it") }
        }

        // Test terminal checks
        assert(g2.isTerminal("+")) { "+ should be terminal" }
        assert(g2.isNonTerminal("E")) { "E should be non-terminal" }
        assert(!g2.isTerminal("E")) { "E should NOT be terminal" }

        println("\n✅ Test 2 PASSED\n")
        passedTests++
    } catch (e: Exception) {
        println("❌ Test 2 FAILED: ${e.message}\n")
        e.printStackTrace()
    }

    // Test 3: Grammar with epsilon productions (g3)
    println("━━━ Test 3: Grammar with Epsilon Productions ━━━")
    totalTests++
    try {
        val g3 = Grammar("grammars/g3_with_epsilon.txt")
        g3.print()

        // Find and verify epsilon productions
        val epsilonProductions = g3.productions.filter { it.isEpsilon() }
        println("✓ Epsilon productions found: ${epsilonProductions.size}")
        epsilonProductions.forEach { println("  - $it") }

        assert(epsilonProductions.size == 2) {
            "Should have 2 epsilon productions, found ${epsilonProductions.size}"
        }

        // Verify specific epsilon productions
        val aProductions = g3.getProductionsFor("A")
        val bProductions = g3.getProductionsFor("B")
        val aEpsilon = aProductions.any { it.isEpsilon() }
        val bEpsilon = bProductions.any { it.isEpsilon() }

        assert(aEpsilon) { "A should have epsilon production" }
        assert(bEpsilon) { "B should have epsilon production" }
        println("  ✓ Epsilon productions detected correctly")

        // Verify non-epsilon productions
        val nonEpsilonProds = g3.productions.filter { !it.isEpsilon() }
        println("  Non-epsilon productions: ${nonEpsilonProds.size}")
        nonEpsilonProds.forEach { println("    - $it") }

        println("✅ Test 3 PASSED\n")
        passedTests++
    } catch (e: Exception) {
        println("❌ Test 3 FAILED: ${e.message}\n")
        e.printStackTrace()
    }

    // Test 4: Grammar augmentation
    println("━━━ Test 4: Grammar Augmentation ━━━")
    totalTests++
    try {
        val g4 = Grammar("grammars/g2_arithmetic.txt")
        println("Before augmentation:")
        println("  Start symbol: ${g4.startSymbol}")
        println("  Productions: ${g4.productions.size}")
        println("  First production: ${g4.productions[0]}")
        println("  Non-terminals: ${g4.nonTerminals}")

        g4.augmentGrammar()

        println("\nAfter augmentation:")
        println("  Start symbol: ${g4.startSymbol}")
        println("  Productions: ${g4.productions.size}")
        println("  First production: ${g4.productions[0]}")
        println("  Non-terminals: ${g4.nonTerminals}")

        // Verify augmentation
        assert(g4.startSymbol == "E'") { "Start symbol should be E', got ${g4.startSymbol}" }
        assert(g4.productions[0].lhs == "E'") { "First production LHS should be E'" }
        assert(g4.productions[0].rhs == listOf("E")) { "Augmented production RHS should be [E]" }
        assert(g4.isNonTerminal("E'")) { "E' should be recognized as non-terminal" }
        assert(!g4.isTerminal("E'")) { "E' should NOT be terminal" }

        // Verify original productions still exist
        val eProds = g4.getProductionsFor("E")
        assert(eProds.isNotEmpty()) { "Original E productions should still exist" }

        println("\n  ✓ Grammar augmented correctly")
        println("  ✓ Augmented start symbol recognized as non-terminal")
        println("✅ Test 4 PASSED\n")
        passedTests++
    } catch (e: Exception) {
        println("❌ Test 4 FAILED: ${e.message}\n")
        e.printStackTrace()
    }

    // Test 5: Edge cases
    println("━━━ Test 5: Edge Cases ━━━")
    totalTests++
    try {
        val g5 = Grammar("grammars/g1_simple.txt")

        // Test with non-existent non-terminal
        val emptyProds = g5.getProductionsFor("X")
        assert(emptyProds.isEmpty()) { "Non-existent non-terminal should return empty list" }
        println("  ✓ getProductionsFor() handles non-existent non-terminal")

        // Test symbol classification with invalid symbols
        assert(!g5.isTerminal("INVALID")) { "Unknown symbol should not be terminal" }
        assert(!g5.isNonTerminal("invalid")) { "Unknown symbol should not be non-terminal" }
        println("  ✓ Symbol classification handles unknown symbols")

        // Test that all productions have valid LHS
        g5.productions.forEach { prod ->
            assert(g5.isNonTerminal(prod.lhs)) {
                "Production LHS ${prod.lhs} should be a non-terminal"
            }
        }
        println("  ✓ All production LHS are non-terminals")

        // Test that start symbol is a non-terminal
        assert(g5.isNonTerminal(g5.startSymbol)) {
            "Start symbol should be a non-terminal"
        }
        println("  ✓ Start symbol is a non-terminal")

        println("✅ Test 5 PASSED\n")
        passedTests++
    } catch (e: Exception) {
        println("❌ Test 5 FAILED: ${e.message}\n")
        e.printStackTrace()
    }

    // Summary
    println("╔═══════════════════════════════════════════╗")
    println("║          Step 1 Testing Complete          ║")
    println("╚═══════════════════════════════════════════╝")
    println("\nResults: $passedTests/$totalTests tests passed")

    if (passedTests == totalTests) {
        println("\n🎉 Congratulations! All tests passed!")
        println("✅ Step 1 is complete and working correctly.")
        println("\n📚 You're ready for Step 2: FIRST sets computation")
        println("   Run: ./gradlew run --args=\"--help\" for next steps")
    } else {
        println("\n⚠️  Some tests failed. Please fix the issues above.")
        println("💡 Review Grammar.kt implementation")
    }
    println()
}

/**
 * TODO: Parse an input sequence using the given grammar.
 *
 * Purpose: Main parsing functionality - read grammar and input, build parser,
 * and parse the input sequence.
 *
 * Algorithm:
 * 1. Load grammar from file
 * 2. Augment the grammar (add S' -> S)
 * 3. Build SLR parser tables (Action and Goto)
 * 4. Read input sequence from file
 * 5. Parse the input using the SLR algorithm
 * 6. Output:
 *    - Parse tree (derivation tree)
 *    - OR sequence of productions used
 *    - OR error message if input is rejected
 *
 * @param grammarFile Path to grammar file
 * @param inputFile Path to input sequence file
 *
 * Example output for valid input:
 * ```
 * Input: id + id * id
 * Status: ACCEPTED
 *
 * Productions used:
 * 1. E -> E + T
 * 2. E -> T
 * 3. T -> T * F
 * 4. T -> F
 * 5. F -> id
 * ```
 *
 * Example output for invalid input:
 * ```
 * Input: id + + id
 * Status: REJECTED
 * Error: Unexpected token '+' at position 2
 * ```
 */
fun parseInput(grammarFile: String, inputFile: String) {
    // TODO: Implement parsing functionality
    println("Parsing input file: $inputFile")
    println("Using grammar: $grammarFile")

    // Step 1: Load and parse grammar
    // val grammar = Grammar(grammarFile)
    // grammar.print()

    // Step 2: Augment grammar
    // grammar.augmentGrammar()

    // Step 3: Compute FIRST and FOLLOW sets
    // val firstSets = computeFirst(grammar)
    // val followSets = computeFollow(grammar, firstSets)

    // Step 4: Build LR(0) canonical collection
    // val items = buildCanonicalCollection(grammar)

    // Step 5: Build SLR parsing tables
    // val parsingTable = buildSLRTable(grammar, items, followSets)

    // Step 6: Check if grammar is SLR (no conflicts)
    // if (!parsingTable.isSLR()) {
    //     println("ERROR: Grammar is not SLR!")
    //     parsingTable.printConflicts()
    //     return
    // }

    // Step 7: Read input sequence
    // val input = readInput(inputFile)

    // Step 8: Parse the input
    // val result = parse(grammar, parsingTable, input)

    // Step 9: Display results
    // result.print()
}

/**
 * TODO: Check if a grammar is SLR.
 *
 * Purpose: Verify whether a given grammar satisfies SLR conditions.
 * A grammar is SLR if there are no shift-reduce or reduce-reduce conflicts
 * when building the SLR parsing table.
 *
 * Algorithm:
 * 1. Load grammar
 * 2. Augment grammar
 * 3. Compute FIRST and FOLLOW sets
 * 4. Build canonical LR(0) collection
 * 5. Attempt to build SLR table
 * 6. Check for conflicts:
 *    - Shift-reduce conflict: when same state has both shift and reduce actions for same terminal
 *    - Reduce-reduce conflict: when same state has multiple reduce actions for same terminal
 * 7. Report results
 *
 * @param grammarFile Path to grammar file
 *
 * Output format:
 * ```
 * Grammar: g2_arithmetic.txt
 * Status: SLR ✓
 *
 * FIRST sets: ...
 * FOLLOW sets: ...
 * Number of states: 12
 * ```
 *
 * Or if not SLR:
 * ```
 * Grammar: bad_grammar.txt
 * Status: NOT SLR ✗
 *
 * Conflicts found:
 * State 5: Shift-reduce conflict on terminal '+'
 *   - Shift to state 7
 *   - Reduce by production E -> T
 * ```
 */
fun checkIfSLR(grammarFile: String) {
    // TODO: Implement SLR checking
    println("Checking if grammar is SLR: $grammarFile")

    // TODO: Load grammar, build parser, check for conflicts
}

/**
 * TODO: Compute and display FIRST and FOLLOW sets for the grammar.
 *
 * Purpose: Show the computed FIRST and FOLLOW sets for each non-terminal.
 * Useful for understanding the grammar and debugging parser issues.
 *
 * Algorithm:
 * 1. Load grammar
 * 2. Compute FIRST sets for all non-terminals
 * 3. Compute FOLLOW sets for all non-terminals
 * 4. Display in readable format
 *
 * @param grammarFile Path to grammar file
 *
 * Output format:
 * ```
 * FIRST sets:
 * E: { (, id }
 * T: { (, id }
 * F: { (, id }
 *
 * FOLLOW sets:
 * E: { $, +, ) }
 * T: { $, +, *, ) }
 * F: { $, +, *, ) }
 * ```
 */
fun showFirstFollow(grammarFile: String) {
    println("=== Computing FIRST and FOLLOW Sets ===\n")
    println("Grammar file: $grammarFile\n")

    try {
        val grammar = Grammar(grammarFile)
        grammar.print()

        // Compute FIRST sets
        val firstSets = FirstSets(grammar)
        firstSets.print()

        // TODO: Step 3 - Compute FOLLOW sets
        // val followSets = FollowSets(grammar, firstSets)
        // followSets.print()
    } catch (e: Exception) {
        println("Error: ${e.message}")
        e.printStackTrace()
    }
}

/**
 * Step 2: Test FIRST sets implementation
 */
fun runStep2Tests() {
    println("╔═══════════════════════════════════════════╗")
    println("║   STEP 2: FIRST Sets Implementation Tests║")
    println("╚═══════════════════════════════════════════╝\n")

    var passedTests = 0
    var totalTests = 0

    // Test 1: Simple grammar without epsilon
    println("━━━ Test 1: Arithmetic Grammar (No Epsilon) ━━━")
    totalTests++
    try {
        val g1 = Grammar("grammars/g2_arithmetic.txt")
        val firstSets = FirstSets(g1)

        println("Grammar:")
        g1.print()
        println("FIRST Sets:")
        firstSets.print()

        // Verify FIRST sets
        val expectedFirstE = setOf("(", "id")
        val expectedFirstT = setOf("(", "id")
        val expectedFirstF = setOf("(", "id")

        val actualFirstE = firstSets.getFirst("E")
        val actualFirstT = firstSets.getFirst("T")
        val actualFirstF = firstSets.getFirst("F")

        println("✓ Verification:")
        println("  Expected FIRST(E) = $expectedFirstE")
        println("  Actual FIRST(E) = $actualFirstE")
        assert(actualFirstE == expectedFirstE) {
            "FIRST(E) mismatch! Expected $expectedFirstE, got $actualFirstE"
        }

        println("  Expected FIRST(T) = $expectedFirstT")
        println("  Actual FIRST(T) = $actualFirstT")
        assert(actualFirstT == expectedFirstT) {
            "FIRST(T) mismatch! Expected $expectedFirstT, got $actualFirstT"
        }

        println("  Expected FIRST(F) = $expectedFirstF")
        println("  Actual FIRST(F) = $actualFirstF")
        assert(actualFirstF == expectedFirstF) {
            "FIRST(F) mismatch! Expected $expectedFirstF, got $actualFirstF"
        }

        // Test terminals
        assert(firstSets.getFirst("+") == setOf("+")) { "FIRST(+) should be {+}" }
        assert(firstSets.getFirst("id") == setOf("id")) { "FIRST(id) should be {id}" }

        // Test epsilon derivation
        assert(!firstSets.canDeriveEpsilon("E")) { "E should not derive epsilon" }
        assert(!firstSets.canDeriveEpsilon("T")) { "T should not derive epsilon" }

        println("  ✓ All FIRST sets correct")
        println("  ✓ Epsilon derivation correct")
        println("✅ Test 1 PASSED\n")
        passedTests++
    } catch (e: Exception) {
        println("❌ Test 1 FAILED: ${e.message}\n")
        e.printStackTrace()
    }

    // Test 2: Grammar with epsilon productions
    println("━━━ Test 2: Grammar with Epsilon Productions ━━━")
    totalTests++
    try {
        val g2 = Grammar("grammars/g3_with_epsilon.txt")
        val firstSets = FirstSets(g2)

        println("Grammar:")
        g2.print()
        println("FIRST Sets:")
        firstSets.print()

        // Verify FIRST sets with epsilon
        val expectedFirstS = setOf("a", "b", "c")
        val expectedFirstA = setOf("a", "ε")
        val expectedFirstB = setOf("b", "ε")

        val actualFirstS = firstSets.getFirst("S")
        val actualFirstA = firstSets.getFirst("A")
        val actualFirstB = firstSets.getFirst("B")

        println("✓ Verification:")
        println("  Expected FIRST(S) = $expectedFirstS")
        println("  Actual FIRST(S) = $actualFirstS")
        assert(actualFirstS == expectedFirstS) {
            "FIRST(S) mismatch! Expected $expectedFirstS, got $actualFirstS"
        }

        println("  Expected FIRST(A) = $expectedFirstA")
        println("  Actual FIRST(A) = $actualFirstA")
        assert(actualFirstA == expectedFirstA) {
            "FIRST(A) mismatch! Expected $expectedFirstA, got $actualFirstA"
        }

        println("  Expected FIRST(B) = $expectedFirstB")
        println("  Actual FIRST(B) = $actualFirstB")
        assert(actualFirstB == expectedFirstB) {
            "FIRST(B) mismatch! Expected $expectedFirstB, got $actualFirstB"
        }

        // Test epsilon derivation
        assert(firstSets.canDeriveEpsilon("A")) { "A should derive epsilon" }
        assert(firstSets.canDeriveEpsilon("B")) { "B should derive epsilon" }
        assert(!firstSets.canDeriveEpsilon("S")) { "S should not derive epsilon" }

        println("  ✓ All FIRST sets with epsilon correct")
        println("  ✓ Epsilon derivation detection correct")
        println("✅ Test 2 PASSED\n")
        passedTests++
    } catch (e: Exception) {
        println("❌ Test 2 FAILED: ${e.message}\n")
        e.printStackTrace()
    }

    // Test 3: FIRST of string sequences
    println("━━━ Test 3: FIRST of String Sequences ━━━")
    totalTests++
    try {
        val g3 = Grammar("grammars/g3_with_epsilon.txt")
        val firstSets = FirstSets(g3)

        println("Testing firstOfString()...")

        // Test: FIRST(A B c)
        val seq1 = listOf("A", "B", "c")
        val result1 = firstSets.firstOfString(seq1)
        val expected1 = setOf("a", "b", "c")
        println("  FIRST(A B c) = $result1")
        println("  Expected: $expected1")
        assert(result1 == expected1) {
            "FIRST(A B c) mismatch! Expected $expected1, got $result1"
        }

        // Test: FIRST(A a)
        val seq2 = listOf("A", "a")
        val result2 = firstSets.firstOfString(seq2)
        val expected2 = setOf("a")
        println("  FIRST(A a) = $result2")
        println("  Expected: $expected2")
        assert(result2 == expected2) {
            "FIRST(A a) mismatch! Expected $expected2, got $result2"
        }

        // Test: FIRST(c)
        val seq3 = listOf("c")
        val result3 = firstSets.firstOfString(seq3)
        val expected3 = setOf("c")
        println("  FIRST(c) = $result3")
        println("  Expected: $expected3")
        assert(result3 == expected3) {
            "FIRST(c) mismatch! Expected $expected3, got $result3"
        }

        // Test: FIRST(A B) where both are nullable
        val seq4 = listOf("A", "B")
        val result4 = firstSets.firstOfString(seq4)
        val expected4 = setOf("a", "b", "ε")
        println("  FIRST(A B) = $result4")
        println("  Expected: $expected4")
        assert(result4 == expected4) {
            "FIRST(A B) mismatch! Expected $expected4, got $result4"
        }

        println("  ✓ All firstOfString() tests correct")
        println("✅ Test 3 PASSED\n")
        passedTests++
    } catch (e: Exception) {
        println("❌ Test 3 FAILED: ${e.message}\n")
        e.printStackTrace()
    }

    // Test 4: Simple grammar
    println("━━━ Test 4: Simple Grammar (a^n b^n) ━━━")
    totalTests++
    try {
        val g4 = Grammar("grammars/g1_simple.txt")
        val firstSets = FirstSets(g4)

        println("Grammar:")
        g4.print()
        println("FIRST Sets:")
        firstSets.print()

        val expectedFirstS = setOf("a")
        val actualFirstS = firstSets.getFirst("S")

        println("✓ Verification:")
        println("  Expected FIRST(S) = $expectedFirstS")
        println("  Actual FIRST(S) = $actualFirstS")
        assert(actualFirstS == expectedFirstS) {
            "FIRST(S) mismatch! Expected $expectedFirstS, got $actualFirstS"
        }

        assert(!firstSets.canDeriveEpsilon("S")) { "S should not derive epsilon" }

        println("  ✓ FIRST(S) correct")
        println("✅ Test 4 PASSED\n")
        passedTests++
    } catch (e: Exception) {
        println("❌ Test 4 FAILED: ${e.message}\n")
        e.printStackTrace()
    }

    // Summary
    println("╔═══════════════════════════════════════════╗")
    println("║          Step 2 Testing Complete          ║")
    println("╚═══════════════════════════════════════════╝")
    println("\nResults: $passedTests/$totalTests tests passed")

    if (passedTests == totalTests) {
        println("\n🎉 Congratulations! All FIRST sets tests passed!")
        println("✅ Step 2 is complete and working correctly.")
        println("\n📚 You're ready for Step 3: FOLLOW sets computation")
    } else {
        println("\n⚠️  Some tests failed. Please fix the issues above.")
        println("💡 Review FirstSets.kt implementation")
    }
    println()
}

/**
 * Print usage information.
 */
fun printUsage() {
    println("""
        Usage:
          1. Parse input sequence:
             ./program <grammar_file> <input_file>

          2. Check if grammar is SLR:
             ./program --check-slr <grammar_file>

          3. Show FIRST and FOLLOW sets:
             ./program --first-follow <grammar_file>

        Examples:
          ./program grammars/g2_arithmetic.txt inputs/test2_arithmetic.txt
          ./program --check-slr grammars/g2_arithmetic.txt
          ./program --first-follow grammars/g2_arithmetic.txt

        Grammar file format:
          N: <non-terminals>
          T: <terminals>
          S: <start symbol>
          P:
          <production 1>
          <production 2>
          ...
    """.trimIndent())
}
