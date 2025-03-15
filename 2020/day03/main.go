package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func part1(input string) (string, error) {
	grid := strings.Split(input, "\n")
	height := len(grid)
	width := len(grid[0])
	start := [2]int{0, 0}
	dir := [2]int{1, 3}
	pos := start
	count := 0
	for pos[0] < height {
		if grid[pos[0]][pos[1]] == '#' {
			count++
		}
		pos[0] += dir[0]
		pos[1] = (pos[1] + dir[1]) % width
	}
	return strconv.Itoa(count), nil
}

func part2(input string) (string, error) {
	grid := strings.Split(input, "\n")
	height := len(grid)
	width := len(grid[0])
	start := [2]int{0, 0}
	dirs := [][2]int{
		{1, 1},
		{1, 3},
		{1, 5},
		{1, 7},
		{2, 1},
	}
	res := 1
	for _, dir := range dirs {
		pos := start
		count := 0
		for pos[0] < height {
			if grid[pos[0]][pos[1]] == '#' {
				count++
			}
			pos[0] += dir[0]
			pos[1] = (pos[1] + dir[1]) % width
		}
		res *= count
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
