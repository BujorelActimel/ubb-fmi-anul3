package main

import "fmt"

var a int
var b int
var result int

func main() {
	fmt.Scanf("%d", &a)
	fmt.Scanf("%d", &b)

	result = a + b*2

	fmt.Printf("%d\n", result)
}
