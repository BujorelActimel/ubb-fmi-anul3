package main

import "fmt"

func main() {
	counter := 0
	for true {
		counter += 1
		fmt.Printf("%d\n", counter)
		break
	}
}
