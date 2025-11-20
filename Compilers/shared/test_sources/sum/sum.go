package main

import "fmt"

func main() {
	var n int
	fmt.Printf("n = ")
	fmt.Scanf("%d", &n)

	sum := 0

	for i := 0; i < n; i++ {
		fmt.Printf("a[%d] = ", i)
		var currentValue int
		fmt.Scanf("%d", &currentValue)
		sum += currentValue
	}

	fmt.Printf("sum =  %d", sum)
}
