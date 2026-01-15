import kotlin.test.*

class GrammarTest {

    @Test
    fun testSimpleGrammar() {
        val g1 = Grammar("grammars/g1_simple.txt")

        // Verify symbol classification
        assertTrue(g1.isNonTerminal("S"))
        assertTrue(g1.isTerminal("a"))
        assertTrue(g1.isTerminal("b"))
        assertFalse(g1.isTerminal("S"))
        assertFalse(g1.isNonTerminal("a"))

        // Test getProductionsFor
        val sProductions = g1.getProductionsFor("S")
        assertEquals(2, sProductions.size)
    }

    @Test
    fun testArithmeticGrammar() {
        val g2 = Grammar("grammars/g2_arithmetic.txt")

        val expectedNonTerminals = setOf("E", "T", "F")
        val expectedTerminals = setOf("+", "*", "(", ")", "id")

        assertEquals(expectedNonTerminals, g2.nonTerminals)
        assertEquals(expectedTerminals, g2.terminals)
        assertEquals("E", g2.startSymbol)

        // Test terminal checks
        assertTrue(g2.isTerminal("+"))
        assertTrue(g2.isNonTerminal("E"))
        assertFalse(g2.isTerminal("E"))
    }

    @Test
    fun testEpsilonProductions() {
        val g3 = Grammar("grammars/g3_with_epsilon.txt")

        val epsilonProductions = g3.productions.filter { it.isEpsilon() }
        assertEquals(2, epsilonProductions.size)

        val aProductions = g3.getProductionsFor("A")
        val bProductions = g3.getProductionsFor("B")
        val aEpsilon = aProductions.any { it.isEpsilon() }
        val bEpsilon = bProductions.any { it.isEpsilon() }

        assertTrue(aEpsilon)
        assertTrue(bEpsilon)
    }

    @Test
    fun testGrammarAugmentation() {
        val g4 = Grammar("grammars/g2_arithmetic.txt")
        val originalStartSymbol = g4.startSymbol

        g4.augmentGrammar()

        assertEquals("$originalStartSymbol'", g4.startSymbol)
        assertEquals("$originalStartSymbol'", g4.productions[0].lhs)
        assertEquals(listOf(originalStartSymbol), g4.productions[0].rhs)
        assertTrue(g4.isNonTerminal("$originalStartSymbol'"))
        assertFalse(g4.isTerminal("$originalStartSymbol'"))

        // Verify original productions still exist
        val eProds = g4.getProductionsFor(originalStartSymbol)
        assertTrue(eProds.isNotEmpty())
    }

    @Test
    fun testEdgeCases() {
        val g5 = Grammar("grammars/g1_simple.txt")

        // Test with non-existent non-terminal
        val emptyProds = g5.getProductionsFor("X")
        assertTrue(emptyProds.isEmpty())

        // Test symbol classification with invalid symbols
        assertFalse(g5.isTerminal("INVALID"))
        assertFalse(g5.isNonTerminal("invalid"))

        // Test that all productions have valid LHS
        g5.productions.forEach { prod ->
            assertTrue(g5.isNonTerminal(prod.lhs))
        }

        // Test that start symbol is a non-terminal
        assertTrue(g5.isNonTerminal(g5.startSymbol))
    }
}
