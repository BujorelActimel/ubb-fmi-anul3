package main

import (
	"fmt"
	"strings"
)

type Position struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}

type FiniteAutomaton struct {
	States       []string                       `json:"states"`
	Alphabet     []string                       `json:"alphabet"`
	Transitions  map[string]map[string][]string `json:"transitions"`
	InitialState string                         `json:"initialState"`
	FinalStates  []string                       `json:"finalStates"`
	Positions    map[string]Position            `json:"positions,omitempty"`
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

// AddState adds a new state to the automaton
func (fa *FiniteAutomaton) AddState(name string) error {
	if name == "" {
		return fmt.Errorf("numele stării nu poate fi gol")
	}

	if contains(fa.States, name) {
		return fmt.Errorf("starea '%s' există deja", name)
	}

	fa.States = append(fa.States, name)

	// Initialize transitions map for the new state
	if fa.Transitions == nil {
		fa.Transitions = make(map[string]map[string][]string)
	}
	if fa.Transitions[name] == nil {
		fa.Transitions[name] = make(map[string][]string)
	}

	return nil
}

// RemoveState removes a state and all transitions involving it
func (fa *FiniteAutomaton) RemoveState(name string) error {
	if !contains(fa.States, name) {
		return fmt.Errorf("starea '%s' nu există", name)
	}

	// Cannot remove initial state if it's the only state
	if name == fa.InitialState && len(fa.States) == 1 {
		return fmt.Errorf("nu se poate șterge singura stare a automatului")
	}

	// Remove from states list
	newStates := make([]string, 0)
	for _, state := range fa.States {
		if state != name {
			newStates = append(newStates, state)
		}
	}
	fa.States = newStates

	// Remove from final states if present
	newFinalStates := make([]string, 0)
	for _, state := range fa.FinalStates {
		if state != name {
			newFinalStates = append(newFinalStates, state)
		}
	}
	fa.FinalStates = newFinalStates

	// Remove all transitions from this state
	delete(fa.Transitions, name)

	// Remove all transitions to this state
	for fromState := range fa.Transitions {
		for symbol, toStates := range fa.Transitions[fromState] {
			newToStates := make([]string, 0)
			for _, toState := range toStates {
				if toState != name {
					newToStates = append(newToStates, toState)
				}
			}
			if len(newToStates) > 0 {
				fa.Transitions[fromState][symbol] = newToStates
			} else {
				delete(fa.Transitions[fromState], symbol)
			}
		}
	}

	// Remove position if exists
	if fa.Positions != nil {
		delete(fa.Positions, name)
	}

	// If we removed the initial state, set a new one
	if name == fa.InitialState && len(fa.States) > 0 {
		fa.InitialState = fa.States[0]
	}

	return nil
}

// RenameState changes the name of a state and updates all references
func (fa *FiniteAutomaton) RenameState(oldName, newName string) error {
	if oldName == "" || newName == "" {
		return fmt.Errorf("numele stării nu poate fi gol")
	}

	if !contains(fa.States, oldName) {
		return fmt.Errorf("starea '%s' nu există", oldName)
	}

	if contains(fa.States, newName) {
		return fmt.Errorf("starea '%s' există deja", newName)
	}

	// Update states list
	for i, state := range fa.States {
		if state == oldName {
			fa.States[i] = newName
			break
		}
	}

	// Update initial state
	if fa.InitialState == oldName {
		fa.InitialState = newName
	}

	// Update final states
	for i, state := range fa.FinalStates {
		if state == oldName {
			fa.FinalStates[i] = newName
			break
		}
	}

	// Update transitions from this state
	if transitions, exists := fa.Transitions[oldName]; exists {
		fa.Transitions[newName] = transitions
		delete(fa.Transitions, oldName)
	}

	// Update transitions to this state
	for fromState := range fa.Transitions {
		for symbol, toStates := range fa.Transitions[fromState] {
			for i, toState := range toStates {
				if toState == oldName {
					fa.Transitions[fromState][symbol][i] = newName
				}
			}
		}
	}

	// Update position if exists
	if fa.Positions != nil {
		if pos, exists := fa.Positions[oldName]; exists {
			fa.Positions[newName] = pos
			delete(fa.Positions, oldName)
		}
	}

	return nil
}

// SetInitialState sets the initial state
func (fa *FiniteAutomaton) SetInitialState(state string) error {
	if !contains(fa.States, state) {
		return fmt.Errorf("starea '%s' nu există", state)
	}

	fa.InitialState = state
	return nil
}

// ToggleFinalState adds or removes a state from the final states
func (fa *FiniteAutomaton) ToggleFinalState(state string) error {
	if !contains(fa.States, state) {
		return fmt.Errorf("starea '%s' nu există", state)
	}

	if contains(fa.FinalStates, state) {
		// Remove from final states
		newFinalStates := make([]string, 0)
		for _, s := range fa.FinalStates {
			if s != state {
				newFinalStates = append(newFinalStates, s)
			}
		}
		fa.FinalStates = newFinalStates
	} else {
		// Add to final states
		fa.FinalStates = append(fa.FinalStates, state)
	}

	return nil
}

// SetStatePosition sets the visual position of a state
func (fa *FiniteAutomaton) SetStatePosition(state string, x, y float64) error {
	if !contains(fa.States, state) {
		return fmt.Errorf("starea '%s' nu există", state)
	}

	if fa.Positions == nil {
		fa.Positions = make(map[string]Position)
	}

	fa.Positions[state] = Position{X: x, Y: y}
	return nil
}

// AddTransition adds a transition between states
func (fa *FiniteAutomaton) AddTransition(from, symbol, to string) error {
	if !contains(fa.States, from) {
		return fmt.Errorf("starea '%s' nu există", from)
	}

	if !contains(fa.States, to) {
		return fmt.Errorf("starea '%s' nu există", to)
	}

	if !contains(fa.Alphabet, symbol) {
		return fmt.Errorf("simbolul '%s' nu este în alfabet", symbol)
	}

	if fa.Transitions == nil {
		fa.Transitions = make(map[string]map[string][]string)
	}

	if fa.Transitions[from] == nil {
		fa.Transitions[from] = make(map[string][]string)
	}

	// Check if transition already exists
	for _, existingTo := range fa.Transitions[from][symbol] {
		if existingTo == to {
			return fmt.Errorf("tranziția există deja")
		}
	}

	fa.Transitions[from][symbol] = append(fa.Transitions[from][symbol], to)
	return nil
}

// RemoveTransition removes a specific transition
func (fa *FiniteAutomaton) RemoveTransition(from, symbol, to string) error {
	if fa.Transitions == nil || fa.Transitions[from] == nil {
		return fmt.Errorf("tranziția nu există")
	}

	toStates := fa.Transitions[from][symbol]
	newToStates := make([]string, 0)
	found := false

	for _, state := range toStates {
		if state == to {
			found = true
		} else {
			newToStates = append(newToStates, state)
		}
	}

	if !found {
		return fmt.Errorf("tranziția nu există")
	}

	if len(newToStates) > 0 {
		fa.Transitions[from][symbol] = newToStates
	} else {
		delete(fa.Transitions[from], symbol)
	}

	return nil
}
