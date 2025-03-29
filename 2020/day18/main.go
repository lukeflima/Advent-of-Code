package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func indexOf(data string, element rune) int {
	for k, v := range data {
		if element == v {
			return k
		}
	}
	return -1
}

func parseExpresssionP1(expression string) (int, int) {
	res := 0
	c := 0
	op := '+'
loop:
	for c < len(expression) {
		cell := rune(expression[c])
		switch cell {
		case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '(':
			num := (int(cell) - int('0'))
			if cell == '(' {
				n, dc := parseExpresssionP1(expression[c+1:])
				c += dc
				num = n
			}

			switch op {
			case '+':
				res += num
			case '*':
				res *= num
			default:
				panic("Invalid")
			}
			op = '.'
			c += 1
		case '*', '+':
			if op != '.' {
				panic("Invalid op")
			}
			op = cell
			c += 1
		case ')':
			c += 1
			break loop
		default:
			c += 1
		}
	}
	return res, c
}

func pop[T any](stack []T) (T, []T) {
	stack_size := len(stack)
	if stack_size <= 0 {
		panic("Stack underflow")
	}
	return stack[stack_size-1], stack[:stack_size-1]
}

func peek(stack []rune) rune {
	stack_size := len(stack)
	if stack_size <= 0 {
		return 0
	}
	return stack[stack_size-1]
}

func shuntingYard(expression string) []rune {
	infix := []rune{}
	stack := []rune{}

	top := rune(0)
	for _, c := range expression {
		switch c {
		case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
			infix = append(infix, c)
		case '+', '(':
			stack = append(stack, c)
		case '*':
			for peek(stack) == '+' {
				top, stack = pop(stack)
				infix = append(infix, top)
			}
			stack = append(stack, c)
		case ')':
			for peek(stack) != '(' {
				top, stack = pop(stack)
				infix = append(infix, top)
			}
			_, stack = pop(stack)
		default:
			continue
		}
	}
	for len(stack) > 0 {
		top, stack = pop(stack)
		infix = append(infix, top)
	}
	return infix
}

func parseExpresssionP2(expression string) int {
	infix := shuntingYard(expression)
	stack := []int{}
	top := 0
	for _, c := range infix {
		switch c {
		case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
			stack = append(stack, (int(c) - int('0')))
		default:
			top, stack = pop(stack)
			rhs := top
			top, stack = pop(stack)
			if c == '+' {
				stack = append(stack, rhs+top)
			} else {
				stack = append(stack, rhs*top)
			}
		}
	}
	res, _ := pop(stack)
	return res
}

func part1(input string) (string, error) {
	expressions := strings.Split(input, "\n")
	res := 0
	for _, expression := range expressions {
		r, _ := parseExpresssionP1(expression)
		// fmt.Println(expression, " = ", r)
		res += r
	}
	return strconv.Itoa(res), nil
}

func part2(input string) (string, error) {
	expressions := strings.Split(input, "\n")
	res := 0
	for _, expression := range expressions {
		r := parseExpresssionP2(expression)
		// fmt.Println(expression, "=", r)
		res += r
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
