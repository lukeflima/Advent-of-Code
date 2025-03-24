package main

import (
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

func part1(input string) (string, error) {
	lines := strings.Split(input, "\n")
	adapters := []int{}
	for _, line := range lines {
		num, _ := strconv.Atoi(line)
		adapters = append(adapters, num)
	}
	slices.Sort(adapters)

	diff_of_1 := 0
	diff_of_3 := 1
	prev := 0
	for _, cur := range adapters {
		diff := cur - prev
		if diff == 1 {
			diff_of_1++
		} else if diff == 3 {
			diff_of_3++
		}
		prev = cur
	}

	return strconv.Itoa(diff_of_1 * diff_of_3), nil
}

func part2(input string) (string, error) {
	lines := strings.Split(input, "\n")
	adapters := []int{}
	for _, line := range lines {
		num, _ := strconv.Atoi(line)
		adapters = append(adapters, num)
	}
	slices.Sort(adapters)

	counts := map[int]int{}
	counts[0] = 1
	for _, adapter := range adapters {
		counts[adapter] = counts[adapter-1] + counts[adapter-2] + counts[adapter-3]
	}

	return strconv.Itoa(counts[adapters[len(adapters)-1]]), nil
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
