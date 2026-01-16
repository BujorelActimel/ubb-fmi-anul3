package main

import "fmt"

var x int
var y int
var max int

func main() {
	fmt.Scanf("%d", &x)
	fmt.Scanf("%d", &y)

	if x > y {
		max = x
	} else {
		max = y
	}

	fmt.Printf("%d\n", max)
}
