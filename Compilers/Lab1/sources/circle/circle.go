package main

import "fmt"

const pi float32 = 3.14

type Circle struct {
	radius int
}

func main() {
	var radius int
	fmt.Printf("Circle radius = ")
	fmt.Scanf("%d", &radius)

	c := NewCircle(radius)

	fmt.Printf("Circle perimeter = %.3f\n", c.ComputePerimeter())
	fmt.Printf("Circle area = %.3f\n", c.ComputeArea())
}

func NewCircle(radius int) *Circle {
	return &Circle{radius}
}

func (c *Circle) ComputePerimeter() float32 {
	return pi * float32(2*c.radius)
}

func (c *Circle) ComputeArea() float32 {
	return pi * float32(c.radius*c.radius)
}
