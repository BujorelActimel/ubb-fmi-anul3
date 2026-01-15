/**
 * Represents an action in the SLR parsing table.
 */
sealed class Action {
    /** Shift to the specified state */
    data class Shift(val state: Int) : Action() {
        override fun toString() = "s$state"
    }

    /** Reduce by the specified production */
    data class Reduce(val production: Production, val productionIndex: Int) : Action() {
        override fun toString() = "r$productionIndex"
    }

    /** Accept the input */
    object Accept : Action() {
        override fun toString() = "acc"
    }

    /** Error (no action defined) */
    object Error : Action() {
        override fun toString() = "err"
    }
}

/**
 * Represents a conflict in the parsing table.
 */
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

/**
 * SLR Parsing Table with ACTION and GOTO tables.
 *
 * The ACTION table determines what action to take based on current state and input symbol.
 * The GOTO table determines the next state after a reduction.
 */
class SLRTable(
    private val grammar: Grammar,
    private val automaton: LRAutomaton,
    private val followSets: FollowSets
) {
    // ACTION[state, terminal] -> Action
    private val actionTable: MutableMap<Pair<Int, String>, Action> = mutableMapOf()

    // GOTO[state, non-terminal] -> state
    private val gotoTable: MutableMap<Pair<Int, String>, Int> = mutableMapOf()

    // List of conflicts found during table construction
    private val conflicts: MutableList<Conflict> = mutableListOf()

    init {
        buildTable()
    }

    /**
     * Build the SLR parsing table.
     *
     * Algorithm:
     * For each state I:
     *   For each item [A -> α•aβ] in I where a is a terminal:
     *     If goto(I, a) = j, set ACTION[I, a] = shift j
     *
     *   For each item [A -> α•] in I (complete item):
     *     For each terminal a in FOLLOW(A):
     *       If A is the start symbol (S' -> S), set ACTION[I, $] = accept
     *       Otherwise, set ACTION[I, a] = reduce A->α
     *
     *   For each non-terminal A:
     *     If goto(I, A) = j, set GOTO[I, A] = j
     */
    private fun buildTable() {
        val states = automaton.getStates()

        for (state in states) {
            val stateId = state.id

            for (item in state.items) {
                val nextSym = item.nextSymbol()

                if (nextSym != null) {
                    // Item: [A -> α•Xβ] where X is the next symbol
                    val gotoState = automaton.getTransition(stateId, nextSym)

                    if (gotoState != null) {
                        if (grammar.isTerminal(nextSym)) {
                            // ACTION[state, terminal] = shift
                            addAction(stateId, nextSym, Action.Shift(gotoState))
                        } else {
                            // GOTO[state, non-terminal] = gotoState
                            gotoTable[Pair(stateId, nextSym)] = gotoState
                        }
                    }
                } else {
                    // Complete item: [A -> α•]
                    val production = item.production
                    val prodIndex = grammar.productions.indexOf(production)

                    // Check if this is the accept item: S' -> S•
                    if (production.lhs == grammar.startSymbol &&
                        production.rhs.size == 1 &&
                        stateId != 0) {
                        // ACTION[state, $] = accept
                        addAction(stateId, "$", Action.Accept)
                    } else {
                        // For each terminal in FOLLOW(A), ACTION[state, a] = reduce
                        val followSet = followSets.getFollow(production.lhs)
                        for (terminal in followSet) {
                            addAction(stateId, terminal, Action.Reduce(production, prodIndex))
                        }
                    }
                }
            }
        }
    }

    /**
     * Add an action to the ACTION table, detecting conflicts.
     */
    private fun addAction(state: Int, terminal: String, newAction: Action) {
        val key = Pair(state, terminal)
        val existingAction = actionTable[key]

        if (existingAction == null) {
            // No conflict, just add the action
            actionTable[key] = newAction
        } else if (existingAction != newAction) {
            // Conflict detected!
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
        // If actions are the same, no conflict (can happen with same reduce from different paths)
    }

    /**
     * Get the action for a given state and terminal.
     */
    fun getAction(state: Int, terminal: String): Action {
        return actionTable[Pair(state, terminal)] ?: Action.Error
    }

    /**
     * Get the goto state for a given state and non-terminal.
     */
    fun getGoto(state: Int, nonTerminal: String): Int? {
        return gotoTable[Pair(state, nonTerminal)]
    }

    /**
     * Check if the grammar is SLR (no conflicts).
     */
    fun isSLR(): Boolean {
        return conflicts.isEmpty()
    }

    /**
     * Get all conflicts found during table construction.
     */
    fun getConflicts(): List<Conflict> {
        return conflicts
    }

    /**
     * Print the parsing table in a readable format.
     */
    fun print() {
        println("=== SLR Parsing Table ===")
        println("\nGrammar is ${if (isSLR()) "SLR (no conflicts)" else "NOT SLR (conflicts found)"}")

        if (!isSLR()) {
            println("\n⚠️  CONFLICTS DETECTED:")
            for (conflict in conflicts) {
                println("\n$conflict")
            }
            println()
        }

        // Collect all terminals and non-terminals for headers
        val terminals = (grammar.terminals + "$").sorted()
        val nonTerminals = grammar.nonTerminals.filter { it != grammar.startSymbol }.sorted()
        val states = automaton.getStates()

        // Print ACTION table
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

        // Print GOTO table
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

    /**
     * Print a compact summary of the table.
     */
    fun printSummary() {
        println("SLR Table Summary:")
        println("  States: ${automaton.getStates().size}")
        println("  ACTION entries: ${actionTable.size}")
        println("  GOTO entries: ${gotoTable.size}")
        println("  Conflicts: ${conflicts.size}")
        println("  Is SLR: ${if (isSLR()) "✓ Yes" else "✗ No"}")
    }
}
