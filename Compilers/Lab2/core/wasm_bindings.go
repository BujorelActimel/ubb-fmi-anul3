//go:build js && wasm

package main

import (
	"syscall/js"
)

func main() {
	js.Global().Set("parseAutomaton", js.FuncOf(parseAutomatonWASM))
	js.Global().Set("simulateSequence", js.FuncOf(simulateSequenceWASM))
	js.Global().Set("findLongestPrefix", js.FuncOf(findLongestPrefixWASM))

	// Edit operations
	js.Global().Set("addState", js.FuncOf(addStateWASM))
	js.Global().Set("removeState", js.FuncOf(removeStateWASM))
	js.Global().Set("renameState", js.FuncOf(renameStateWASM))
	js.Global().Set("setInitialState", js.FuncOf(setInitialStateWASM))
	js.Global().Set("toggleFinalState", js.FuncOf(toggleFinalStateWASM))
	js.Global().Set("setStatePosition", js.FuncOf(setStatePositionWASM))
	js.Global().Set("addTransition", js.FuncOf(addTransitionWASM))
	js.Global().Set("removeTransition", js.FuncOf(removeTransitionWASM))
	js.Global().Set("getAutomatonJSON", js.FuncOf(getAutomatonJSONWASM))

	<-make(chan bool)
}

func parseAutomatonWASM(this js.Value, args []js.Value) interface{} {
	if len(args) != 1 {
		return map[string]interface{}{
			"error": "Se așteaptă exact un argument (JSON string)",
		}
	}

	jsonStr := args[0].String()
	fa, err := ParseFromJSON(jsonStr)
	if err != nil {
		return map[string]interface{}{
			"error": err.Error(),
		}
	}

	return map[string]interface{}{
		"success":        true,
		"isDeterministic": fa.IsDeterministic(),
		"states":         len(fa.States),
		"alphabet":       len(fa.Alphabet),
		"type":           fa.typeString(),
	}
}

func simulateSequenceWASM(this js.Value, args []js.Value) interface{} {
	if len(args) != 2 {
		return map[string]interface{}{
			"error": "Se așteaptă 2 argumente (JSON automat, secvență)",
		}
	}

	jsonStr := args[0].String()
	sequence := args[1].String()

	fa, err := ParseFromJSON(jsonStr)
	if err != nil {
		return map[string]interface{}{
			"error": err.Error(),
		}
	}

	result := fa.Simulate(sequence)

	return serializeSimulationResult(result)
}

func findLongestPrefixWASM(this js.Value, args []js.Value) interface{} {
	if len(args) != 2 {
		return map[string]interface{}{
			"error": "Se așteaptă 2 argumente (JSON automat, secvență)",
		}
	}

	jsonStr := args[0].String()
	sequence := args[1].String()

	fa, err := ParseFromJSON(jsonStr)
	if err != nil {
		return map[string]interface{}{
			"error": err.Error(),
		}
	}

	longestPrefix, result := fa.LongestPrefix(sequence)

	response := serializeSimulationResult(result)
	response["longestPrefix"] = longestPrefix

	return response
}

func serializeSimulationResult(result SimulationResult) map[string]interface{} {
	finalStatesArr := make([]interface{}, len(result.FinalStates))
	for i, s := range result.FinalStates {
		finalStatesArr[i] = s
	}

	response := map[string]interface{}{
		"accepted":    result.Accepted,
		"finalStates": finalStatesArr,
	}

	steps := make([]interface{}, len(result.Steps))
	for i, step := range result.Steps {
		activeStatesArr := make([]interface{}, len(step.ActiveStates))
		for j, s := range step.ActiveStates {
			activeStatesArr[j] = s
		}

		transitions := make([]interface{}, len(step.Transitions))
		for j, t := range step.Transitions {
			transitions[j] = map[string]interface{}{
				"from":   t.From,
				"to":     t.To,
				"symbol": t.Symbol,
			}
		}

		steps[i] = map[string]interface{}{
			"activeStates": activeStatesArr,
			"charIndex":    step.CharIndex,
			"symbol":       step.Symbol,
			"transitions":  transitions,
		}
	}
	response["steps"] = steps

	if result.Error != nil {
		errorStatesArr := make([]interface{}, len(result.Error.States))
		for i, s := range result.Error.States {
			errorStatesArr[i] = s
		}

		response["error"] = map[string]interface{}{
			"type":     result.Error.Type,
			"position": result.Error.Position,
			"states":   errorStatesArr,
			"symbol":   result.Error.Symbol,
			"message":  result.Error.Message,
		}
	}

	return response
}

func addStateWASM(this js.Value, args []js.Value) interface{} {
	if len(args) != 2 {
		return map[string]interface{}{
			"success": false,
			"error":   "Se așteaptă 2 argumente (JSON automat, nume stare)",
		}
	}

	jsonStr := args[0].String()
	stateName := args[1].String()

	fa, err := ParseFromJSON(jsonStr)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	err = fa.AddState(stateName)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	updatedJSON, err := fa.ToJSON()
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	return map[string]interface{}{
		"success": true,
		"data":    updatedJSON,
	}
}

