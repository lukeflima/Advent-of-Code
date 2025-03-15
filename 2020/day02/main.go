package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func part1(input string) (string, error) {
	lines := strings.Split(input, "\n")
	res := 0
	for _, line := range lines {
		parts := strings.Split(line, ": ")
		policy := parts[0]
		password := parts[1]

		parts = strings.Split(policy, " ")
		letter := rune(parts[1][0])

		parts = strings.Split(parts[0], "-")
		min, err := strconv.Atoi(parts[0])
		if err != nil {
			return "", err
		}
		max, err := strconv.Atoi(parts[1])
		if err != nil {
			return "", err
		}
		count := 0
		for _, char := range password {
			if char == letter {
				count++
			}
		}
		if count >= min && count <= max {
			res++
		}
	}
	return strconv.Itoa(res), nil
}

func part2(input string) (string, error) {
	lines := strings.Split(input, "\n")
	res := 0
	for _, line := range lines {
		parts := strings.Split(line, ": ")
		policy := parts[0]
		password := parts[1]

		parts = strings.Split(policy, " ")
		letter := rune(parts[1][0])

		parts = strings.Split(parts[0], "-")
		min, err := strconv.Atoi(parts[0])
		if err != nil {
			return "", err
		}
		max, err := strconv.Atoi(parts[1])
		if err != nil {
			return "", err
		}
		if (rune(password[min-1]) == letter && rune(password[max-1]) != letter) ||
			(rune(password[min-1]) != letter && rune(password[max-1]) == letter) {
			res++
		}
	}
	return strconv.Itoa(res), nil
}

func main() {
	// input_file := "sample.txt"
	input_file := "input.txt"

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
