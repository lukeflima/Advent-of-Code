package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func part1(input string) (string, error) {
	target := 2020
	lines := strings.Split(input, "\n")
	difs := make(map[int]int)
	for _, line := range lines {
		num, err := strconv.Atoi(line)
		if err != nil {
			return "", err
		}
		dif := target - num
		if _, ok := difs[dif]; ok {
			return strconv.Itoa(num * dif), nil
		}
		difs[num] = num
	}
	return "", fmt.Errorf("no solution found")
}

func part2(input string) (string, error) {
	lines := strings.Split(input, "\n")
	nums := make([]int, len(lines))
	for i, line := range lines {
		num, err := strconv.Atoi(line)
		if err != nil {
			return "", err
		}
		nums[i] = num
	}
	for _, num := range nums {
		for _, num2 := range nums {
			for _, num3 := range nums {
				if num+num2+num3 == 2020 {
					return strconv.Itoa(num * num2 * num3), nil
				}
			}
		}
	}

	return "", fmt.Errorf("no solution found")
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
