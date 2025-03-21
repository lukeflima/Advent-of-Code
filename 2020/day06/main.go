package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func part1(input string) (string, error) {
	votes := strings.Split(input, "\n\n")
	res := 0
	for _, vote := range votes {
		answers := ['z' - 'a' + 1]bool{}
		vote = strings.ReplaceAll(vote, "\n", "")
		for _, c := range vote {
			answers[c-'a'] = true
		}
		for _, a := range answers {
			if a {
				res++
			}
		}
	}
	return strconv.Itoa(res), nil
}

func part2(input string) (string, error) {
	votes := strings.Split(input, "\n\n")
	res := 0
	for _, vote := range votes {
		answers := ['z' - 'a' + 1]int{}
		vote_without_newline := strings.ReplaceAll(vote, "\n", "")
		for _, c := range vote_without_newline {
			answers[c-'a'] += 1
		}
		vote_size := len(strings.Split(vote, "\n"))
		for _, a := range answers {
			if a == vote_size {
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
