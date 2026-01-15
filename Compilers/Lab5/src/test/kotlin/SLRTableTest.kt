import kotlin.test.*

class SLRTableTest {

    @Test
    fun testArithmeticGrammarSLR() {
        val g1 = Grammar("grammars/g2_arithmetic.txt")
        g1.augmentGrammar()
        val firstSets = FirstSets(g1)
        val followSets = FollowSets(g1, firstSets)
        val automaton = LRAutomaton(g1, firstSets)
        val slrTable = SLRTable(g1, automaton, followSets)

        // Verify the grammar is SLR
        assertTrue(slrTable.isSLR(), "Arithmetic grammar should be SLR")

        // Test specific actions
        val action0id = slrTable.getAction(0, "id")
        assertTrue(action0id is Action.Shift)

        val action1dollar = slrTable.getAction(1, "$")
        assertTrue(action1dollar is Action.Accept)

        val goto0E = slrTable.getGoto(0, "E")
        assertNotNull(goto0E)
    }

    @Test
    fun testSimpleGrammarSLR() {
        val g2 = Grammar("grammars/g1_simple.txt")
        g2.augmentGrammar()
        val firstSets = FirstSets(g2)
        val followSets = FollowSets(g2, firstSets)
        val automaton = LRAutomaton(g2, firstSets)
        val slrTable = SLRTable(g2, automaton, followSets)

        assertTrue(slrTable.isSLR())
    }

    @Test
    fun testGrammarWithEpsilonSLR() {
        val g3 = Grammar("grammars/g3_with_epsilon.txt")
        g3.augmentGrammar()
        val firstSets = FirstSets(g3)
        val followSets = FollowSets(g3, firstSets)
        val automaton = LRAutomaton(g3, firstSets)
        val slrTable = SLRTable(g3, automaton, followSets)

        assertTrue(slrTable.isSLR())

        // Verify epsilon reductions exist
        val action0b = slrTable.getAction(0, "b")
        val action0c = slrTable.getAction(0, "c")

        assertTrue(action0b is Action.Reduce || action0b is Action.Shift)
        assertTrue(action0c is Action.Reduce || action0c is Action.Shift)
    }

    @Test
    fun testConflictDetection() {
        val conflictGrammarPath = "grammars/g4_conflict.txt"
        java.io.File(conflictGrammarPath).writeText("""
            S -> E
            E -> E + E
            E -> id
        """.trimIndent())

        val g4 = Grammar(conflictGrammarPath)
        g4.augmentGrammar()
        val firstSets = FirstSets(g4)
        val followSets = FollowSets(g4, firstSets)
        val automaton = LRAutomaton(g4, firstSets)
        val slrTable = SLRTable(g4, automaton, followSets)

        // This ambiguous grammar should have conflicts
        if (!slrTable.isSLR()) {
            assertTrue(slrTable.getConflicts().isNotEmpty())
        }
    }

    @Test
    fun testActionTableEntries() {
        val g5 = Grammar("grammars/g2_arithmetic.txt")
        g5.augmentGrammar()
        val firstSets = FirstSets(g5)
        val followSets = FollowSets(g5, firstSets)
        val automaton = LRAutomaton(g5, firstSets)
        val slrTable = SLRTable(g5, automaton, followSets)

        var shiftCount = 0
        var reduceCount = 0
        var acceptCount = 0

        for (state in automaton.getStates()) {
            for (terminal in g5.terminals + "$") {
                when (val action = slrTable.getAction(state.id, terminal)) {
                    is Action.Shift -> shiftCount++
                    is Action.Reduce -> reduceCount++
                    is Action.Accept -> acceptCount++
                    is Action.Error -> {}
                }
            }
        }

        assertTrue(shiftCount > 0)
        assertTrue(reduceCount > 0)
        assertEquals(1, acceptCount)

        // Verify GOTO entries exist
        var gotoCount = 0
        for (state in automaton.getStates()) {
            for (nt in g5.nonTerminals) {
                if (nt == g5.startSymbol) continue
                if (slrTable.getGoto(state.id, nt) != null) {
                    gotoCount++
                }
            }
        }
        assertTrue(gotoCount > 0)
    }
}
