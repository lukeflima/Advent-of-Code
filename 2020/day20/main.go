package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Side int

const (
	UNKNOWN      = -2
	CORNER       = -1
	UP      Side = 0
	LEFT    Side = 1
	DOWN    Side = 2
	RIGHT   Side = 3
)

var IMAGE_SIZE int

type Tile struct {
	id     int
	edges  []int
	tile   []string
	placed bool
}

func encode(s string) int {
	size := len(s)
	num1 := 0
	num2 := 0
	for i, c := range s {
		if c == '#' {
			num1 |= 1 << (size - i - 1)
			num2 |= 1 << i
		}
	}
	return min(num1, num2)
}

func transpose(input []string) []string {
	if len(input) == 0 {
		return nil
	}

	// Determine maximum row length
	maxLen := 0
	for _, row := range input {
		if len(row) > maxLen {
			maxLen = len(row)
		}
	}

	// Create transposed rows
	result := make([]string, maxLen)
	for col := 0; col < maxLen; col++ {
		var sb strings.Builder
		for _, row := range input {
			if col < len(row) {
				sb.WriteByte(row[col])
			}
		}
		result[col] = sb.String()
	}

	return result
}

func getEdges(grid []string) []int {
	height := len(grid)
	transposed_grid := transpose(grid)
	widht := len(transposed_grid)
	return []int{
		encode(grid[0]),
		encode(transposed_grid[0]),
		encode(grid[height-1]),
		encode(transposed_grid[widht-1]),
	}
}

func parseTile(blocks string) Tile {
	lines := strings.Split(blocks, "\n")
	id_str := lines[0]
	tile_id, _ := strconv.Atoi(strings.Split(strings.Split(id_str, ":")[0], " ")[1])
	return Tile{
		id:    tile_id,
		tile:  lines[1:],
		edges: getEdges(lines[1:]),
	}
}

type Set[T comparable] map[T]bool

func makeSetFromList[T comparable](list []T) Set[T] {
	set := make(Set[T])
	for _, v := range list {
		set.add(v)
	}
	return set
}

func (set Set[T]) interssection(another Set[T]) Set[T] {
	interssection := make(Set[T])
	for k := range set {
		if another[k] {
			interssection[k] = true
		}
	}
	return interssection
}

func (set Set[T]) add(values ...T) {
	for _, value := range values {
		set[value] = true
	}
}

func (set Set[T]) toList() []T {
	list := []T{}
	for value := range set {
		list = append(list, value)
	}
	return list
}

func parseTiles(input string) (map[int]Tile, map[int][]int) {
	tilesStr := strings.Split(input, "\n\n")
	tiles := make(map[int]Tile)
	edges := make(map[int][]int)
	for _, tileStr := range tilesStr {
		tile := parseTile(tileStr)
		tiles[tile.id] = tile
		for _, edge := range tile.edges {
			edges[edge] = append(edges[edge], tile.id)
		}
	}
	return tiles, edges
}

func part1(input string) (string, error) {
	tiles, edges := parseTiles(input)

	res := 1
	for _, tile := range tiles {
		unmatched_edges := 0
		for _, edge := range tile.edges {
			if len(edges[edge]) == 1 {
				unmatched_edges += 1
			}
		}
		if unmatched_edges == 2 {
			res *= tile.id
		}
	}

	return strconv.Itoa(res), nil
}

type Point [2]int

func addPoints(p1, p2 Point) Point {
	return Point{p1[0] + p2[0], p1[1] + p2[1]}
}

func get_edge(p Point, side Side, image [][]Tile) int {
	if p[0] < 0 || p[0] >= IMAGE_SIZE || p[1] < 0 || p[1] >= IMAGE_SIZE {
		return CORNER
	}
	if tile := image[p[0]][p[1]]; tile.id != 0 {
		switch side {
		case UP:
			return tile.edges[DOWN]
		case LEFT:
			return tile.edges[RIGHT]
		case DOWN:
			return tile.edges[UP]
		case RIGHT:
			return tile.edges[LEFT]
		default:
			panic("Unknown side")
		}
	}
	return UNKNOWN
}

func get_edges(i, j int, image [][]Tile) ([]int, int) {
	dirs := []Point{{-1, 0}, {0, -1}, {1, 0}, {0, 1}}
	edges := make([]int, 4)
	knwon_edges := 0
	for idir, dir := range dirs {
		edges[idir] = get_edge(addPoints(Point{i, j}, dir), Side(idir), image)
		if edges[idir] >= 0 {
			knwon_edges += 1
		}
	}
	return edges, knwon_edges
}

func rotate(tile Tile) Tile {
	original := tile.tile
	rows := len(original)
	cols := len(original[0])
	rotated := make([]string, cols)
	for i := 0; i < cols; i++ {
		newRow := make([]byte, rows)
		for j := 0; j < rows; j++ {
			newRow[j] = original[rows-1-j][i]
		}
		rotated[i] = string(newRow)
	}
	return Tile{
		id:    tile.id,
		tile:  rotated,
		edges: getEdges(rotated),
	}
}

func flip(tile Tile) Tile {
	flipped := make([]string, len(tile.tile))
	for i, row := range tile.tile {
		reversed := []rune(row)
		for j, k := 0, len(reversed)-1; j < k; j, k = j+1, k-1 {
			reversed[j], reversed[k] = reversed[k], reversed[j]
		}
		flipped[i] = string(reversed)
	}
	return Tile{
		id:    tile.id,
		tile:  flipped,
		edges: getEdges(flipped),
	}
}

