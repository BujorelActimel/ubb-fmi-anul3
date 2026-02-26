package main

import "fmt"

var a int
var expr int

func main() {
	fmt.Scanf("%d", &a)

	expr = a + a*a + a + 5 - 5

	fmt.Printf("%d\n", expr)
}
