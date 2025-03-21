package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func part1(input string) (string, error) {
	ops := strings.Split(input, "\n")
	acc := 0
	ip := 0
	visited := make(map[int]bool)
	for {
		if visited[ip] {
			break
		}
		visited[ip] = true

		op := strings.Split(ops[ip], " ")
		sign := op[1][0]
		num, err := strconv.Atoi(op[1][1:])
		if err != nil {
			return "", err
		}
		if sign == '-' {
			num = -num
		}

		switch op[0] {
		case "acc":
			acc += num
			ip += 1
		case "jmp":
			ip += num
		case "nop":
			ip += 1
		}
	}
	return strconv.Itoa(acc), nil
}

func part2(input string) (string, error) {
	ops := strings.Split(input, "\n")
	acc := 0
	for i, op := range ops {
		if strings.HasPrefix(op, "acc") {
			continue
		}

		acc = 0
		ip := 0
		visited := make(map[int]bool)
		for {
			if ip >= len(ops) {
				return strconv.Itoa(acc), nil
			}
			if visited[ip] {
				break
			}
			visited[ip] = true

			op := strings.Split(ops[ip], " ")
			if ip == i {
				if op[0] == "jmp" {
					op[0] = "nop"
				} else if op[0] == "nop" {
					op[0] = "jmp"
				}
			}
			sign := op[1][0]
			num, err := strconv.Atoi(op[1][1:])
			if err != nil {
				return "", err
			}
			if sign == '-' {
				num = -num
			}

			switch op[0] {
			case "acc":
				acc += num
				ip += 1
			case "jmp":
				ip += num
			case "nop":
				ip += 1
			}
		}
	}
	return "", fmt.Errorf("No solution found")
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
