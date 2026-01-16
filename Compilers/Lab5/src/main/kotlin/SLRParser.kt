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

class SLRParser(
    private val grammar: Grammar,
    private val slrTable: SLRTable
) {
    fun parse(tokens: List<String>): ParseResult {
        val stack = mutableListOf<Pair<String, Int>>()
        stack.add(Pair("", 0))

        val input = tokens.toMutableList()
        input.add("$")
        var inputIndex = 0

        val productionsUsed = mutableListOf<Production>()
        val productionIndices = mutableListOf<Int>()

        while (true) {
            val currentState = stack.last().second
            val currentSymbol = input[inputIndex]

            val action = slrTable.getAction(currentState, currentSymbol)

            when (action) {
                is Action.Shift -> {
                    stack.add(Pair(currentSymbol, action.state))
                    inputIndex++
                }

                is Action.Reduce -> {
                    val production = action.production
                    val rhsLength = production.rhs.size

                    repeat(rhsLength) {
                        if (stack.size > 1) {
                            stack.removeAt(stack.size - 1)
                        }
                    }

                    val topState = stack.last().second

                    val gotoState = slrTable.getGoto(topState, production.lhs)
                        ?: return ParseResult.Error(
                            tokens,
                            "No GOTO entry for state $topState and non-terminal ${production.lhs}",
                            inputIndex
                        )

                    stack.add(Pair(production.lhs, gotoState))

                    productionsUsed.add(production)
                    productionIndices.add(action.productionIndex)
                }

                is Action.Accept -> {
                    return ParseResult.Success(tokens, productionsUsed, productionIndices)
                }

                is Action.Error -> {
                    val expected = getExpectedSymbols(currentState)
                    val message = "Unexpected symbol '$currentSymbol'. Expected one of: ${expected.joinToString(", ")}"
                    return ParseResult.Error(tokens, message, inputIndex)
                }
            }
        }
    }

    private fun getExpectedSymbols(state: Int): List<String> {
        val expected = mutableListOf<String>()

        for (terminal in grammar.terminals + "$") {
            val action = slrTable.getAction(state, terminal)
            if (action !is Action.Error) {
                expected.add(terminal)
            }
        }

        return expected
    }

    fun parse(input: String): ParseResult {
        val tokens = input.trim().split("\\s+".toRegex()).filter { it.isNotEmpty() }
        return parse(tokens)
    }

    fun printTable() {
        slrTable.print()
    }
}
