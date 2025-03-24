package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func copy_grid(grid [][]rune) [][]rune {
	new_grid := make([][]rune, len(grid))
	for i := range grid {
		new_grid[i] = make([]rune, len(grid[i]))
		copy(new_grid[i], grid[i])
	}
	return new_grid
}

func equal_grid(grid1, grid2 [][]rune) bool {
	for i := range grid1 {
		for j := range grid1[i] {
			if grid1[i][j] != grid2[i][j] {
				return false
			}
		}
	}
	return true
}

func part1(input string) (string, error) {
	lines := strings.Split(input, "\n")
	grid := make([][]rune, len(lines))
	for i, line := range lines {
		grid[i] = []rune(line)
	}
	prev_grid := [][]rune{}
	for {
		prev_grid = copy_grid(grid)
		for i := range grid {
			for j := range grid[i] {
				cell := grid[i][j]
				if cell == '.' {
					continue
				}
				occupied := 0
				for x := i - 1; x <= i+1; x++ {
					for y := j - 1; y <= j+1; y++ {
						if x < 0 || y < 0 || x >= len(grid) || y >= len(grid[i]) {
							continue
						}
						if x == i && y == j {
							continue
						}
						if prev_grid[x][y] == '#' {
							occupied++
						}
					}
				}
				if cell == 'L' && occupied == 0 {
					grid[i][j] = '#'
				} else if cell == '#' && occupied >= 4 {
					grid[i][j] = 'L'
				}
			}
		}
		if equal_grid(grid, prev_grid) {
			break
		}
	}

	res := 0
	for i := range grid {
		for j := range grid[i] {
			if grid[i][j] == '#' {
				res++
			}
		}
	}

	return strconv.Itoa(res), nil
}

func part2(input string) (string, error) {
	lines := strings.Split(input, "\n")
	grid := make([][]rune, len(lines))
	for i, line := range lines {
		grid[i] = []rune(line)
	}
	prev_grid := [][]rune{}
	for {
		prev_grid = copy_grid(grid)
		for i := range grid {
			for j := range grid[i] {
				cell := grid[i][j]
				if cell == '.' {
					continue
				}
				occupied := 0
				for dx := -1; dx <= 1; dx++ {
					for dy := -1; dy <= 1; dy++ {
						if dx == 0 && dy == 0 {
							continue
						}
						x := i + dx
						y := j + dy
						for x >= 0 && y >= 0 && x < len(grid) && y < len(grid[i]) {
							if prev_grid[x][y] == '#' {
								occupied++
								break
							}
							if prev_grid[x][y] == 'L' {
								break
							}
							x += dx
							y += dy
						}
					}
				}
				if cell == 'L' && occupied == 0 {
					grid[i][j] = '#'
				} else if cell == '#' && occupied >= 5 {
					grid[i][j] = 'L'
				}
			}
		}
		if equal_grid(grid, prev_grid) {
			break
		}
	}

	res := 0
	for i := range grid {
		for j := range grid[i] {
			if grid[i][j] == '#' {
				res++
			}
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
