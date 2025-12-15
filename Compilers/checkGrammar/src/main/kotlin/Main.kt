import kotlin.text.trim
import java.io.File

fun main() {
    val input = File("grammar").readText()
    val grammar = Grammar(input)

    if (grammar.checkRegular()) {
        println("regular")
    } else {
        println("NOT regular")
    }
}

class Grammar(val input: String) {
    fun checkRegular(): Boolean {
        var productions = input.lines()

        if (productions[0].isEmpty() || productions[0].isBlank()) {
            return false
        }

        if (!productions[0].hasRegularForm(epsilon=true)) {
            return false
        }
        productions = productions.drop(1)

        for (production in productions) {
            if (production.isEmpty() || production.isBlank()) {
                continue
            }
            if (!production.hasRegularForm()) {
                return false
            }
        }
        return true
    }

    private fun String.hasRegularForm(epsilon: Boolean = false): Boolean {
        val (left, right) = this.split("->").map{ it -> it.trim() }

        // aB -> a NOPE
        // b -> a  NOPE
        if (left.length != 1 || left.first().isLowerCase()) {
            return false
        }

        // S ->   -> OK
        if (!epsilon) {
            if (right.length < 1) {
                return false
            }
        }

        // A -> A NOPE
        if (right.length == 1) {
            return right.first().isLowerCase()
        }

        // A -> abc..defA -> OK
        // A -> aa        -> OK
        for (symbol in right.dropLast(1)) {
            if (symbol.isUpperCase()) {
                return false
            }
        }

        return true
    }
}
