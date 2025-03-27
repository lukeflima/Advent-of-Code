package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Range struct {
	min int
	max int
}

func (r Range) inRange(n int) bool {
	return n >= r.min && n <= r.max
}

type Class struct {
	ranges []Range
}

func (c Class) inRange(n int) bool {
	for _, r := range c.ranges {
		if r.inRange(n) {
			return true
		}
	}
	return false
}

func part1(input string) (string, error) {
	blocks := strings.Split(input, "\n\n")
	classes := make(map[string]Class)
	for _, line := range strings.Split(blocks[0], "\n") {
		parts := strings.Split(line, ": ")
		name := parts[0]
		ranges := strings.Split(parts[1], " or ")
		var r []Range
		for _, r_str := range ranges {
			var min, max int
			fmt.Sscanf(r_str, "%d-%d", &min, &max)
			r = append(r, Range{min, max})
		}
		classes[name] = Class{r}
	}
	res := 0
	for _, line := range strings.Split(blocks[2], "\n")[1:] {
		for _, n_str := range strings.Split(line, ",") {
			var n int
			fmt.Sscanf(n_str, "%d", &n)
			valid := false
			for _, c := range classes {
				if c.inRange(n) {
					valid = true
				}
			}
			if !valid {
				res += n
			}
		}
	}
	return strconv.Itoa(res), nil
}

type Ticket []int

func (ticket Ticket) isValid(classes map[string]Class) bool {
	for _, n := range ticket {
		valid := false
		for _, c := range classes {
			if c.inRange(n) {
				valid = true
			}
		}
		if !valid {
			return false
		}
	}
	return true
}

func parseTicket(line string) Ticket {
	ticket := Ticket{}
	for _, n_str := range strings.Split(line, ",") {
		n, _ := strconv.Atoi(n_str)
		ticket = append(ticket, n)
	}
	return ticket
}

func part2(input string) (string, error) {
	blocks := strings.Split(input, "\n\n")
	classes := make(map[string]Class)
	for _, line := range strings.Split(blocks[0], "\n") {
		parts := strings.Split(line, ": ")
		name := parts[0]
		ranges := strings.Split(parts[1], " or ")
		var r []Range
		for _, r_str := range ranges {
			var min, max int
			fmt.Sscanf(r_str, "%d-%d", &min, &max)
			r = append(r, Range{min, max})
		}
		classes[name] = Class{r}
	}

	tickets := [][]int{}
	tickets = append(tickets, parseTicket(strings.Split(blocks[1], "\n")[1]))

	for _, line := range strings.Split(blocks[2], "\n")[1:] {
		ticket := parseTicket(line)
		if ticket.isValid(classes) {
			tickets = append(tickets, ticket)
		}
	}

	ids := []map[string]bool{}
	for i := 0; i < len(tickets[0]); i++ {
		ids = append(ids, make(map[string]bool))
		for name := range classes {
			ids[i][name] = true
		}
	}
	for _, ticket := range tickets {
		for i, n := range ticket {
			for name, c := range classes {
				if !c.inRange(n) {
					delete(ids[i], name)
				}
			}
		}
	}

	changed := true
	for changed {
		changed = false
		for i, id := range ids {
			if len(id) == 1 {
				for j, id2 := range ids {
					if i != j {
						for name := range id {
							if id2[name] {
								delete(id2, name)
								changed = true
							}
						}
					}
				}
			}
		}
	}

	res := 1
	for i, id := range ids {
		for name := range id {
			if strings.HasPrefix(name, "departure") {
				res *= tickets[0][i]
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
