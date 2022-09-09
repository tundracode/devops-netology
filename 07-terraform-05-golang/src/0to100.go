package main

import "fmt"

func main() {
	end := 0
	for n := 0; n < 100; n++ {
		end += n
		if n%3 == 0 && n != 0 {
			fmt.Print(n, ", ")
		}
	}
}
