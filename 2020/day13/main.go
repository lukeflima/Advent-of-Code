package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func part1(input string) (string, error) {
	lines := strings.Split(input, "\n")
	timestamp, _ := strconv.Atoi(lines[0])
	buses := strings.Split(lines[1], ",")
	min_wait := 1000000
	min_bus := 0
	for _, bus := range buses {
		if bus == "x" {
			continue
		}
		bus_id, _ := strconv.Atoi(bus)
		wait := bus_id - (timestamp % bus_id)
		if wait < min_wait {
			min_wait = wait
			min_bus = bus_id
		}
	}
	return strconv.Itoa(min_wait * min_bus), nil
}

func part2(input string) (string, error) {
	lines := strings.Split(input, "\n")
	// timestamp, _ := strconv.Atoi(lines[0])
	buses := strings.Split(lines[1], ",")
	bus_ids := make([]int, 0)
	bus_offsets := make([]int, 0)
	for i, bus := range buses {
		if bus == "x" {
			continue
		}
		num, _ := strconv.Atoi(bus)
		bus_ids = append(bus_ids, num)
		bus_offsets = append(bus_offsets, i)
	}
	res := bus_ids[0]
	increment := bus_ids[0]
	for i := 1; i < len(bus_ids); i++ {
		for (res+bus_offsets[i])%bus_ids[i] != 0 {
			res += increment
		}
		increment *= bus_ids[i]
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
