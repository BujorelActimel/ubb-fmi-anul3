package main

import "fmt"

func main() {
	counter := 0
	for {
		counter += 1
		fmt.Printf("%d\n", counter)
		break
	}
}
