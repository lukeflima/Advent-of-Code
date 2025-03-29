package main

import (
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

type Pos3 struct {
	x int
	y int
	z int
}

type Pos4 struct {
	x int
	y int
	z int
	w int
}

func updatedStateP3(pos Pos3, cubes map[Pos3]bool) bool {
	active := cubes[pos]
	active_neighbours := 0
	for dx := -1; dx <= 1; dx++ {
		for dy := -1; dy <= 1; dy++ {
			for dz := -1; dz <= 1; dz++ {
				p := Pos3{
					x: pos.x + dx,
					y: pos.y + dy,
					z: pos.z + dz,
				}
				if pos == p {
					continue
				}
				if cubes[p] {
					active_neighbours += 1
				}
			}
		}
	}
	if active && (active_neighbours == 2 || active_neighbours == 3) {
		return true
	}
	if !active && active_neighbours == 3 {
		return true
	}
	return false
}

func updatedStateP4(pos Pos4, cubes map[Pos4]bool) bool {
	active := cubes[pos]
	active_neighbours := 0
	for dx := -1; dx <= 1; dx++ {
		for dy := -1; dy <= 1; dy++ {
			for dz := -1; dz <= 1; dz++ {
				for dw := -1; dw <= 1; dw++ {
					p := Pos4{
						x: pos.x + dx,
						y: pos.y + dy,
						z: pos.z + dz,
						w: pos.w + dw,
					}
					if pos == p {
						continue
					}
					if cubes[p] {
						active_neighbours += 1
					}
				}
			}
		}
	}
	if active && (active_neighbours == 2 || active_neighbours == 3) {
		return true
	}
	if !active && active_neighbours == 3 {
		return true
	}
	return false
}

func part1(input string) (string, error) {
	cubes := make(map[Pos3]bool)
	for x, row := range strings.Split(input, "\n") {
		for y, cell := range row {
			if cell == '#' {
				cubes[Pos3{x, y, 1}] = true
			}
		}
	}
	for _ = range 6 {
		min_x := math.MaxInt
		min_y := math.MaxInt
		min_z := math.MaxInt
		max_x := math.MinInt
		max_y := math.MinInt
		max_z := math.MinInt
		for p, active := range cubes {
			if active {
				if p.x < min_x {
					min_x = p.x
				}
				if p.y < min_y {
					min_y = p.y
				}
				if p.z < min_z {
					min_z = p.z
				}
				if p.x > max_x {
					max_x = p.x
				}
				if p.y > max_y {
					max_y = p.y
				}
				if p.z > max_z {
					max_z = p.z
				}
			}
		}
		new_cubes := make(map[Pos3]bool)
		for x := min_x - 1; x <= max_x+1; x++ {
			for y := min_y - 1; y <= max_y+1; y++ {
				for z := min_z - 1; z <= max_z+1; z++ {
					p := Pos3{x, y, z}
					activate := updatedStateP3(p, cubes)
					if activate {
						new_cubes[p] = activate
					}
				}
			}
		}
		cubes = new_cubes
	}

	return strconv.Itoa(len(cubes)), nil
}

func part2(input string) (string, error) {
	cubes := make(map[Pos4]bool)
	for x, row := range strings.Split(input, "\n") {
		for y, cell := range row {
			if cell == '#' {
				cubes[Pos4{x, y, 1, 1}] = true
			}
		}
	}
	for _ = range 6 {
		min_x := math.MaxInt
		min_y := math.MaxInt
		min_z := math.MaxInt
		min_w := math.MaxInt
		max_x := math.MinInt
		max_y := math.MinInt
		max_z := math.MinInt
		max_w := math.MinInt
		for p, active := range cubes {
			if active {
				if p.x < min_x {
					min_x = p.x
				}
				if p.y < min_y {
					min_y = p.y
				}
				if p.z < min_z {
					min_z = p.z
				}
				if p.w < min_w {
					min_w = p.w
				}
				if p.x > max_x {
					max_x = p.x
				}
				if p.y > max_y {
					max_y = p.y
				}
				if p.z > max_z {
					max_z = p.z
				}
				if p.w > max_w {
					max_w = p.w
				}
			}
		}
		new_cubes := make(map[Pos4]bool)
		for x := min_x - 1; x <= max_x+1; x++ {
			for y := min_y - 1; y <= max_y+1; y++ {
				for z := min_z - 1; z <= max_z+1; z++ {
					for w := min_w - 1; w <= max_w+1; w++ {
						p := Pos4{x, y, z, w}
						activate := updatedStateP4(p, cubes)
						if activate {
							new_cubes[p] = activate
						}
					}
				}
			}
		}
		cubes = new_cubes
	}

	return strconv.Itoa(len(cubes)), nil
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
