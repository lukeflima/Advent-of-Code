package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func part1(input string) (string, error) {
	lines := strings.Split(input, "\n")
	memory := make(map[int]int)
	mask_one := 0
	mask_zero := 0
	for _, line := range lines {
		if strings.HasPrefix(line, "mask") {
			mask_one = 0
			mask_zero = 0
			parts := strings.Split(line, " = ")
			for i, b := range parts[1] {
				if b == '1' {
					mask_one |= 1 << (35 - i)
				}
				if b == '0' {
					mask_zero |= (1 << (35 - i))
				}
			}
			mask_zero = ^mask_zero & ((1 << 36) - 1)
		} else {
			parts := strings.Split(line, " = ")
			address, _ := strconv.Atoi(parts[0][4 : len(parts[0])-1])
			value, _ := strconv.Atoi(parts[1])
			memory[address] = (value & mask_zero) | mask_one
		}
	}
	sum := 0
	for _, v := range memory {
		sum += v
	}
	return strconv.Itoa(sum), nil
}

func part2(input string) (string, error) {
	lines := strings.Split(input, "\n")
	memory := make(map[int]int)
	mask_one := 0
	mask_xs := make([]int, 0)
	for _, line := range lines {
		if strings.HasPrefix(line, "mask") {
			mask_one = 0
			mask_xs = make([]int, 0)
			parts := strings.Split(line, " = ")
			for i, b := range parts[1] {
				if b == '1' {
					mask_one |= 1 << (35 - i)
				}
				if b == 'X' {
					mask_xs = append(mask_xs, 35-i)
				}
			}
		} else {
			parts := strings.Split(line, " = ")
			address, _ := strconv.Atoi(parts[0][4 : len(parts[0])-1])
			value, _ := strconv.Atoi(parts[1])
			address |= mask_one
			for i := 0; i < (1 << len(mask_xs)); i++ {
				new_address := address
				for j, x := range mask_xs {
					if i&(1<<j) != 0 {
						new_address |= 1 << x
					} else {
						new_address &= ^(1 << x)
					}
				}
				memory[new_address] = value
			}
		}
	}
	sum := 0
	for _, v := range memory {
		sum += v
	}
	return strconv.Itoa(sum), nil
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
