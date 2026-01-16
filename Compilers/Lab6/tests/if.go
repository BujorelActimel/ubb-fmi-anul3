package main

import "fmt"

func main() {
	var a int
	var b int
	var max int

	a = 10
	b = 20

	if a > b {
		max = a
	} else {
		max = b
	}

	fmt.Printf("%d\n", max)
}
