sealed class Action {
    data class Shift(val state: Int) : Action() {
        override fun toString() = "s$state"
    }

    data class Reduce(val production: Production, val productionIndex: Int) : Action() {
        override fun toString() = "r$productionIndex"
    }

    object Accept : Action() {
        override fun toString() = "acc"
    }

    object Error : Action() {
        override fun toString() = "err"
    }
}

sealed class Conflict {
    data class ShiftReduce(
        val state: Int,
        val terminal: String,
        val shiftState: Int,
        val reduceProduction: Production,
        val reduceIndex: Int
    ) : Conflict() {
        override fun toString(): String {
            return "Shift-Reduce conflict in State $state on terminal '$terminal':\n" +
                   "  - Shift to state $shiftState\n" +
                   "  - Reduce by production $reduceIndex: $reduceProduction"
        }
    }

    data class ReduceReduce(
        val state: Int,
        val terminal: String,
        val production1: Production,
        val production1Index: Int,
        val production2: Production,
        val production2Index: Int
    ) : Conflict() {
        override fun toString(): String {
            return "Reduce-Reduce conflict in State $state on terminal '$terminal':\n" +
                   "  - Reduce by production $production1Index: $production1\n" +
                   "  - Reduce by production $production2Index: $production2"
        }
    }
}

class SLRTable(
    private val grammar: Grammar,
    private val automaton: LRAutomaton,
    private val followSets: FollowSets
) {
    private val actionTable: MutableMap<Pair<Int, String>, Action> = mutableMapOf()

    private val gotoTable: MutableMap<Pair<Int, String>, Int> = mutableMapOf()

    private val conflicts: MutableList<Conflict> = mutableListOf()

    init {
        buildTable()
    }

    private fun buildTable() {
        val states = automaton.getStates()

        for (state in states) {
            val stateId = state.id

            for (item in state.items) {
                val nextSym = item.nextSymbol()

                if (nextSym != null) {
                    val gotoState = automaton.getTransition(stateId, nextSym)

                    if (gotoState != null) {
                        if (grammar.isTerminal(nextSym)) {
                            addAction(stateId, nextSym, Action.Shift(gotoState))
                        } else {
                            gotoTable[Pair(stateId, nextSym)] = gotoState
                        }
                    }
                } else {
                    val production = item.production
                    val prodIndex = grammar.productions.indexOf(production)

                    if (production.lhs == grammar.startSymbol &&
                        production.rhs.size == 1 &&
                        stateId != 0) {
                        addAction(stateId, "$", Action.Accept)
                    } else {
                        val followSet = followSets.getFollow(production.lhs)
                        for (terminal in followSet) {
                            addAction(stateId, terminal, Action.Reduce(production, prodIndex))
                        }
                    }
                }
            }
        }
    }

    private fun addAction(state: Int, terminal: String, newAction: Action) {
        val key = Pair(state, terminal)
        val existingAction = actionTable[key]

        if (existingAction == null) {
            actionTable[key] = newAction
        } else if (existingAction != newAction) {
            val conflict = when {
                existingAction is Action.Shift && newAction is Action.Reduce -> {
                    Conflict.ShiftReduce(
                        state, terminal,
                        existingAction.state,
                        newAction.production, newAction.productionIndex
                    )
                }
                existingAction is Action.Reduce && newAction is Action.Shift -> {
                    Conflict.ShiftReduce(
                        state, terminal,
                        newAction.state,
                        existingAction.production, existingAction.productionIndex
                    )
                }
                existingAction is Action.Reduce && newAction is Action.Reduce -> {
                    Conflict.ReduceReduce(
                        state, terminal,
                        existingAction.production, existingAction.productionIndex,
                        newAction.production, newAction.productionIndex
                    )
                }
                else -> null
            }

            if (conflict != null) {
                conflicts.add(conflict)
            }
        }
    }

    fun getAction(state: Int, terminal: String): Action {
        return actionTable[Pair(state, terminal)] ?: Action.Error
    }

    fun getGoto(state: Int, nonTerminal: String): Int? {
        return gotoTable[Pair(state, nonTerminal)]
    }

    fun isSLR(): Boolean {
        return conflicts.isEmpty()
    }

    fun getConflicts(): List<Conflict> {
        return conflicts
    }

    fun print() {
        println("=== SLR Parsing Table ===")
        println("\nGrammar is ${if (isSLR()) "SLR (no conflicts)" else "NOT SLR (conflicts found)"}")

        if (!isSLR()) {
            println("CONFLICTS DETECTED:")
            for (conflict in conflicts) {
                println("\n$conflict")
            }
            println()
        }

        val terminals = (grammar.terminals + "$").sorted()
        val nonTerminals = grammar.nonTerminals.filter { it != grammar.startSymbol }.sorted()
        val states = automaton.getStates()

        println("\n--- ACTION Table ---")
        print("State".padEnd(8))
        for (term in terminals) {
            print(term.padEnd(8))
        }
        println()
        println("-".repeat(8 + terminals.size * 8))

        for (state in states) {
            print("${state.id}".padEnd(8))
            for (term in terminals) {
                val action = getAction(state.id, term)
                val actionStr = if (action is Action.Error) "" else action.toString()
                print(actionStr.padEnd(8))
            }
            println()
        }

        println("\n--- GOTO Table ---")
        print("State".padEnd(8))
        for (nt in nonTerminals) {
            print(nt.padEnd(8))
        }
        println()
        println("-".repeat(8 + nonTerminals.size * 8))

        for (state in states) {
            print("${state.id}".padEnd(8))
            for (nt in nonTerminals) {
                val gotoState = getGoto(state.id, nt)
                val gotoStr = gotoState?.toString() ?: ""
                print(gotoStr.padEnd(8))
            }
            println()
        }

        println("\n========================\n")
    }

    fun printSummary() {
        println("SLR Table Summary:")
        println("  States: ${automaton.getStates().size}")
        println("  ACTION entries: ${actionTable.size}")
        println("  GOTO entries: ${gotoTable.size}")
        println("  Conflicts: ${conflicts.size}")
        println("  Is SLR: ${if (isSLR()) "✓ Yes" else "✗ No"}")
    }
}
