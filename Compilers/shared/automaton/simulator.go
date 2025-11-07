package automaton

import (
	"fmt"
	"strings"
)

func (fa *FiniteAutomaton) Simulate(input string) SimulationResult {
	if fa.IsDeterministic() {
		return fa.simulateAFD(input)
	}
	return fa.simulateAFND(input)
}

func (fa *FiniteAutomaton) simulateAFD(input string) SimulationResult {
	currentState := fa.InitialState
	steps := []Step{}

	for i, char := range input {
		symbol := string(char)

		if !fa.IsInAlphabet(symbol) {
			return SimulationResult{
				Accepted: false,
				Error: &SimulationError{
					Type:     "invalid_char",
					Position: i,
					States:   []string{currentState},
					Symbol:   symbol,
					Message:  fmt.Sprintf("Caracterul '%s' nu aparține alfabetului", symbol),
				},
				Steps:       steps,
				FinalStates: []string{currentState},
			}
		}

		nextStates, exists := fa.Transitions[currentState][symbol]
		if !exists || len(nextStates) == 0 {
			return SimulationResult{
				Accepted: false,
				Error: &SimulationError{
					Type:     "no_transition",
					Position: i,
					States:   []string{currentState},
					Symbol:   symbol,
					Message:  fmt.Sprintf("Nu există tranziție din %s cu simbolul '%s'", currentState, symbol),
				},
				Steps:       steps,
				FinalStates: []string{currentState},
			}
		}

		nextState := nextStates[0]
		steps = append(steps, Step{
			ActiveStates: []string{nextState},
			CharIndex:    i,
			Symbol:       symbol,
			Transitions: []Transition{{
				From:   currentState,
				To:     nextState,
				Symbol: symbol,
			}},
		})
		currentState = nextState
	}

	accepted := fa.IsFinalState(currentState)
	result := SimulationResult{
		Accepted:    accepted,
		Steps:       steps,
		FinalStates: []string{currentState},
	}

	if !accepted {
		result.Error = &SimulationError{
			Type:     "not_final",
			Position: len(input),
			States:   []string{currentState},
			Symbol:   "",
			Message:  fmt.Sprintf("Starea finală %s nu este acceptoare", currentState),
		}
	}

	return result
}

func (fa *FiniteAutomaton) simulateAFND(input string) SimulationResult {
	activeStates := map[string]bool{fa.InitialState: true}
	steps := []Step{}

	for i, char := range input {
		symbol := string(char)

		if !fa.IsInAlphabet(symbol) {
			return SimulationResult{
				Accepted: false,
				Error: &SimulationError{
					Type:     "invalid_char",
					Position: i,
					States:   getKeys(activeStates),
					Symbol:   symbol,
					Message:  fmt.Sprintf("Caracterul '%s' nu aparține alfabetului", symbol),
				},
				Steps:       steps,
				FinalStates: getKeys(activeStates),
			}
		}

		nextStates := make(map[string]bool)
		transitions := []Transition{}

		for state := range activeStates {
			if nexts, exists := fa.Transitions[state][symbol]; exists {
				for _, next := range nexts {
					nextStates[next] = true
					transitions = append(transitions, Transition{
						From:   state,
						To:     next,
						Symbol: symbol,
					})
				}
			}
		}

		if len(nextStates) == 0 {
			return SimulationResult{
				Accepted: false,
				Error: &SimulationError{
					Type:     "no_transition",
					Position: i,
					States:   getKeys(activeStates),
					Symbol:   symbol,
					Message: fmt.Sprintf("Nicio tranziție disponibilă din stările {%s} cu simbolul '%s'",
						strings.Join(getKeys(activeStates), ", "), symbol),
				},
				Steps:       steps,
				FinalStates: getKeys(activeStates),
			}
		}

		steps = append(steps, Step{
			ActiveStates: getKeys(nextStates),
			CharIndex:    i,
			Symbol:       symbol,
			Transitions:  transitions,
		})

		activeStates = nextStates
	}

	finalStatesReached := getKeys(activeStates)
	accepted := false
	for state := range activeStates {
		if fa.IsFinalState(state) {
			accepted = true
			break
		}
	}

	result := SimulationResult{
		Accepted:    accepted,
		Steps:       steps,
		FinalStates: finalStatesReached,
	}

	if !accepted {
		result.Error = &SimulationError{
			Type:     "not_final",
			Position: len(input),
			States:   finalStatesReached,
			Symbol:   "",
			Message: fmt.Sprintf("Stările finale {%s} nu conțin stări acceptoare",
				strings.Join(finalStatesReached, ", ")),
		}
	}

	return result
}

func (fa *FiniteAutomaton) LongestPrefix(input string) (string, SimulationResult) {
	longestAcceptedPrefix := ""
	var longestResult SimulationResult

	for i := 1; i <= len(input); i++ {
		prefix := input[:i]
		result := fa.Simulate(prefix)

		if result.Accepted {
			longestAcceptedPrefix = prefix
			longestResult = result
		}
	}

	return longestAcceptedPrefix, longestResult
}
