package main

import (
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

type Point [2]float64

func addPoint(p1, p2 Point) Point {
	return Point{p1[0] + p2[0], p1[1] + p2[1]}
}

var dirs = map[string]Point{
	"e":  {0.0, 1.0},
	"se": {0.5, 0.5},
	"sw": {0.5, -0.5},
	"w":  {0.0, -1.0},
	"nw": {-0.5, -0.5},
	"ne": {-0.5, 0.5},
}

func parseDirectionsTile(tile string) []string {
	directions := []string{}
	for i := 0; i < len(tile); {
		switch tile[i] {
		case 's', 'n':
			directions = append(directions, tile[i:i+2])
			i += 2
		default:
			directions = append(directions, tile[i:i+1])
			i += 1
		}
	}
	return directions
}

func part1(input string) (string, error) {
	flips := make(map[Point]int)
	for _, tile := range strings.Split(input, "\n") {
		directions := parseDirectionsTile(tile)
		pos := Point{0, 0}
		for _, dir := range directions {
			pos = addPoint(pos, dirs[dir])
		}
		flips[pos] += 1
	}

	res := 0
	for _, nflip := range flips {
		if nflip%2 == 1 {
			res += 1
		}
	}

	return strconv.Itoa(res), nil
}

type Set[T comparable] map[T]bool

func (set Set[T]) add(values ...T) {
	for _, value := range values {
		set[value] = true
	}
}

func part2(input string) (string, error) {
	blacks := make(Set[Point])
	for _, tile := range strings.Split(input, "\n") {
		directions := parseDirectionsTile(tile)
		pos := Point{0, 0}
		for _, dir := range directions {
			pos = addPoint(pos, dirs[dir])
		}
		if !blacks[pos] {
			blacks.add(pos)
		} else {
			delete(blacks, pos)
		}
	}

	for range 100 {
		xMin, yMin, xMax, yMax := math.Inf(1), math.Inf(1), math.Inf(-1), math.Inf(-1)
		for pos := range blacks {
			if pos[0] < xMin {
				xMin = pos[0]
			}
			if pos[1] < yMin {
				yMin = pos[1]
			}
			if pos[0] > xMax {
				xMax = pos[0]
			}
			if pos[1] > yMax {
				yMax = pos[1]
			}
		}
		xMin -= 0.5
		yMin -= 0.5
		xMax += 0.5
		yMax += 0.5
		newBlacks := Set[Point]{}
		for x := xMin; x <= xMax; x += 0.5 {
			for y := yMin; y <= yMax; y += 0.5 {
				p := Point{x, y}
				nblacks := 0
				for _, dir := range dirs {
					if blacks[addPoint(p, dir)] {
						nblacks += 1
					}
				}
				if blacks[p] {
					if nblacks > 0 && nblacks <= 2 {
						newBlacks.add(p)
					}
				} else {
					if nblacks == 2 {
						newBlacks.add(p)
					}
				}
			}
		}
		blacks = newBlacks
	}

	return strconv.Itoa(len(blacks)), nil
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
