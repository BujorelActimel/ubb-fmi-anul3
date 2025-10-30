package main

import (
	"encoding/json"
	"fmt"
	"os"
)

func ParseFromJSON(jsonStr string) (*FiniteAutomaton, error) {
	var fa FiniteAutomaton

	err := json.Unmarshal([]byte(jsonStr), &fa)
	if err != nil {
		return nil, fmt.Errorf("eroare la parsarea JSON: %v", err)
	}

	if err := fa.Validate(); err != nil {
		return nil, fmt.Errorf("automat invalid: %v", err)
	}

	return &fa, nil
}

func ParseFromFile(filename string) (*FiniteAutomaton, error) {
	data, err := os.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("eroare la citirea fișierului: %v", err)
	}

	return ParseFromJSON(string(data))
}

func (fa *FiniteAutomaton) ToJSON() (string, error) {
	data, err := json.MarshalIndent(fa, "", "  ")
	if err != nil {
		return "", fmt.Errorf("eroare la serializarea JSON: %v", err)
	}
	return string(data), nil
}

func (fa *FiniteAutomaton) SaveToFile(filename string) error {
	jsonStr, err := fa.ToJSON()
	if err != nil {
		return err
	}

	err = os.WriteFile(filename, []byte(jsonStr), 0644)
	if err != nil {
		return fmt.Errorf("eroare la scrierea fișierului: %v", err)
	}

	return nil
}
