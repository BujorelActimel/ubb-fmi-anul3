data class ItemSet(
    val items: Set<LRItem>,
    val id: Int
) {
    override fun toString(): String {
        val itemsStr = items.joinToString("\n    ") { it.toString() }
        return "State $id:\n    $itemsStr"
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is ItemSet) return false
        return items == other.items
    }

    override fun hashCode(): Int {
        return items.hashCode()
    }
}

class LRAutomaton(
    private val grammar: Grammar,
    private val firstSets: FirstSets
) {
    private val states: MutableList<ItemSet> = mutableListOf()
    private val transitions: MutableMap<Pair<Int, String>, Int> = mutableMapOf()

    private val itemSetToId: MutableMap<Set<LRItem>, Int> = mutableMapOf()

    init {
        buildCanonicalCollection()
    }

    fun closure(items: Set<LRItem>): Set<LRItem> {
        val result = items.toMutableSet()

        do {
            var changed = false
            val toAdd = mutableSetOf<LRItem>()

            for (item in result) {
                val nextSym = item.nextSymbol()

                if (nextSym == null || !grammar.isNonTerminal(nextSym)) {
                    continue
                }

                for (production in grammar.getProductionsFor(nextSym)) {
                    val newItem = LRItem(production, 0)
                    if (newItem !in result) {
                        toAdd.add(newItem)
                        changed = true
                    }
                }
            }

            result.addAll(toAdd)
        } while (changed)

        return result
    }

    fun goto(items: Set<LRItem>, symbol: String): Set<LRItem> {
        val movedItems = mutableSetOf<LRItem>()

        for (item in items) {
            if (item.nextSymbol() == symbol) {
                movedItems.add(item.advance())
            }
        }

        return if (movedItems.isEmpty()) {
            emptySet()
        } else {
            closure(movedItems)
        }
    }

    private fun buildCanonicalCollection() {
        val augmentedProduction = grammar.productions[0]
        val initialItem = LRItem(augmentedProduction, 0)
        val initialClosure = closure(setOf(initialItem))

        val initialState = ItemSet(initialClosure, 0)
        states.add(initialState)
        itemSetToId[initialClosure] = 0

        val queue = mutableListOf(0)
        val processed = mutableSetOf<Int>()

        while (queue.isNotEmpty()) {
            val stateId = queue.removeAt(0)
            if (stateId in processed) continue
            processed.add(stateId)

            val state = states[stateId]

            val symbols = state.items
                .mapNotNull { it.nextSymbol() }
                .toSet()

            for (symbol in symbols) {
                val gotoSet = goto(state.items, symbol)

                if (gotoSet.isEmpty()) continue

                val existingId = itemSetToId[gotoSet]

                val targetId = if (existingId != null) {
                    existingId
                } else {
                    val newId = states.size
                    val newState = ItemSet(gotoSet, newId)
                    states.add(newState)
                    itemSetToId[gotoSet] = newId
                    queue.add(newId)
                    newId
                }

                transitions[Pair(stateId, symbol)] = targetId
            }
        }
    }

    fun getStates(): List<ItemSet> = states

    fun getTransition(stateId: Int, symbol: String): Int? {
        return transitions[Pair(stateId, symbol)]
    }

    fun getAllTransitions(): Map<Pair<Int, String>, Int> = transitions

    fun print() {
        println("=== LR(0) Automaton ===")
        println("\nStates: ${states.size}")
        println("Transitions: ${transitions.size}")

        println("\n--- States ---")
        for (state in states) {
            println("\n$state")
        }

        println("\n--- Transitions ---")
        for ((key, target) in transitions.toSortedMap(compareBy({ it.first }, { it.second }))) {
            val (from, symbol) = key
            println("  State $from --[$symbol]--> State $target")
        }

        println("\n======================\n")
    }
}
