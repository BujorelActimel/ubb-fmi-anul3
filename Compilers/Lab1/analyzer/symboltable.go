package analyzer

import (
	"Lab1/lexer"
	"fmt"
	"os"
	"strings"
)

type Node struct {
	Symbol string
	Left   *Node
	Right  *Node
}

type SymbolTable struct {
	root      *Node
	positions map[string]int
	needsSync bool
}

func NewSymbolTable() *SymbolTable {
	return &SymbolTable{
		root:      nil,
		positions: make(map[string]int),
		needsSync: false,
	}
}

func (st *SymbolTable) Add(symbol string) int {
	if st.exists(symbol) {
		return st.positions[symbol]
	}

	st.root = st.insert(st.root, symbol)
	st.needsSync = true

	st.syncPositions()

	return st.positions[symbol]
}

func (st *SymbolTable) exists(symbol string) bool {
	return st.search(st.root, symbol)
}

func (st *SymbolTable) search(node *Node, symbol string) bool {
	if node == nil {
		return false
	}

	cmp := strings.Compare(symbol, node.Symbol)
	if cmp == 0 {
		return true
	} else if cmp < 0 {
		return st.search(node.Left, symbol)
	} else {
		return st.search(node.Right, symbol)
	}
}

func (st *SymbolTable) insert(node *Node, symbol string) *Node {
	if node == nil {
		return &Node{Symbol: symbol}
	}

	cmp := strings.Compare(symbol, node.Symbol)

	if cmp == 0 {
		return node
	} else if cmp < 0 {
		node.Left = st.insert(node.Left, symbol)
	} else {
		node.Right = st.insert(node.Right, symbol)
	}
	return node
}

func (st *SymbolTable) syncPositions() {
	if !st.needsSync {
		return
	}

	symbols := st.GetInOrder()
	st.positions = make(map[string]int)
	for i, s := range symbols {
		st.positions[s] = i + 1
	}
	st.needsSync = false
}

func (st *SymbolTable) GetInOrder() []string {
	result := make([]string, 0)
	st.inorderTraversal(st.root, &result)
	return result
}

func (st *SymbolTable) inorderTraversal(node *Node, result *[]string) {
	if node == nil {
		return
	}
	st.inorderTraversal(node.Left, result)
	*result = append(*result, node.Symbol)
	st.inorderTraversal(node.Right, result)
}

func (st *SymbolTable) SaveToFile(filepath string) error {
	st.syncPositions()

	table := "Pos,Symbol\n"

	symbols := st.GetInOrder()
	for i, symbol := range symbols {
		table += fmt.Sprintf("%d,%s\n", i+1, symbol)
	}

	return os.WriteFile(filepath, []byte(table), 0644)
}

func (st *SymbolTable) GetPositionMap() map[string]int {
	st.needsSync = true
	st.syncPositions()
	return st.positions
}

type FIPEntry struct {
	TokenType lexer.TokenType
	Symbol    string
}

func (f FIPEntry) String(posMap map[string]int) string {
	typeName := lexer.GetTokenName(f.TokenType)
	if typeName == "" {
		typeName = fmt.Sprintf("UNKNOWN(%d)", f.TokenType)
	}

	if f.Symbol != "" {
		pos := posMap[f.Symbol]
		return fmt.Sprintf("%s,%d", typeName, pos)
	}
	return fmt.Sprintf("%s,-", typeName)
}

type FIP struct {
	entries []FIPEntry
}

func NewFIP() *FIP {
	return &FIP{
		entries: make([]FIPEntry, 0),
	}
}

func (fip *FIP) AddEntry(entry FIPEntry) {
	fip.entries = append(fip.entries, entry)
}

func (fip *FIP) SaveToFile(filepath string, posMap map[string]int) error {
	result := "TokenType,TSPos\n"

	for _, entry := range fip.entries {
		result += entry.String(posMap) + "\n"
	}

	return os.WriteFile(filepath, []byte(result), 0644)
}
