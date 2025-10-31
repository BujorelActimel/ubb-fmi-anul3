//go:build !wasm

package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	var fa *FiniteAutomaton

	fmt.Println("╔════════════════════════════════════════════════════╗")
	fmt.Println("║     Simulator Automate Finite                      ║")
	fmt.Println("╚════════════════════════════════════════════════════╝")
	fmt.Println()

	for {
		printMenu()
		fmt.Print("Alegeți o opțiune: ")

		if !scanner.Scan() {
			break
		}

		choice := strings.TrimSpace(scanner.Text())

		switch choice {
		case "1":
			fa = loadFromFile(scanner)
		case "2":
			fa = createManually(scanner)
		case "3":
			if fa == nil {
				fmt.Println("\nNu există automat încărcat! Încărcați mai întâi un automat.\n")
			} else {
				displayStates(fa)
			}
		case "4":
			if fa == nil {
				fmt.Println("\nNu există automat încărcat! Încărcați mai întâi un automat.\n")
			} else {
				displayAlphabet(fa)
			}
		case "5":
			if fa == nil {
				fmt.Println("\nNu există automat încărcat! Încărcați mai întâi un automat.\n")
			} else {
				displayTransitions(fa)
			}
		case "6":
			if fa == nil {
				fmt.Println("\nNu există automat încărcat! Încărcați mai întâi un automat.\n")
			} else {
				displayFinalStates(fa)
			}
		case "7":
			if fa == nil {
				fmt.Println("\nNu există automat încărcat! Încărcați mai întâi un automat.\n")
			} else {
				checkSequence(fa, scanner)
			}
		case "8":
			if fa == nil {
				fmt.Println("\nNu există automat încărcat! Încărcați mai întâi un automat.\n")
			} else {
				findLongestPrefix(fa, scanner)
			}
		case "9":
			if fa != nil {
				fmt.Println(fa.String())
			} else {
				fmt.Println("\nNu există automat încărcat!\n")
			}
		case "0":
			fmt.Println("\nLa revedere!")
			return
		default:
			fmt.Println("\nOpțiune invalidă! Încercați din nou.\n")
		}
	}
}

func printMenu() {
	fmt.Println("╔════════════════════════════════════════════════════╗")
	fmt.Println("║                    MENIU                           ║")
	fmt.Println("╠════════════════════════════════════════════════════╣")
	fmt.Println("║  1. Încarcă automat din fișier                     ║")
	fmt.Println("║  2. Creează automat manual                         ║")
	fmt.Println("║  3. Afișează stările                               ║")
	fmt.Println("║  4. Afișează alfabetul                             ║")
	fmt.Println("║  5. Afișează tranzițiile                           ║")
	fmt.Println("║  6. Afișează stările finale                        ║")
	fmt.Println("║  7. Verifică secvență                              ║")
	fmt.Println("║  8. Găsește cel mai lung prefix acceptat           ║")
	fmt.Println("║  9. Afișează automatul complet                     ║")
	fmt.Println("║  0. Ieșire                                         ║")
	fmt.Println("╚════════════════════════════════════════════════════╝")
	fmt.Println()
}

func loadFromFile(scanner *bufio.Scanner) *FiniteAutomaton {
	fmt.Print("\nIntroduceți calea către fișierul JSON: ")
	if !scanner.Scan() {
		return nil
	}

	filename := strings.TrimSpace(scanner.Text())
	fa, err := ParseFromFile(filename)

	if err != nil {
		fmt.Printf("\nEroare: %v\n\n", err)
		return nil
	}

	fmt.Println("\nAutomat încărcat cu succes!")
	fmt.Printf("Tip: %s\n", fa.typeString())
	fmt.Printf("Stări: %d, Alfabet: %d simboluri\n\n", len(fa.States), len(fa.Alphabet))

	return fa
}

func createManually(scanner *bufio.Scanner) *FiniteAutomaton {
	fmt.Println("\n=== Creare Automat Manual ===")

	fmt.Print("Introduceți stările (separate prin virgulă): ")
	if !scanner.Scan() {
		return nil
	}
	states := parseList(scanner.Text())

	fmt.Print("Introduceți alfabetul (simboluri separate prin virgulă): ")
	if !scanner.Scan() {
		return nil
	}
	alphabet := parseList(scanner.Text())

	fmt.Print("Introduceți starea inițială: ")
	if !scanner.Scan() {
		return nil
	}
	initialState := strings.TrimSpace(scanner.Text())

	fmt.Print("Introduceți stările finale (separate prin virgulă): ")
	if !scanner.Scan() {
		return nil
	}
	finalStates := parseList(scanner.Text())

	fmt.Println("\nIntroduceți tranzițiile (format: stare_sursa,simbol,stare_destinatie)")
	fmt.Println("Introduceți o linie goală pentru a termina:")

	transitions := make(map[string]map[string][]string)
	for {
		if !scanner.Scan() {
			break
		}
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			break
		}

		parts := strings.Split(line, ",")
		if len(parts) != 3 {
			fmt.Println("Format invalid! Folosiți: stare_sursa,simbol,stare_destinatie")
			continue
		}

		from := strings.TrimSpace(parts[0])
		symbol := strings.TrimSpace(parts[1])
		to := strings.TrimSpace(parts[2])

		if transitions[from] == nil {
			transitions[from] = make(map[string][]string)
		}
		transitions[from][symbol] = append(transitions[from][symbol], to)
	}

	fa := &FiniteAutomaton{
		States:       states,
		Alphabet:     alphabet,
		Transitions:  transitions,
		InitialState: initialState,
		FinalStates:  finalStates,
	}

	if err := fa.Validate(); err != nil {
		fmt.Printf("\nAutomat invalid: %v\n\n", err)
		return nil
	}

	fmt.Println("\nAutomat creat cu succes!")
	fmt.Printf("Tip: %s\n\n", fa.typeString())

	return fa
}

