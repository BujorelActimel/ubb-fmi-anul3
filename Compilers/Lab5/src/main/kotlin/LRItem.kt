data class LRItem(
    val production: Production,
    val dotPosition: Int
) {
    fun nextSymbol(): String? {
        return if (dotPosition < production.rhs.size) {
            production.rhs[dotPosition]
        } else {
            null
        }
    }

    fun isComplete(): Boolean {
        return dotPosition >= production.rhs.size
    }

    fun advance(): LRItem {
        require(!isComplete()) { "Cannot advance a complete item" }
        return LRItem(production, dotPosition + 1)
    }

    fun symbolsAfterDot(): List<String> {
        return if (dotPosition < production.rhs.size) {
            production.rhs.subList(dotPosition, production.rhs.size)
        } else {
            emptyList()
        }
    }

    override fun toString(): String {
        val rhs = production.rhs.toMutableList()
        rhs.add(dotPosition, "•")
        val rhsStr = if (production.isEpsilon()) {
            "• ε"
        } else {
            rhs.joinToString(" ")
        }
        return "${production.lhs} -> $rhsStr"
    }
}
