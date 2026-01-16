import java.io.File

class MLPTokenizer(private val source: String) {
    private var position = 0
    private val tokens = mutableListOf<String>()

    private val keywords = setOf(
        "package", "import", "const", "var", "type", "struct",
        "func", "return", "if", "else", "for",
        "int", "float32", "float64", "string", "bool"
    )

    private val multiCharOps = mapOf(
        ":=" to "colonassign",
        "==" to "eq",
        "!=" to "neq",
        "<=" to "lte",
        ">=" to "gte",
        "&&" to "and",
        "||" to "or",
        "+=" to "plusassign",
        "-=" to "minusassign",
        "*=" to "multassign",
        "/=" to "divassign",
        "%=" to "modassign"
    )

    private val singleCharTokens = mapOf(
        '=' to "assign",
        '+' to "plus",
        '-' to "minus",
        '*' to "mult",
        '/' to "div",
        '%' to "mod",
        '<' to "lt",
        '>' to "gt",
        '!' to "not",
        '&' to "ampersand",
        '(' to "lparen",
        ')' to "rparen",
        '{' to "lbrace",
        '}' to "rbrace",
        ',' to "comma",
        ';' to "semicolon",
        '.' to "dot",
        ':' to "colon"
    )

    fun tokenize(): List<String> {
        while (position < source.length) {
            skipWhitespace()
            if (position >= source.length) break

            when {
                tryReadComment() -> continue
                tryReadString() -> continue
                tryReadNumber() -> continue
                tryReadIdentifierOrKeyword() -> continue
                tryReadMultiCharOperator() -> continue
                tryReadSingleCharToken() -> continue
                else -> {
                    position++
                }
            }
        }
        return tokens
    }

    private fun skipWhitespace() {
        while (position < source.length && source[position].isWhitespace()) {
            position++
        }
    }

    private fun tryReadComment(): Boolean {
        if (position + 1 < source.length && source[position] == '/' && source[position + 1] == '/') {
            while (position < source.length && source[position] != '\n') {
                position++
            }
            return true
        }
        if (position + 1 < source.length && source[position] == '/' && source[position + 1] == '*') {
            position += 2
            while (position + 1 < source.length) {
                if (source[position] == '*' && source[position + 1] == '/') {
                    position += 2
                    break
                }
                position++
            }
            return true
        }
        return false
    }

    private fun tryReadString(): Boolean {
        if (source[position] != '"') return false

        val start = position
        position++

        while (position < source.length && source[position] != '"') {
            if (source[position] == '\\') {
                position++
            }
            position++
        }

        if (position < source.length) {
            position++
        }

        val stringValue = source.substring(start, position)

        if (stringValue.matches(Regex("\"%(d|s).*\""))) {
            tokens.add("fmtstr")
        } else {
            tokens.add("string")
        }

        return true
    }

    private fun tryReadNumber(): Boolean {
        if (!source[position].isDigit()) return false

        val start = position
        while (position < source.length && (source[position].isDigit() || source[position] == '.')) {
            position++
        }

        val numValue = source.substring(start, position)
        if (numValue.contains('.')) {
            tokens.add("floatconst")
        } else {
            tokens.add("intconst")
        }

        return true
    }

    private fun tryReadIdentifierOrKeyword(): Boolean {
        if (!source[position].isLetter() && source[position] != '_') return false

        val start = position
        while (position < source.length &&
               (source[position].isLetterOrDigit() || source[position] == '_')) {
            position++
        }

        if (position < source.length && source[position] == '.') {
            val firstPart = source.substring(start, position)
            position++

            val dotStart = position
            while (position < source.length &&
                   (source[position].isLetterOrDigit() || source[position] == '_')) {
                position++
            }
            val secondPart = source.substring(dotStart, position)

            when ("$firstPart.$secondPart") {
                "fmt.Printf" -> tokens.add("printf")
                "fmt.Scanf" -> tokens.add("scanf")
                else -> {
                    tokens.add("id")
                    tokens.add("dot")
                    tokens.add("id")
                }
            }
            return true
        }

        val identifier = source.substring(start, position)

        if (identifier in keywords) {
            tokens.add(identifier)
        } else {
            tokens.add("id")
        }

        return true
    }

    private fun tryReadMultiCharOperator(): Boolean {
        if (position + 1 >= source.length) return false

        val twoChars = source.substring(position, position + 2)
        val tokenName = multiCharOps[twoChars]

        if (tokenName != null) {
            tokens.add(tokenName)
            position += 2
            return true
        }

        return false
    }

    private fun tryReadSingleCharToken(): Boolean {
        val char = source[position]
        val tokenName = singleCharTokens[char]

        if (tokenName != null) {
            tokens.add(tokenName)
            position++
            return true
        }

        return false
    }

    companion object {
        fun tokenizeFile(filePath: String): List<String> {
            val source = File(filePath).readText()
            return MLPTokenizer(source).tokenize()
        }
    }
}
