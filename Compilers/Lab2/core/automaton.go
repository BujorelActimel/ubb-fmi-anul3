package main

import (
	"fmt"
	"strings"
)

type FiniteAutomaton struct {
	States       []string                       `json:"states"`
	Alphabet     []string                       `json:"alphabet"`
	Transitions  map[string]map[string][]string `json:"transitions"`
	InitialState string                         `json:"initialState"`
	FinalStates  []string                       `json:"finalStates"`
}

type SimulationResult struct {
	Accepted    bool             `json:"accepted"`
	Error       *SimulationError `json:"error,omitempty"`
	Steps       []Step           `json:"steps"`
	FinalStates []string         `json:"finalStates"`
}

type SimulationError struct {
	Type     string   `json:"type"` // "invalid_char", "no_transition", "not_final"
	Position int      `json:"position"`
	States   []string `json:"states"`
	Symbol   string   `json:"symbol"`
	Message  string   `json:"message"`
}

type Step struct {
	ActiveStates []string     `json:"activeStates"`
	CharIndex    int          `json:"charIndex"`
	Symbol       string       `json:"symbol"`
	Transitions  []Transition `json:"transitions"`
}

type Transition struct {
	From   string `json:"from"`
	To     string `json:"to"`
	Symbol string `json:"symbol"`
}

func (fa *FiniteAutomaton) IsDeterministic() bool {
	for state := range fa.Transitions {
		for _, nextStates := range fa.Transitions[state] {
			if len(nextStates) > 1 {
				return false
			}
		}
	}
	return true
}

func (fa *FiniteAutomaton) Validate() error {
	if len(fa.States) == 0 {
		return fmt.Errorf("automatul trebuie să aibă cel puțin o stare")
	}

	if len(fa.Alphabet) == 0 {
		return fmt.Errorf("automatul trebuie să aibă cel puțin un simbol în alfabet")
	}

	if !contains(fa.States, fa.InitialState) {
		return fmt.Errorf("starea inițială '%s' nu există în mulțimea stărilor", fa.InitialState)
	}

	for _, finalState := range fa.FinalStates {
		if !contains(fa.States, finalState) {
			return fmt.Errorf("starea finală '%s' nu există în mulțimea stărilor", finalState)
		}
	}

	for fromState, transitions := range fa.Transitions {
		if !contains(fa.States, fromState) {
			return fmt.Errorf("starea '%s' din tranziții nu există în mulțimea stărilor", fromState)
		}

		for symbol, toStates := range transitions {
			if !contains(fa.Alphabet, symbol) {
				return fmt.Errorf("simbolul '%s' din tranziții nu există în alfabet", symbol)
			}

			for _, toState := range toStates {
				if !contains(fa.States, toState) {
					return fmt.Errorf("starea '%s' din tranziții nu există în mulțimea stărilor", toState)
				}
			}
		}
	}

	return nil
}

func (fa *FiniteAutomaton) IsInAlphabet(symbol string) bool {
	return contains(fa.Alphabet, symbol)
}

func (fa *FiniteAutomaton) GetTransitionsFrom(state string) map[string][]string {
	if transitions, exists := fa.Transitions[state]; exists {
		return transitions
	}
	return make(map[string][]string)
}

func (fa *FiniteAutomaton) IsFinalState(state string) bool {
	return contains(fa.FinalStates, state)
}

func (fa *FiniteAutomaton) String() string {
	var sb strings.Builder

	sb.WriteString("=== Automat Finit ===\n\n")

	sb.WriteString(fmt.Sprintf("Tip: %s\n\n", fa.typeString()))

	sb.WriteString(fmt.Sprintf("Stări: {%s}\n", strings.Join(fa.States, ", ")))
	sb.WriteString(fmt.Sprintf("Alfabet: {%s}\n", strings.Join(fa.Alphabet, ", ")))
	sb.WriteString(fmt.Sprintf("Stare inițială: %s\n", fa.InitialState))
	sb.WriteString(fmt.Sprintf("Stări finale: {%s}\n\n", strings.Join(fa.FinalStates, ", ")))

	sb.WriteString("Tranziții:\n")
	for state, transitions := range fa.Transitions {
		for symbol, nextStates := range transitions {
			for _, nextState := range nextStates {
				sb.WriteString(fmt.Sprintf("  %s --%s--> %s\n", state, symbol, nextState))
			}
		}
	}

	return sb.String()
}

func (fa *FiniteAutomaton) typeString() string {
	if fa.IsDeterministic() {
		return "AFD (Automat Finit Determinist)"
	}
	return "AFND (Automat Finit Nedeterminist)"
}

func contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

func getKeys(m map[string]bool) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	return keys
}