func displayStates(fa *FiniteAutomaton) {
	fmt.Println("\n=== Stări ===")
	fmt.Printf("Stări: {%s}\n", strings.Join(fa.States, ", "))
	fmt.Printf("Total: %d stări\n\n", len(fa.States))
}

func displayAlphabet(fa *FiniteAutomaton) {
	fmt.Println("\n=== Alfabet ===")
	fmt.Printf("Alfabet: {%s}\n", strings.Join(fa.Alphabet, ", "))
	fmt.Printf("Total: %d simboluri\n\n", len(fa.Alphabet))
}

func displayTransitions(fa *FiniteAutomaton) {
	fmt.Println("\n=== Tranziții ===")
	count := 0
	for state, transitions := range fa.Transitions {
		for symbol, nextStates := range transitions {
			for _, nextState := range nextStates {
				fmt.Printf("  %s --%s--> %s\n", state, symbol, nextState)
				count++
			}
		}
	}
	fmt.Printf("Total: %d tranziții\n\n", count)
}

func displayFinalStates(fa *FiniteAutomaton) {
	fmt.Println("\n=== Stări Finale ===")
	fmt.Printf("Stări finale: {%s}\n", strings.Join(fa.FinalStates, ", "))
	fmt.Printf("Total: %d stări finale\n\n", len(fa.FinalStates))
}

func checkSequence(fa *FiniteAutomaton, scanner *bufio.Scanner) {
	fmt.Print("\nIntroduceți secvența de verificat: ")
	if !scanner.Scan() {
		return
	}

	sequence := strings.TrimSpace(scanner.Text())
	result := fa.Simulate(sequence)

	fmt.Println("\n=== Rezultat Simulare ===")

	if result.Error != nil {
		displayError(result.Error)
	} else {
		fmt.Println("ACCEPTAT")
		fmt.Printf("Secvența '%s' este acceptată de automat.\n", sequence)
	}

	fmt.Printf("\nPași efectuați: %d\n", len(result.Steps))
	fmt.Printf("Stări finale: {%s}\n\n", strings.Join(result.FinalStates, ", "))

	fmt.Print("Doriți să vedeți pașii detaliat? (da/nu): ")
	if scanner.Scan() && strings.ToLower(strings.TrimSpace(scanner.Text())) == "da" {
		displaySteps(result.Steps, sequence)
	}
	fmt.Println()
}

func findLongestPrefix(fa *FiniteAutomaton, scanner *bufio.Scanner) {
	fmt.Print("\nIntroduceți secvența: ")
	if !scanner.Scan() {
		return
	}

	sequence := strings.TrimSpace(scanner.Text())
	longestPrefix, result := fa.LongestPrefix(sequence)

	fmt.Println("\n=== Cel Mai Lung Prefix Acceptat ===")

	if longestPrefix == "" {
		fmt.Println("Nu există niciun prefix acceptat.")
	} else {
		fmt.Printf("Cel mai lung prefix: '%s'\n", longestPrefix)
		fmt.Printf("Lungime: %d caractere\n", len(longestPrefix))
		fmt.Printf("Stări finale: {%s}\n", strings.Join(result.FinalStates, ", "))
	}
	fmt.Println()
}

func displayError(err *SimulationError) {
	switch err.Type {
	case "invalid_char":
		fmt.Println("CARACTER INVALID")
	case "no_transition":
		fmt.Println("TRANZIȚIE LIPSĂ")
	case "not_final":
		fmt.Println("RESPINS")
	}

	fmt.Printf("%s\n", err.Message)
	fmt.Printf("Poziție: %d\n", err.Position)
	if len(err.States) > 0 {
		fmt.Printf("Stări: {%s}\n", strings.Join(err.States, ", "))
	}
	if err.Symbol != "" {
		fmt.Printf("Simbol: '%s'\n", err.Symbol)
	}
}

func displaySteps(steps []Step, sequence string) {
	fmt.Println("\n=== Pași Detaliat ===")
	fmt.Printf("Stare inițială → (start)\n")

	for i, step := range steps {
		fmt.Printf("\nPasul %d:\n", i+1)
		fmt.Printf("  Caracter: '%s' (poziția %d)\n", step.Symbol, step.CharIndex)
		fmt.Printf("  Stări active: {%s}\n", strings.Join(step.ActiveStates, ", "))

		if len(step.Transitions) > 0 {
			fmt.Println("  Tranziții:")
			for _, t := range step.Transitions {
				fmt.Printf("    %s --%s--> %s\n", t.From, t.Symbol, t.To)
			}
		}
	}
	fmt.Println()
}

func parseList(input string) []string {
	parts := strings.Split(input, ",")
	result := make([]string, 0, len(parts))
	for _, part := range parts {
		trimmed := strings.TrimSpace(part)
		if trimmed != "" {
			result = append(result, trimmed)
		}
	}
	return result
}
