import java.io.File

fun main(args: Array<String>) {
    if (args.isEmpty()) {
        printUsage()
        return
    }

    when (args[0]) {
        "--check-slr" -> {
            if (args.size < 2) {
                println("Error: Missing grammar file argument")
                printUsage()
                return
            }
            checkIfSLR(args[1])
        }
        "--first-follow" -> {
            if (args.size < 2) {
                println("Error: Missing grammar file argument")
                printUsage()
                return
            }
            showFirstFollow(args[1])
        }
        "--help" -> {
            printUsage()
        }
        else -> {
            // Default: parse input sequence
            if (args.size < 2) {
                println("Error: Missing input file argument")
                printUsage()
                return
            }
            parseInput(args[0], args[1])
        }
    }
}

fun parseInput(grammarFile: String, inputFile: String) {
    try {
        println("=== SLR Parser ===\n")
        println("Grammar file: $grammarFile")
        println("Input file: $inputFile\n")

        val grammar = Grammar(grammarFile)

        grammar.augmentGrammar()

        val firstSets = FirstSets(grammar)
        val followSets = FollowSets(grammar, firstSets)

        val automaton = LRAutomaton(grammar, firstSets)

        val slrTable = SLRTable(grammar, automaton, followSets)

        if (!slrTable.isSLR()) {
            println("ERROR: Grammar is not SLR!")
            println("Conflicts found:")
            for (conflict in slrTable.getConflicts()) {
                println(conflict)
            }
            return
        }

        val parser = SLRParser(grammar, slrTable)

        println("Tokenizing: $inputFile")
        val tokens = MLPTokenizer.tokenizeFile(inputFile)
        println("Tokens: ${tokens.joinToString(" ")}\n")

        val result = parser.parse(tokens)

        println(result)

    } catch (e: Exception) {
        println("Error: ${e.message}")
        e.printStackTrace()
    }
}

fun checkIfSLR(grammarFile: String) {
    try {
        println("=== Checking if Grammar is SLR ===\n")
        println("Grammar file: $grammarFile\n")

        val grammar = Grammar(grammarFile)
        grammar.print()

        grammar.augmentGrammar()

        val firstSets = FirstSets(grammar)
        val followSets = FollowSets(grammar, firstSets)

        firstSets.print()
        followSets.print()

        val automaton = LRAutomaton(grammar, firstSets)
        println("Number of states: ${automaton.getStates().size}")
        println("Number of transitions: ${automaton.getAllTransitions().size}\n")

        val slrTable = SLRTable(grammar, automaton, followSets)

        if (slrTable.isSLR()) {
            println("Grammar is SLR (no conflicts)\n")
            slrTable.print()
        } else {
            println("Grammar is NOT SLR\n")
            println("Conflicts found:")
            for (conflict in slrTable.getConflicts()) {
                println(conflict)
                println()
            }
        }

    } catch (e: Exception) {
        println("Error: ${e.message}")
        e.printStackTrace()
    }
}

fun showFirstFollow(grammarFile: String) {
    try {
        println("=== Computing FIRST and FOLLOW Sets ===\n")
        println("Grammar file: $grammarFile\n")

        val grammar = Grammar(grammarFile)
        grammar.print()

        val firstSets = FirstSets(grammar)
        firstSets.print()

        val followSets = FollowSets(grammar, firstSets)
        followSets.print()

    } catch (e: Exception) {
        println("Error: ${e.message}")
        e.printStackTrace()
    }
}

fun printUsage() {
    println("""
        SLR Parser - Command Line Interface

        Usage:
          1. Parse input sequence:
             ./gradlew run --args="<grammar_file> <input_file>"

          2. Check if grammar is SLR:
             ./gradlew run --args="--check-slr <grammar_file>"

          3. Show FIRST and FOLLOW sets:
             ./gradlew run --args="--first-follow <grammar_file>"

          4. Show this help message:
             ./gradlew run --args="--help"

        Examples:
          ./gradlew run --args="grammars/g2_arithmetic.txt inputs/expr1.txt"
          ./gradlew run --args="--check-slr grammars/g2_arithmetic.txt"
          ./gradlew run --args="--first-follow grammars/g2_arithmetic.txt"

        Grammar file format:
          <production 1>
          <production 2>
          ...

          Productions use format: LHS -> RHS
          Non-terminals: Uppercase letters (A-Z)
          Terminals: Everything else
          Epsilon: Empty RHS or "epsilon" or "ε"
          First production's LHS is the start symbol

        Input file format:
          Space-separated sequence of terminal symbols

        To run tests:
          ./gradlew test
    """.trimIndent())
}
