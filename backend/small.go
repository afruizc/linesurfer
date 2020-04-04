package main

func one() {
	println("one")
}

func two() {
	one()
	println("two")
}

func three() {
	one()
	two()
	println("three")
}
