package main

import (
	"fmt"
	"os"
	"strings"
)

func part1(input string) (string, error) {
	return "", nil
}

func part2(input string) (string, error) {
	return "", nil
}

func main() {
	input_file := "sample.txt"
	// input_file := "input.txt"

	input_bytes, err := os.ReadFile(input_file)
	if err != nil {
		fmt.Println("Error:", err)
	}
	input := strings.TrimSpace(string(input_bytes))

	res, err := part1(input)
	if err != nil {
		fmt.Println("Error:", err)
	}
	fmt.Println("Part 1:", res)

	res, err = part2(input)
	if err != nil {
		fmt.Println("Error:", err)
	}
	fmt.Println("Part 2:", res)
}
