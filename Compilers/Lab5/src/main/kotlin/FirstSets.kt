/**
 * FIRST Sets Computation for SLR Parser
 *
 * The FIRST set of a symbol α is the set of terminals that can appear as the
 * first symbol of strings derived from α.
 *
 * Definition:
 * - FIRST(a) = {a} if a is a terminal
 * - FIRST(A) = set of terminals that can start strings derivable from A
 * - ε (epsilon) is included if A can derive the empty string
 *
 * Example:
 * Grammar: E -> T + E | T
 *          T -> id
 * Result: FIRST(E) = {id}, FIRST(T) = {id}
 *
 * With epsilon:
 * Grammar: S -> A B c
 *          A -> a A | ε
 *          B -> b B | ε
 * Result: FIRST(S) = {a, b, c}, FIRST(A) = {a, ε}, FIRST(B) = {b, ε}
 */
class FirstSets(private val grammar: Grammar) {
    // Map from symbol to its FIRST set
    // Key: Non-terminal or terminal symbol
    // Value: Set of terminal symbols (may include "ε" for epsilon)
    private val first: MutableMap<String, MutableSet<String>> = mutableMapOf()

    // Track which symbols can derive epsilon
    // This is crucial for computing FIRST of sequences
    private val nullable: MutableSet<String> = mutableSetOf()

    init {
        computeFirstSets()
    }

    /**
     * TODO: Main algorithm - compute FIRST sets using non-recursive fixed-point iteration.
     *
     * REQUIREMENT: Must be NON-RECURSIVE (as specified in assignment)!
     * Use iterative fixed-point algorithm with a loop that continues until no changes.
     *
     * Algorithm Steps:
     *
     * 1. INITIALIZATION:
     *    a. For each terminal t in grammar.terminals:
     *       - FIRST(t) = {t}
     *    b. For each non-terminal N in grammar.nonTerminals:
     *       - FIRST(N) = {} (empty set initially)
     *
     * 2. EPSILON DETECTION (first pass):
     *    - For each production A → α:
     *      - If α is empty (epsilon production): add A to nullable set
     *
     * 3. FIXED-POINT ITERATION (repeat until no changes):
     *    changed = true
     *    while (changed):
     *        changed = false
     *        For each production A → X₁ X₂ X₃ ... Xₙ:
     *
     *            i = 1
     *            while (i <= n):
     *                a. Add FIRST(Xᵢ) - {ε} to FIRST(A)
     *                   If anything was added, set changed = true
     *
     *                b. If Xᵢ is not nullable (cannot derive ε):
     *                   - Break out of inner while loop
     *
     *                c. If Xᵢ is nullable:
     *                   - Continue to next symbol (i++)
     *
     *            d. If we went through ALL symbols (all are nullable):
     *               - Add ε to FIRST(A)
     *               - Add A to nullable set
     *
     * 4. UPDATE NULLABLE (within iteration):
     *    - After processing each production A → X₁...Xₙ
     *    - If all Xᵢ are nullable, mark A as nullable
     *
     * Example trace for: A → B C, B → ε, C → c
     * Initial: FIRST(A)={}, FIRST(B)={ε}, FIRST(C)={c}, nullable={B}
     * Iteration 1:
     *   - Process A → B C
     *   - Add FIRST(B)-{ε} to FIRST(A) → nothing added
     *   - B is nullable, continue to C
     *   - Add FIRST(C)-{ε} = {c} to FIRST(A)
     *   - FIRST(A) = {c}
     * Result: FIRST(A)={c}
     *
     * Implementation hints:
     * - Use a do-while loop: do { ... } while (changed)
     * - Track changes with a boolean flag
     * - For each production, process RHS symbols left to right
     * - Use the helper function canDeriveEpsilon() to check nullable
     */
    private fun computeFirstSets() {
        // TODO: Step 1 - Initialize FIRST sets for all terminals
        // for (terminal in grammar.terminals) {
        //     first[terminal] = mutableSetOf(terminal)
        // }

        // TODO: Step 1 - Initialize FIRST sets for all non-terminals
        // for (nonTerminal in grammar.nonTerminals) {
        //     first[nonTerminal] = mutableSetOf()
        // }

        // TODO: Step 2 - Detect epsilon productions
        // for (production in grammar.productions) {
        //     if (production.isEpsilon()) {
        //         nullable.add(production.lhs)
        //     }
        // }

        // TODO: Step 3 - Fixed-point iteration
        // var changed: Boolean
        // do {
        //     changed = false
        //     for (production in grammar.productions) {
        //         // Process each production A → X₁ X₂ ... Xₙ
        //         val A = production.lhs
        //         val rhs = production.rhs
        //
        //         // Handle epsilon production
        //         if (production.isEpsilon()) {
        //             if (first[A]?.add("ε") == true) {
        //                 changed = true
        //             }
        //             continue
        //         }
        //
        //         // Process each symbol in RHS
        //         var allNullable = true
        //         for (symbol in rhs) {
        //             // Add FIRST(symbol) - {ε} to FIRST(A)
        //             val symbolFirst = getFirst(symbol)
        //             for (terminal in symbolFirst) {
        //                 if (terminal != "ε") {
        //                     if (first[A]?.add(terminal) == true) {
        //                         changed = true
        //                     }
        //                 }
        //             }
        //
        //             // If symbol cannot derive epsilon, stop
        //             if (!canDeriveEpsilon(symbol)) {
        //                 allNullable = false
        //                 break
        //             }
        //         }
        //
        //         // If all symbols in RHS are nullable, A is nullable
        //         if (allNullable) {
        //             if (nullable.add(A)) {
        //                 changed = true
        //             }
        //             if (first[A]?.add("ε") == true) {
        //                 changed = true
        //             }
        //         }
        //     }
        // } while (changed)
    }

