package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func part1(input string) (string, error) {
	nums := strings.Split(input, ",")
	memory := make(map[int]int)
	for i, line := range nums {
		num, _ := strconv.Atoi(line)
		memory[num] = i + 1
	}
	num, _ := strconv.Atoi(nums[len(nums)-1])
	delete(memory, num)
	for i := len(nums); i < 2020; i++ {
		val, ok := memory[num]
		memory[num] = i
		if !ok {
			num = 0
		} else {
			num = i - val
		}
	}
	return strconv.Itoa(num), nil
}

func part2(input string) (string, error) {
	nums := strings.Split(input, ",")
	memory := make(map[int]int)
	for i, line := range nums {
		num, _ := strconv.Atoi(line)
		memory[num] = i + 1
	}
	num, _ := strconv.Atoi(nums[len(nums)-1])
	delete(memory, num)
	for i := len(nums); i < 30000000; i++ {
		val, ok := memory[num]
		memory[num] = i
		if !ok {
			num = 0
		} else {
			num = i - val
		}
	}
	return strconv.Itoa(num), nil
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
