import kotlin.test.*

class FollowSetsTest {

    @Test
    fun testArithmeticGrammar() {
        val g1 = Grammar("grammars/g2_arithmetic.txt")
        val firstSets = FirstSets(g1)
        val followSets = FollowSets(g1, firstSets)

        val expectedFollowE = setOf("$", "+", ")")
        val expectedFollowT = setOf("$", "+", "*", ")")
        val expectedFollowF = setOf("$", "+", "*", ")")

        assertEquals(expectedFollowE, followSets.getFollow("E"))
        assertEquals(expectedFollowT, followSets.getFollow("T"))
        assertEquals(expectedFollowF, followSets.getFollow("F"))
    }

    @Test
    fun testGrammarWithEpsilon() {
        val g2 = Grammar("grammars/g3_with_epsilon.txt")
        val firstSets = FirstSets(g2)
        val followSets = FollowSets(g2, firstSets)

        val expectedFollowS = setOf("$")
        val expectedFollowA = setOf("b", "c")
        val expectedFollowB = setOf("c")

        assertEquals(expectedFollowS, followSets.getFollow("S"))
        assertEquals(expectedFollowA, followSets.getFollow("A"))
        assertEquals(expectedFollowB, followSets.getFollow("B"))
    }

    @Test
    fun testSimpleGrammar() {
        val g3 = Grammar("grammars/g1_simple.txt")
        val firstSets = FirstSets(g3)
        val followSets = FollowSets(g3, firstSets)

        // S can be followed by b (in S -> a S b)
        val expectedFollowS = setOf("$", "b")
        assertEquals(expectedFollowS, followSets.getFollow("S"))
    }
}
