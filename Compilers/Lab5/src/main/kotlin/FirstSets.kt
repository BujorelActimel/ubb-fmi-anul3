class FirstSets(private val grammar: Grammar) {
    private val first: MutableMap<String, MutableSet<String>> = mutableMapOf()
    private val nullable: MutableSet<String> = mutableSetOf()

    init {
        computeFirstSets()
    }

    private fun computeFirstSets() {
        for (terminal in grammar.terminals) {
            first[terminal] = mutableSetOf(terminal);
        }
        for (nonTerminal in grammar.nonTerminals) {
            first[nonTerminal] = mutableSetOf<String>()
        }

        for (production in grammar.productions) {
            if (production.rhs.isEmpty()) {
                nullable.add(production.lhs)
            }
        }

        do {
            var changed = false
            for (production in grammar.productions) {
                val A = production.lhs

                if (production.isEpsilon()) {
                    changed = nullable.add(A) || changed
                    continue
                }

                for (symbol in production.rhs) {
                    changed = first[A]!!.addAll(first[symbol]!!) || changed

                    if (symbol !in nullable) {
                        break
                    }
                }

                if (production.rhs.all { it in nullable }) {
                    changed = nullable.add(A) || changed
                }
            }
        } while (changed)
    }

    fun getFirst(symbol: String): Set<String> {
        return first[symbol] ?: emptySet()
    }

    fun firstOfString(symbols: List<String>): Set<String> {
        val result = mutableSetOf<String>()

        if (symbols.isEmpty()) {
            return result
        }

        for (symbol in symbols) {
            result.addAll(getFirst(symbol))

            if (!canDeriveEpsilon(symbol)) {
                return result
            }
        }

        return result
    }

    fun canDeriveEpsilon(symbol: String): Boolean {
        return symbol in nullable
    }

    fun canDeriveEpsilonFromSequence(symbols: List<String>): Boolean {
        if (symbols.isEmpty()) {
            return true
        }
        return symbols.all { canDeriveEpsilon(it) }
    }

    fun print() {
        println("=== FIRST Sets ===")

        println("\nNon-terminals:")
        for (nonTerminal in grammar.nonTerminals.sorted()) {
            val firstSet = first[nonTerminal] ?: emptySet()
            val formatted = firstSet.joinToString(", ")
            println("  FIRST($nonTerminal) = { $formatted }")
        }

        println("\nTerminals:")
        for (terminal in grammar.terminals.sorted()) {
            val firstSet = first[terminal] ?: emptySet()
            val formatted = firstSet.joinToString(", ")
            println("  FIRST($terminal) = { $formatted }")
        }

        if (nullable.isNotEmpty()) {
            println("\nNullable symbols (can derive ε):")
            println("  ${nullable.sorted().joinToString(", ")}")
        }

        println("==================\n")
    }
}
