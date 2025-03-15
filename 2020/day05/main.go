package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func part1(input string) (string, error) {
	seats := strings.Split(input, "\n")
	max_seat_id := 0
	for _, seat := range seats {
		row_l := 0
		row_h := 127
		for _, c := range seat[:7] {
			if c == 'F' {
				row_h = row_l + (row_h-row_l)/2
			} else {
				row_l = row_l + (row_h-row_l)/2 + 1
			}
		}
		row := row_l

		col_l := 0
		col_h := 7
		for _, c := range seat[7:] {
			if c == 'L' {
				col_h = col_l + (col_h-col_l)/2
			} else {
				col_l = col_l + (col_h-col_l)/2 + 1
			}
		}
		col := col_l

		seat_id := row*8 + col
		if seat_id > max_seat_id {
			max_seat_id = seat_id
		}
	}
	return strconv.Itoa(max_seat_id), nil

}

func part2(input string) (string, error) {
	seats := strings.Split(input, "\n")
	seat_ids := make(map[int]bool)
	for _, seat := range seats {
		row_l := 0
		row_h := 127
		for _, c := range seat[:7] {
			if c == 'F' {
				row_h = row_l + (row_h-row_l)/2
			} else {
				row_l = row_l + (row_h-row_l)/2 + 1
			}
		}
		row := row_l

		col_l := 0
		col_h := 7
		for _, c := range seat[7:] {
			if c == 'L' {
				col_h = col_l + (col_h-col_l)/2
			} else {
				col_l = col_l + (col_h-col_l)/2 + 1
			}
		}
		col := col_l

		seat_id := row*8 + col
		seat_ids[seat_id] = true
	}
	for i := 1; i < len(seats); i++ {
		if !seat_ids[i] && seat_ids[i-1] && seat_ids[i+1] {
			return strconv.Itoa(i), nil
		}
	}
	return "", fmt.Errorf("Seat not found")
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