func rotate_grid(grid [][]byte) [][]byte {
	rows := len(grid)
	cols := len(grid[0])
	rotated := make([][]byte, cols)
	for i := 0; i < cols; i++ {
		newRow := make([]byte, rows)
		for j := 0; j < rows; j++ {
			newRow[j] = grid[rows-1-j][i]
		}
		rotated[i] = newRow
	}
	return rotated
}

func flip_grid(grid [][]byte) [][]byte {
	flipped := make([][]byte, len(grid))
	for i, row := range grid {
		reversed := []byte(row)
		for j, k := 0, len(reversed)-1; j < k; j, k = j+1, k-1 {
			reversed[j], reversed[k] = reversed[k], reversed[j]
		}
		flipped[i] = reversed
	}
	return flipped
}

func canPlace(tile Tile, edges []int, corners_edges Set[int]) bool {
	right_place := 0
	for i, edge := range edges {
		tile_edge := tile.edges[i]
		if edge == UNKNOWN || edge == tile_edge || (edge == CORNER && corners_edges[tile_edge]) {
			right_place += 1
		}
	}
	return right_place == 4
}

func place(tile Tile, i, j int, corners_edges Set[int], image [][]Tile) {
	placed.add(tile.id)
	edges, _ := get_edges(i, j, image)
	for !canPlace(tile, edges, corners_edges) {
		tile = flip(tile)
		if canPlace(tile, edges, corners_edges) {
			break
		}
		tile = rotate(flip(tile))
	}
	image[i][j] = tile
}

func search_and_place(i, j int, tiles map[int]Tile, corners_edges Set[int], image [][]Tile) {
	edges, known_edges := get_edges(i, j, image)
	count_edges := make(map[int]int)
	for _, edge := range edges {
		count_edges[edge] += 1
	}

	var tile Tile
	for _, t := range tiles {
		if placed[t.id] {
			continue
		}
		matches := 0
		for _, edge := range t.edges {
			if count_edges[edge] > 0 {
				matches += 1
			}
		}
		if matches == known_edges {
			tile = t
			break
		}
	}

	if tile.id == 0 {
		panic("Can't find tile")
	}

	place(tile, i, j, corners_edges, image)
}

func is_sean_monster(grid [][]byte, i, j int) (bool, Set[Point]) {
	SEA_MONSTER := []string{
		"                  # ",
		"#    ##    ##    ###",
		" #  #  #  #  #  #   ",
	}
	height := len(grid)
	width := len(grid[0])
	matches := make(Set[Point])
	for di, row := range SEA_MONSTER {
		ni := i + di
		for dj := range row {
			cell := SEA_MONSTER[di][dj]
			nj := j + dj
			if cell == '#' {
				if ni >= 0 && ni < height && nj >= 0 && nj < width && cell == grid[ni][nj] {
					matches.add(Point{ni, nj})
				} else {
					return false, matches
				}

			}
		}
	}
	return true, matches
}

var placed Set[int] = Set[int]{}

func part2(input string) (string, error) {
	tiles, edges := parseTiles(input)

	image := make([][]Tile, IMAGE_SIZE)
	for i := range image {
		image[i] = make([]Tile, IMAGE_SIZE)
	}

	corners := []Tile{}
	corners_edges := make(Set[int])
	for _, tile := range tiles {
		unmatched_edges := 0
		for _, edge := range tile.edges {
			if len(edges[edge]) == 1 {
				unmatched_edges += 1
				corners_edges.add(edge)
			}
		}
		if unmatched_edges == 2 {
			corners = append(corners, tile)
		}
	}

	place(corners[0], 0, 0, corners_edges, image)

	for i := range IMAGE_SIZE {
		for j := range IMAGE_SIZE {
			if !(i == 0 && j == 0) {
				search_and_place(i, j, tiles, corners_edges, image)
			}
		}
	}

	grid := make([][]byte, 8*IMAGE_SIZE)
	for i := range grid {
		grid[i] = make([]byte, 8*IMAGE_SIZE)
	}

	for imi, imrow := range image {
		for imj, tile := range imrow {
			height := len(tile.tile)
			width := len(tile.tile[0])
			for i := 1; i < height-1; i++ {
				for j := 1; j < width-1; j++ {
					grid[(i-1)+imi*8][(j-1)+imj*8] = tile.tile[i][j]
				}
			}
		}
	}
	matches := make(Set[Point])
	c := 0
	for {
		for i, row := range grid {
			for j, _ := range row {
				if ok, m := is_sean_monster(grid, i, j); ok {
					if len(matches.interssection(m)) == 0 {
						matches.add(m.toList()...)
					}
				}
			}
		}
		if len(matches) != 0 {
			break
		}
		if c%2 == 0 {
			grid = flip_grid(grid)
		} else {
			grid = rotate_grid(flip_grid(grid))
		}
		if c == 8 {
			break
		}
		c += 1
	}

	res := 0
	for i, row := range grid {
		for j, cell := range row {
			if cell == '#' && !matches[Point{i, j}] {
				res += 1
			}

		}
	}

	// img_rows := []string{}
	// for _, row := range grid {
	// 	img_rows = append(img_rows, string(row))
	// }
	// img := strings.Join(img_rows, "\n")
	// fmt.Println(img)

	return strconv.Itoa(res), nil
}

func main() {
	// input_file := "sample.txt"
	// IMAGE_SIZE = 3
	input_file := "input.txt"
	IMAGE_SIZE = 12

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
