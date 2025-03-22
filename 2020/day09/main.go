package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func part1(input string) (string, error) {
	lines := strings.Split(input, "\n")
	nums := []int{}
	for _, num := range lines {
		n, _ := strconv.Atoi(num)
		nums = append(nums, n)
	}
	start := 25
	for i := start; i < len(nums); i++ {
		found := false
	outer:
		for j := i - start; j < i; j++ {
			for k := j + 1; k < i; k++ {
				if nums[j]+nums[k] == nums[i] {
					found = true
					break outer
				}
			}
		}
		if !found {
			return strconv.Itoa(nums[i]), nil
		}
	}

	return "", fmt.Errorf("No solution found")
}

func part2(input string) (string, error) {
	value_str, _ := part1(input)
	value, _ := strconv.Atoi(value_str)
	lines := strings.Split(input, "\n")
	nums := []int{}
	for _, num := range lines {
		n, _ := strconv.Atoi(num)
		nums = append(nums, n)
	}
	for i := 0; i < len(nums); i++ {
		sum := 0
		min := nums[i]
		max := nums[i]
		for j := i; j < len(nums); j++ {
			sum += nums[j]
			if nums[j] < min {
				min = nums[j]
			}
			if nums[j] > max {
				max = nums[j]
			}
			if sum == value {
				return strconv.Itoa(min + max), nil
			}
			if sum > value {
				break
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
