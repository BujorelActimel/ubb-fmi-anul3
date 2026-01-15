import kotlin.test.*

class LRAutomatonTest {

    @Test
    fun testLRItemOperations() {
        val g1 = Grammar("grammars/g2_arithmetic.txt")
        val prod = g1.productions[0]  // E -> E + T

        val item0 = LRItem(prod, 0)  // E -> • E + T
        val item1 = LRItem(prod, 1)  // E -> E • + T
        val item2 = LRItem(prod, 2)  // E -> E + • T
        val item3 = LRItem(prod, 3)  // E -> E + T •

        // Test nextSymbol()
        assertEquals("E", item0.nextSymbol())
        assertEquals("+", item1.nextSymbol())
        assertEquals("T", item2.nextSymbol())
        assertNull(item3.nextSymbol())

        // Test isComplete()
        assertFalse(item0.isComplete())
        assertFalse(item1.isComplete())
        assertFalse(item2.isComplete())
        assertTrue(item3.isComplete())

        // Test advance()
        val advanced = item0.advance()
        assertEquals(1, advanced.dotPosition)
        assertEquals("+", advanced.nextSymbol())
    }

    @Test
    fun testEpsilonItem() {
        val g3 = Grammar("grammars/g3_with_epsilon.txt")
        val epsilonProd = g3.productions.find { it.isEpsilon() }!!
        val epsilonItem = LRItem(epsilonProd, 0)

        assertTrue(epsilonItem.isComplete())
        assertNull(epsilonItem.nextSymbol())
    }

    @Test
    fun testClosureOperation() {
        val g2 = Grammar("grammars/g2_arithmetic.txt")
        g2.augmentGrammar()
        val firstSets = FirstSets(g2)
        val automaton = LRAutomaton(g2, firstSets)

        val initialProd = g2.productions[0]
        val initialItem = LRItem(initialProd, 0)
        val closure0 = automaton.closure(setOf(initialItem))

        // Verify closure includes expected items
        assertTrue(closure0.any { it.production.lhs == "E'" && it.dotPosition == 0 })
        assertTrue(closure0.any { it.production.lhs == "E" && it.production.rhs.getOrNull(0) == "E" && it.dotPosition == 0 })
        assertTrue(closure0.any { it.production.lhs == "E" && it.production.rhs.getOrNull(0) == "T" && it.dotPosition == 0 })
        assertTrue(closure0.any { it.production.lhs == "T" && it.dotPosition == 0 })
        assertTrue(closure0.any { it.production.lhs == "F" && it.dotPosition == 0 })
    }

    @Test
    fun testGotoOperation() {
        val g2 = Grammar("grammars/g2_arithmetic.txt")
        g2.augmentGrammar()
        val firstSets = FirstSets(g2)
        val automaton = LRAutomaton(g2, firstSets)

        val state0 = automaton.getStates()[0]

        // Test goto(state0, E)
        val gotoE = automaton.goto(state0.items, "E")
        assertTrue(gotoE.any { it.production.lhs == "E'" && it.dotPosition == 1 })
        assertTrue(gotoE.any {
            it.production.lhs == "E" &&
            it.production.rhs.size == 3 &&
            it.production.rhs[0] == "E" &&
            it.dotPosition == 1
        })

        // Test goto(state0, id)
        val gotoId = automaton.goto(state0.items, "id")
        assertTrue(gotoId.any {
            it.production.lhs == "F" &&
            it.production.rhs == listOf("id") &&
            it.dotPosition == 1
        })
    }

    @Test
    fun testCanonicalCollectionArithmetic() {
        val g2 = Grammar("grammars/g2_arithmetic.txt")
        g2.augmentGrammar()
        val firstSets = FirstSets(g2)
        val automaton = LRAutomaton(g2, firstSets)

        val states = automaton.getStates()
        val transitions = automaton.getAllTransitions()

        assertTrue(states.size > 5)
        assertTrue(transitions.size > 5)

        val state0 = states[0]
        assertTrue(state0.items.any { it.production.lhs == "E'" && it.dotPosition == 0 })
    }

    @Test
    fun testCanonicalCollectionSimple() {
        val g1 = Grammar("grammars/g1_simple.txt")
        g1.augmentGrammar()
        val firstSets = FirstSets(g1)
        val automaton = LRAutomaton(g1, firstSets)

        val states = automaton.getStates()
        val state0 = states[0]

        assertTrue(state0.items.any { it.production.lhs == "S'" && it.dotPosition == 0 })
    }

    @Test
    fun testCanonicalCollectionWithEpsilon() {
        val g3 = Grammar("grammars/g3_with_epsilon.txt")
        g3.augmentGrammar()
        val firstSets = FirstSets(g3)
        val automaton = LRAutomaton(g3, firstSets)

        val states = automaton.getStates()
        val state0 = states[0]

        assertTrue(state0.items.any { it.production.lhs == "S'" && it.dotPosition == 0 })
        assertTrue(state0.items.any { it.production.lhs == "A" && it.production.isEpsilon() })
    }
}
