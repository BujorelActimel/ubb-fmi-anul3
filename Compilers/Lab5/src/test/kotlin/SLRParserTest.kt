import kotlin.test.*

class SLRParserTest {

    @Test
    fun testValidArithmeticExpressions() {
        val g1 = Grammar("grammars/g2_arithmetic.txt")
        g1.augmentGrammar()
        val firstSets = FirstSets(g1)
        val followSets = FollowSets(g1, firstSets)
        val automaton = LRAutomaton(g1, firstSets)
        val slrTable = SLRTable(g1, automaton, followSets)
        val parser = SLRParser(g1, slrTable)

        // Test: id
        val result1 = parser.parse("id")
        assertTrue(result1 is ParseResult.Success)

        // Test: id + id
        val result2 = parser.parse("id + id")
        assertTrue(result2 is ParseResult.Success)

        // Test: id * id
        val result3 = parser.parse("id * id")
        assertTrue(result3 is ParseResult.Success)

        // Test: id + id * id
        val result4 = parser.parse("id + id * id")
        assertTrue(result4 is ParseResult.Success)

        // Test: ( id + id ) * id
        val result5 = parser.parse("( id + id ) * id")
        assertTrue(result5 is ParseResult.Success)
    }

    @Test
    fun testInvalidArithmeticExpressions() {
        val g2 = Grammar("grammars/g2_arithmetic.txt")
        g2.augmentGrammar()
        val firstSets = FirstSets(g2)
        val followSets = FollowSets(g2, firstSets)
        val automaton = LRAutomaton(g2, firstSets)
        val slrTable = SLRTable(g2, automaton, followSets)
        val parser = SLRParser(g2, slrTable)

        // Test: id + (incomplete)
        val result1 = parser.parse("id +")
        assertTrue(result1 is ParseResult.Error)

        // Test: + id (starts with operator)
        val result2 = parser.parse("+ id")
        assertTrue(result2 is ParseResult.Error)

        // Test: id id (missing operator)
        val result3 = parser.parse("id id")
        assertTrue(result3 is ParseResult.Error)

        // Test: ( id (unmatched parenthesis)
        val result4 = parser.parse("( id")
        assertTrue(result4 is ParseResult.Error)
    }

    @Test
    fun testSimpleGrammar() {
        val g3 = Grammar("grammars/g1_simple.txt")
        g3.augmentGrammar()
        val firstSets = FirstSets(g3)
        val followSets = FollowSets(g3, firstSets)
        val automaton = LRAutomaton(g3, firstSets)
        val slrTable = SLRTable(g3, automaton, followSets)
        val parser = SLRParser(g3, slrTable)

        // Valid: a b
        val result1 = parser.parse("a b")
        assertTrue(result1 is ParseResult.Success)

        // Valid: a a b b
        val result2 = parser.parse("a a b b")
        assertTrue(result2 is ParseResult.Success)

        // Valid: a a a b b b
        val result3 = parser.parse("a a a b b b")
        assertTrue(result3 is ParseResult.Success)

        // Invalid: a b b
        val result4 = parser.parse("a b b")
        assertTrue(result4 is ParseResult.Error)
    }

    @Test
    fun testGrammarWithEpsilon() {
        val g4 = Grammar("grammars/g3_with_epsilon.txt")
        g4.augmentGrammar()
        val firstSets = FirstSets(g4)
        val followSets = FollowSets(g4, firstSets)
        val automaton = LRAutomaton(g4, firstSets)
        val slrTable = SLRTable(g4, automaton, followSets)
        val parser = SLRParser(g4, slrTable)

        // Test: c (A and B both epsilon)
        val result1 = parser.parse("c")
        assertTrue(result1 is ParseResult.Success)

        // Test: a c (A = a, B = epsilon)
        val result2 = parser.parse("a c")
        assertTrue(result2 is ParseResult.Success)

        // Test: b c (A = epsilon, B = b)
        val result3 = parser.parse("b c")
        assertTrue(result3 is ParseResult.Success)

        // Test: a b c
        val result4 = parser.parse("a b c")
        assertTrue(result4 is ParseResult.Success)

        // Test: a a b b c
        val result5 = parser.parse("a a b b c")
        assertTrue(result5 is ParseResult.Success)
    }
}
