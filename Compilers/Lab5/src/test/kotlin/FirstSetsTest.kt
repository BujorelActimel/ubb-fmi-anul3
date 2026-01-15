import kotlin.test.*

class FirstSetsTest {

    @Test
    fun testArithmeticGrammarNoEpsilon() {
        val g1 = Grammar("grammars/g2_arithmetic.txt")
        val firstSets = FirstSets(g1)

        val expectedFirstE = setOf("(", "id")
        val expectedFirstT = setOf("(", "id")
        val expectedFirstF = setOf("(", "id")

        assertEquals(expectedFirstE, firstSets.getFirst("E"))
        assertEquals(expectedFirstT, firstSets.getFirst("T"))
        assertEquals(expectedFirstF, firstSets.getFirst("F"))

        // Test terminals
        assertEquals(setOf("+"), firstSets.getFirst("+"))
        assertEquals(setOf("id"), firstSets.getFirst("id"))

        // Test epsilon derivation
        assertFalse(firstSets.canDeriveEpsilon("E"))
        assertFalse(firstSets.canDeriveEpsilon("T"))
    }

    @Test
    fun testGrammarWithEpsilon() {
        val g2 = Grammar("grammars/g3_with_epsilon.txt")
        val firstSets = FirstSets(g2)

        // NO epsilon in FIRST sets - tracked separately in nullable
        val expectedFirstS = setOf("a", "b", "c")
        val expectedFirstA = setOf("a")
        val expectedFirstB = setOf("b")

        assertEquals(expectedFirstS, firstSets.getFirst("S"))
        assertEquals(expectedFirstA, firstSets.getFirst("A"))
        assertEquals(expectedFirstB, firstSets.getFirst("B"))

        // Test epsilon derivation
        assertTrue(firstSets.canDeriveEpsilon("A"))
        assertTrue(firstSets.canDeriveEpsilon("B"))
        assertFalse(firstSets.canDeriveEpsilon("S"))
    }

    @Test
    fun testFirstOfStringSequences() {
        val g3 = Grammar("grammars/g3_with_epsilon.txt")
        val firstSets = FirstSets(g3)

        // FIRST(A B c)
        assertEquals(setOf("a", "b", "c"), firstSets.firstOfString(listOf("A", "B", "c")))

        // FIRST(A a)
        assertEquals(setOf("a"), firstSets.firstOfString(listOf("A", "a")))

        // FIRST(c)
        assertEquals(setOf("c"), firstSets.firstOfString(listOf("c")))

        // FIRST(A B) where both are nullable - NO ε in result
        assertEquals(setOf("a", "b"), firstSets.firstOfString(listOf("A", "B")))
    }

    @Test
    fun testCanDeriveEpsilonFromSequence() {
        val g = Grammar("grammars/g3_with_epsilon.txt")
        val firstSets = FirstSets(g)

        // Both nullable
        assertTrue(firstSets.canDeriveEpsilonFromSequence(listOf("A", "B")))

        // One not nullable
        assertFalse(firstSets.canDeriveEpsilonFromSequence(listOf("A", "c")))

        // Empty sequence
        assertTrue(firstSets.canDeriveEpsilonFromSequence(emptyList()))
    }

    @Test
    fun testSimpleGrammar() {
        val g4 = Grammar("grammars/g1_simple.txt")
        val firstSets = FirstSets(g4)

        assertEquals(setOf("a"), firstSets.getFirst("S"))
        assertFalse(firstSets.canDeriveEpsilon("S"))
    }
}
