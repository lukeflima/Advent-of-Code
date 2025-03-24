package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func abs(n int) int {
	if n < 0 {
		return -n
	}
	return n
}

func part1(input string) (string, error) {
	lines := strings.Split(input, "\n")

	dir := 0
	x, y := 0, 0
	for _, cmd := range lines {
		action := cmd[0]
		value, _ := strconv.Atoi(cmd[1:])
		switch action {
		case 'N':
			y += value
		case 'S':
			y -= value
		case 'E':
			x += value
		case 'W':
			x -= value
		case 'L':
			dir = (dir + value) % 360
		case 'R':
			dir = (dir - value + 360) % 360
		case 'F':
			switch dir {
			case 0:
				x += value
			case 90:
				y += value
			case 180:
				x -= value
			case 270:
				y -= value
			default:
				return "", fmt.Errorf("Invalid direction: %d", dir)
			}
		default:
			return "", fmt.Errorf("Invalid action: %c", action)
		}
	}
	res := abs(x) + abs(y)
	return strconv.Itoa(res), nil
}

func part2(input string) (string, error) {
	lines := strings.Split(input, "\n")

	x, y := 0, 0
	wx, wy := 10, 1
	for _, cmd := range lines {
		action := cmd[0]
		value, _ := strconv.Atoi(cmd[1:])
		switch action {
		case 'N':
			wy += value
		case 'S':
			wy -= value
		case 'E':
			wx += value
		case 'W':
			wx -= value
		case 'L':
			for i := 0; i < value/90; i++ {
				wx, wy = -wy, wx
			}
		case 'R':
			for i := 0; i < value/90; i++ {
				wx, wy = wy, -wx
			}
		case 'F':
			x += wx * value
			y += wy * value
		default:
			return "", fmt.Errorf("Invalid action: %c", action)
		}
	}
	res := abs(x) + abs(y)
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
