# Simulator Automate Finite - Lab 2

Implementare interactivă pentru simularea automatelor finite (AFD și AFND) cu vizualizare grafică și animație pas-cu-pas.

## Caracteristici

- **Core în Go**: Logica automatului implementată în Go, compilabilă pentru CLI și WASM
- **Interfață Web**: Dark mode minimalist cu vizualizare grafică interactivă
- **Simulare vizuală**: Animație pas-cu-pas cu highlight simultan pe caracter și graf
- **Suport AFD și AFND**: Explorare BFS pentru automate nedeterministe
- **Edge cases**: Gestionare completă a erorilor (caracter invalid, tranziție lipsă, etc.)

## Structură Proiect

```
Lab2/
├── core/                   # Go package
│   ├── automaton.go       # Structuri și validare
│   ├── parser.go          # Parsare JSON
│   ├── simulator.go       # Algoritmi simulare
│   ├── wasm_bindings.go   # Export WASM
│   └── main.go            # CLI
├── web/                   # Interfață web
│   ├── index.html
│   ├── styles.css
│   ├── core.wasm
│   └── js/
│       ├── wasm-loader.js
│       ├── visualizer.js
│       ├── simulator.js
│       └── app.js
├── examples/
│   ├── integer_constants.json  # AFD pentru constante întregi C/C++
│   └── nfa_example.json        # AFND exemplu
└── Makefile
```

## Build

### CLI
```bash
make build-cli
./bin/fa-cli
```

### WASM + Web
```bash
make build-wasm
make serve
```

Apoi deschide `http://localhost:8080`

### Ambele
```bash
make all
```

## Format JSON

```json
{
  "states": ["q0", "q1", "q2"],
  "alphabet": ["a", "b"],
  "transitions": {
    "q0": {"a": ["q1"], "b": ["q2"]},
    "q1": {"a": ["q1", "q2"]}
  },
  "initialState": "q0",
  "finalStates": ["q2"]
}
```

## Utilizare CLI

1. Încarcă automat din fișier sau creează manual
2. Afișează componente (stări, alfabet, tranziții, stări finale)
3. Verifică dacă o secvență este acceptată
4. Găsește cel mai lung prefix acceptat

## Utilizare Web

1. **Încărcare**: Upload fișier JSON sau folosește exemplele
2. **Vizualizare**: Graf interactiv generat automat
3. **Simulare**:
   - Introdu secvență
   - Apasă Play
   - Vezi animația pas-cu-pas cu highlight pe caracter și graf
   - Controlează viteza cu slider-ul

## Exemple Testate

### AFD - Constante Întregi C/C++
- Decimal: `123`, `456`
- Hexadecimal: `0xFF`, `0x1A2B`
- Octal: `0755`, `0123`
- Binary: `0b1010`, `0B1111`
- Cu sufixe: `123ULL`, `0xFFul`

### AFND - Paths Multiple
- Secvență `ab` → acceptat prin q0→q1→q3
- Secvență `aa` → respins (niciunul din paths nu ajunge la stare finală)

## Tehnologii

- **Backend**: Go 1.25+
- **WASM**: Go WASM target
- **Frontend**: Vanilla JavaScript
- **Vizualizare**: vis.js
- **Styling**: CSS custom (dark blue-grey theme)
