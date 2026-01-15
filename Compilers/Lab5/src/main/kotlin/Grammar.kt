import java.io.File

class Grammar(filePath: String) {
    val nonTerminals: MutableSet<String> = mutableSetOf()
    val terminals: MutableSet<String> = mutableSetOf()
    var startSymbol: String = ""
    val productions: MutableList<Production> = mutableListOf()

    init {
        parseGrammarFile(filePath)
    }

    private fun parseGrammarFile(filePath: String) {
        val lines = File(filePath).readLines()
        var firstProduction = true

        lines.forEach {line -> 
            val trimmedLine = line.trim()

            if (
                trimmedLine.isEmpty() || 
                trimmedLine.isBlank() ||
                trimmedLine.startsWith("//") ||
                trimmedLine.startsWith("#")
            ) {
                // skip empty lines and comments
                return@forEach
            }

            require("->" in line) { 
                "Invalid rule, missing '->': $line" 
            }
            val (lhs, rhs) = line.split("->", limit = 2).map(String::trim)

            require(lhs.split(" ").size == 1) {
                "Invalid production, should have only one non-terminal on lhs: $line" 
            }
            require(hasNonTerminalForm(lhs)) {
                "Invalid production, lhs must be a single uppercase non-terminal: $line"
            }
            if (firstProduction) {
                startSymbol = lhs
                firstProduction = false
            }
            nonTerminals.add(lhs)

            val rhsElements = if (rhs.isEmpty()) emptyList() else rhs.split(" ")

            // handle epsilon production
            if (
                rhsElements.size == 0 ||
                rhsElements == listOf("epsilon") ||
                rhsElements == listOf("ε")
            ) {
                productions.add(Production(lhs, emptyList()))
                return@forEach
            }

            rhsElements.forEach { symbol ->
                if (hasNonTerminalForm(symbol)) {
                    nonTerminals.add(symbol)
                }
                else {
                    terminals.add(symbol)
                }
            }

            productions.add(Production(lhs, rhsElements))
        }
    }

    private fun hasNonTerminalForm(symbol: String): Boolean {
        return symbol.all { it in 'A'..'Z' || it == '\'' }
    }

    fun isTerminal(symbol: String): Boolean {
        return symbol in terminals
    }

    fun isNonTerminal(symbol: String): Boolean {
        return symbol in nonTerminals
    }

    fun getProductionsFor(nonTerminal: String): List<Production> {
        return productions.filter { it.lhs == nonTerminal }
    }

    fun augmentGrammar() {
        val newStart = startSymbol + "'"
        nonTerminals.add(newStart)
        val augmentedProd = Production(newStart, listOf(startSymbol))
        productions.add(0, augmentedProd)
        startSymbol = newStart
    }

    fun print() {
        println("=== Grammar ===")
        println("Non-terminals: ${nonTerminals.joinToString(", ")}")
        println("Terminals: ${terminals.joinToString(", ")}")
        println("Start Symbol: $startSymbol")
        println("\nProductions:")
        productions.forEachIndexed { index, prod ->
            println("$index: $prod")
        }
        println("===============\n")
    }
}

data class Production(
    val lhs: String,
    val rhs: List<String>
) {
    fun isEpsilon(): Boolean {
        return rhs.isEmpty()
    }

    override fun toString(): String {
        val rhsStr = if (isEpsilon()) "ε" else rhs.joinToString(" ")
        return "$lhs -> $rhsStr"
    }
}
