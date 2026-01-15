/**
 * Represents the result of parsing an input string.
 */
sealed class ParseResult {
    data class Success(
        val input: List<String>,
        val productions: List<Production>,
        val productionIndices: List<Int>
    ) : ParseResult() {
        override fun toString(): String {
            val sb = StringBuilder()
            sb.append("Input: ${input.joinToString(" ")}\n")
            sb.append("Status: ACCEPTED\n\n")
            sb.append("Productions used (in order):\n")
            productionIndices.forEachIndexed { idx, prodIdx ->
                sb.append("${idx + 1}. [$prodIdx] ${productions[idx]}\n")
            }
            return sb.toString()
        }
    }

    data class Error(
        val input: List<String>,
        val message: String,
        val position: Int
    ) : ParseResult() {
        override fun toString(): String {
            val sb = StringBuilder()
            sb.append("Input: ${input.joinToString(" ")}\n")
            sb.append("Status: REJECTED\n\n")
            sb.append("Error: $message\n")
            sb.append("Position: $position\n")
            return sb.toString()
        }
    }
}

/**
 * SLR Parser - implements shift-reduce parsing using SLR table.
 *
 * The parser uses a stack to track states and symbols, and processes
 * input left-to-right using the ACTION and GOTO tables.
 */
class SLRParser(
    private val grammar: Grammar,
    private val slrTable: SLRTable
) {
    /**
     * Parse an input sequence.
     *
     * Algorithm (shift-reduce parsing):
     * 1. Initialize: stack = [0], input = tokens + [$]
     * 2. Let s = top of stack, a = current input symbol
     * 3. Based on ACTION[s, a]:
     *    - Shift: Push a and next state onto stack, advance input
     *    - Reduce by A -> β: Pop |β| symbols, push A and GOTO[top, A]
     *    - Accept: Parsing successful
     *    - Error: Parsing failed
     * 4. Repeat until accept or error
     *
     * @param tokens The input sequence (list of terminals)
     * @return ParseResult indicating success or failure
     */
    fun parse(tokens: List<String>): ParseResult {
        // Stack stores pairs of (symbol, state)
        val stack = mutableListOf<Pair<String, Int>>()
        stack.add(Pair("", 0)) // Initial state

        // Input with end-of-input marker
        val input = tokens.toMutableList()
        input.add("$")
        var inputIndex = 0

        // Track productions used (for output)
        val productionsUsed = mutableListOf<Production>()
        val productionIndices = mutableListOf<Int>()

        // Parsing loop
        while (true) {
            val currentState = stack.last().second
            val currentSymbol = input[inputIndex]

            // Get action from table
            val action = slrTable.getAction(currentState, currentSymbol)

            when (action) {
                is Action.Shift -> {
                    // Shift: push symbol and next state onto stack
                    stack.add(Pair(currentSymbol, action.state))
                    inputIndex++
                }

                is Action.Reduce -> {
                    // Reduce by production A -> β
                    val production = action.production
                    val rhsLength = production.rhs.size

                    // Pop |β| symbols from stack (but keep at least initial state)
                    repeat(rhsLength) {
                        if (stack.size > 1) {
                            stack.removeAt(stack.size - 1)
                        }
                    }

                    // Get current state after popping
                    val topState = stack.last().second

                    // Get goto state for non-terminal A
                    val gotoState = slrTable.getGoto(topState, production.lhs)
                        ?: return ParseResult.Error(
                            tokens,
                            "No GOTO entry for state $topState and non-terminal ${production.lhs}",
                            inputIndex
                        )

                    // Push A and goto state
                    stack.add(Pair(production.lhs, gotoState))

                    // Record production used
                    productionsUsed.add(production)
                    productionIndices.add(action.productionIndex)
                }

                is Action.Accept -> {
                    // Parsing successful!
                    return ParseResult.Success(tokens, productionsUsed, productionIndices)
                }

                is Action.Error -> {
                    // Parsing failed
                    val expected = getExpectedSymbols(currentState)
                    val message = "Unexpected symbol '$currentSymbol'. Expected one of: ${expected.joinToString(", ")}"
                    return ParseResult.Error(tokens, message, inputIndex)
                }
            }
        }
    }

    /**
     * Get the set of symbols expected in a given state.
     * Used for better error messages.
     */
    private fun getExpectedSymbols(state: Int): List<String> {
        val expected = mutableListOf<String>()

        // Check all terminals to see which have valid actions
        for (terminal in grammar.terminals + "$") {
            val action = slrTable.getAction(state, terminal)
            if (action !is Action.Error) {
                expected.add(terminal)
            }
        }

        return expected
    }

    /**
     * Parse input from a string (space-separated tokens).
     */
    fun parse(input: String): ParseResult {
        val tokens = input.trim().split("\\s+".toRegex()).filter { it.isNotEmpty() }
        return parse(tokens)
    }

    /**
     * Print the parsing table for debugging.
     */
    fun printTable() {
        slrTable.print()
    }
}
