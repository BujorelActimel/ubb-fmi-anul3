class FollowSets(
    private val grammar: Grammar,
    private val firstSets: FirstSets
) {
    private val follow: MutableMap<String, MutableSet<String>> = mutableMapOf()

    init {
        computeFollowSets()
    }

    private fun computeFollowSets() {
        for (nonTerminal in grammar.nonTerminals) {
            follow[nonTerminal] = mutableSetOf()
        }

        follow[grammar.startSymbol]?.add("$")

        do {
            var changed = false
            for (production in grammar.productions) {
                val A = production.lhs
                val rhs = production.rhs

                for (i in rhs.indices) {
                    val B = rhs[i]

                    if (!grammar.isNonTerminal(B)) continue

                    val beta = rhs.subList(i + 1, rhs.size)

                    val firstBeta = firstSets.firstOfString(beta)
                    changed = follow[B]!!.addAll(firstBeta) || changed

                    if (firstSets.canDeriveEpsilonFromSequence(beta)) {
                        changed = follow[B]!!.addAll(follow[A]!!) || changed
                    }
                }
            }
        } while (changed)
    }

    fun getFollow(nonTerminal: String): Set<String> {
        return follow[nonTerminal] ?: emptySet()
    }

    fun print() {
        println("=== FOLLOW Sets ===")

        println("\nNon-terminals:")
        for (nonTerminal in grammar.nonTerminals.sorted()) {
            val followSet = follow[nonTerminal] ?: emptySet()
            val formatted = followSet.sorted().joinToString(", ")
            println("  FOLLOW($nonTerminal) = { $formatted }")
        }

        println("===================\n")
    }
}