    /**
     * TODO: Get FIRST set for a single symbol.
     *
     * Purpose: Retrieve the FIRST set for any symbol (terminal or non-terminal).
     * This is used both internally and externally.
     *
     * Algorithm:
     * 1. If symbol exists in the first map, return its set
     * 2. Otherwise, return empty set (shouldn't happen if grammar is valid)
     *
     * @param symbol The symbol to get FIRST set for
     * @return Set of terminals in FIRST(symbol), may include "ε"
     *
     * Example:
     * getFirst("E") might return {"(", "id"}
     * getFirst("+") returns {"+"}
     * getFirst("A") where A -> ε returns {"ε"}
     */
    fun getFirst(symbol: String): Set<String> {
        // TODO: Return FIRST set for symbol
        // return first[symbol] ?: emptySet()
        return emptySet()
    }

    /**
     * TODO: Compute FIRST set for a sequence of symbols.
     *
     * Purpose: Given a sequence of symbols α = X₁ X₂ ... Xₙ, compute FIRST(α).
     * This is essential for parsing - we need to know what terminals can start
     * a string derived from a sequence of symbols.
     *
     * Algorithm:
     * 1. result = empty set
     * 2. For each symbol Xᵢ in sequence (left to right):
     *    a. Add FIRST(Xᵢ) - {ε} to result
     *    b. If Xᵢ cannot derive ε:
     *       - Stop, return result
     *    c. If Xᵢ can derive ε:
     *       - Continue to next symbol
     * 3. If ALL symbols can derive ε:
     *    - Add ε to result
     * 4. Return result
     *
     * Example 1: FIRST(T + E) where FIRST(T)={id}, FIRST(+)={+}
     * - Add FIRST(T) = {id}
     * - T cannot derive ε, stop
     * Result: {id}
     *
     * Example 2: FIRST(A B c) where A->ε, FIRST(A)={a,ε}, FIRST(B)={b,ε}, FIRST(c)={c}
     * - Add FIRST(A)-{ε} = {a}
     * - A is nullable, continue
     * - Add FIRST(B)-{ε} = {b}
     * - B is nullable, continue
     * - Add FIRST(c) = {c}
     * - c is not nullable, stop
     * Result: {a, b, c}
     *
     * Example 3: FIRST(A B) where both A and B derive only ε
     * - Add FIRST(A)-{ε} = {}
     * - A is nullable, continue
     * - Add FIRST(B)-{ε} = {}
     * - B is nullable, continue
     * - All symbols nullable, add ε
     * Result: {ε}
     *
     * @param symbols List of symbols (terminals and/or non-terminals)
     * @return Set of terminals that can start strings derived from the sequence
     */
    fun firstOfString(symbols: List<String>): Set<String> {
        // TODO: Implement FIRST of string sequence
        // val result = mutableSetOf<String>()
        // if (symbols.isEmpty()) {
        //     result.add("ε")
        //     return result
        // }
        //
        // for (symbol in symbols) {
        //     val symbolFirst = getFirst(symbol)
        //     // Add everything except epsilon
        //     result.addAll(symbolFirst.filter { it != "ε" })
        //
        //     // If this symbol cannot derive epsilon, stop
        //     if (!canDeriveEpsilon(symbol)) {
        //         return result
        //     }
        // }
        //
        // // All symbols are nullable
        // result.add("ε")
        // return result
        return emptySet()
    }

    /**
     * TODO: Check if a symbol can derive epsilon (empty string).
     *
     * Purpose: Determine whether a symbol can eventually derive ε.
     * This is critical for computing FIRST sets correctly.
     *
     * Algorithm:
     * 1. If symbol is a terminal: return false (terminals cannot derive ε)
     * 2. If symbol is in nullable set: return true
     * 3. Otherwise: return false
     *
     * Note: The nullable set is computed during computeFirstSets()
     *
     * @param symbol The symbol to check
     * @return true if symbol can derive ε, false otherwise
     *
     * Example:
     * Grammar: A -> ε | a
     * canDeriveEpsilon("A") = true
     * canDeriveEpsilon("a") = false
     */
    fun canDeriveEpsilon(symbol: String): Boolean {
        // TODO: Check if symbol is nullable
        // return symbol in nullable
        return false
    }

    /**
     * Print FIRST sets in readable format.
     * Useful for debugging and verifying correctness.
     */
    fun print() {
        println("=== FIRST Sets ===")

        // Print non-terminals first
        println("\nNon-terminals:")
        for (nonTerminal in grammar.nonTerminals.sorted()) {
            val firstSet = first[nonTerminal] ?: emptySet()
            val formatted = firstSet.joinToString(", ")
            println("  FIRST($nonTerminal) = { $formatted }")
        }

        // Print terminals
        println("\nTerminals:")
        for (terminal in grammar.terminals.sorted()) {
            val firstSet = first[terminal] ?: emptySet()
            val formatted = firstSet.joinToString(", ")
            println("  FIRST($terminal) = { $formatted }")
        }

        // Print nullable symbols
        if (nullable.isNotEmpty()) {
            println("\nNullable symbols (can derive ε):")
            println("  ${nullable.sorted().joinToString(", ")}")
        }

        println("==================\n")
    }
}
