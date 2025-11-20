package main

import "fmt"

func main() {
	var a, b int

	fmt.Printf("a = ")
	fmt.Scanf("%d", &a)
	fmt.Printf("b = ")
	fmt.Scanf("%d", &b)

	fmt.Printf("gcd = %d", gcd(a, b))
}

func gcd(a, b int) int {
	if a == 0 {
		return b
	}
	if b == 0 {
		return a
	}

	if a == b {
		return a
	}

	if a > b {
		return gcd(a-b, b)
	}
	return gcd(a, b-a)
}