func removeStateWASM(this js.Value, args []js.Value) interface{} {
	if len(args) != 2 {
		return map[string]interface{}{
			"success": false,
			"error":   "Se așteaptă 2 argumente (JSON automat, nume stare)",
		}
	}

	jsonStr := args[0].String()
	stateName := args[1].String()

	fa, err := ParseFromJSON(jsonStr)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	err = fa.RemoveState(stateName)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	updatedJSON, err := fa.ToJSON()
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	return map[string]interface{}{
		"success": true,
		"data":    updatedJSON,
	}
}

func renameStateWASM(this js.Value, args []js.Value) interface{} {
	if len(args) != 3 {
		return map[string]interface{}{
			"success": false,
			"error":   "Se așteaptă 3 argumente (JSON automat, nume vechi, nume nou)",
		}
	}

	jsonStr := args[0].String()
	oldName := args[1].String()
	newName := args[2].String()

	fa, err := ParseFromJSON(jsonStr)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	err = fa.RenameState(oldName, newName)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	updatedJSON, err := fa.ToJSON()
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	return map[string]interface{}{
		"success": true,
		"data":    updatedJSON,
	}
}

func setInitialStateWASM(this js.Value, args []js.Value) interface{} {
	if len(args) != 2 {
		return map[string]interface{}{
			"success": false,
			"error":   "Se așteaptă 2 argumente (JSON automat, nume stare)",
		}
	}

	jsonStr := args[0].String()
	stateName := args[1].String()

	fa, err := ParseFromJSON(jsonStr)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	err = fa.SetInitialState(stateName)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	updatedJSON, err := fa.ToJSON()
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	return map[string]interface{}{
		"success": true,
		"data":    updatedJSON,
	}
}

func toggleFinalStateWASM(this js.Value, args []js.Value) interface{} {
	if len(args) != 2 {
		return map[string]interface{}{
			"success": false,
			"error":   "Se așteaptă 2 argumente (JSON automat, nume stare)",
		}
	}

	jsonStr := args[0].String()
	stateName := args[1].String()

	fa, err := ParseFromJSON(jsonStr)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	err = fa.ToggleFinalState(stateName)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	updatedJSON, err := fa.ToJSON()
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	return map[string]interface{}{
		"success": true,
		"data":    updatedJSON,
	}
}

func setStatePositionWASM(this js.Value, args []js.Value) interface{} {
	if len(args) != 4 {
		return map[string]interface{}{
			"success": false,
			"error":   "Se așteaptă 4 argumente (JSON automat, nume stare, x, y)",
		}
	}

	jsonStr := args[0].String()
	stateName := args[1].String()
	x := args[2].Float()
	y := args[3].Float()

	fa, err := ParseFromJSON(jsonStr)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	err = fa.SetStatePosition(stateName, x, y)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	updatedJSON, err := fa.ToJSON()
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	return map[string]interface{}{
		"success": true,
		"data":    updatedJSON,
	}
}

func addTransitionWASM(this js.Value, args []js.Value) interface{} {
	if len(args) != 4 {
		return map[string]interface{}{
			"success": false,
			"error":   "Se așteaptă 4 argumente (JSON automat, stare de la, simbol, stare către)",
		}
	}

	jsonStr := args[0].String()
	from := args[1].String()
	symbol := args[2].String()
	to := args[3].String()

	fa, err := ParseFromJSON(jsonStr)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	err = fa.AddTransition(from, symbol, to)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	updatedJSON, err := fa.ToJSON()
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	return map[string]interface{}{
		"success": true,
		"data":    updatedJSON,
	}
}

func removeTransitionWASM(this js.Value, args []js.Value) interface{} {
	if len(args) != 4 {
		return map[string]interface{}{
			"success": false,
			"error":   "Se așteaptă 4 argumente (JSON automat, stare de la, simbol, stare către)",
		}
	}

	jsonStr := args[0].String()
	from := args[1].String()
	symbol := args[2].String()
	to := args[3].String()

	fa, err := ParseFromJSON(jsonStr)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	err = fa.RemoveTransition(from, symbol, to)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	updatedJSON, err := fa.ToJSON()
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	return map[string]interface{}{
		"success": true,
		"data":    updatedJSON,
	}
}

func getAutomatonJSONWASM(this js.Value, args []js.Value) interface{} {
	if len(args) != 1 {
		return map[string]interface{}{
			"success": false,
			"error":   "Se așteaptă 1 argument (JSON automat)",
		}
	}

	jsonStr := args[0].String()

	fa, err := ParseFromJSON(jsonStr)
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	updatedJSON, err := fa.ToJSON()
	if err != nil {
		return map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		}
	}

	return map[string]interface{}{
		"success": true,
		"data":    updatedJSON,
	}
}
