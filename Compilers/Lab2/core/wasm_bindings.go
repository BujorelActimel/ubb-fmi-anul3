//go:build js && wasm

package main

import (
	"syscall/js"
)

func main() {
	js.Global().Set("parseAutomaton", js.FuncOf(parseAutomatonWASM))
	js.Global().Set("simulateSequence", js.FuncOf(simulateSequenceWASM))
	js.Global().Set("findLongestPrefix", js.FuncOf(findLongestPrefixWASM))

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
