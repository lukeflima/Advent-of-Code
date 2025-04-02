package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func hash(subjectNumber, loopSize int) int {
	res := 1
	for range loopSize {
		res = (res * subjectNumber) % 20201227
	}
	return res
}

func part1(input string) (string, error) {
	keys := []int{}
	for _, line := range strings.Split(input, "\n") {
		num, _ := strconv.Atoi(line)
		keys = append(keys, num)
	}

	h := 1
	i := 1
	for ; ; i += 1 {
		h = (h * 7) % 20201227
		if keys[0] == h {
			break
		}
	}
	res := hash(keys[1], i)

	return strconv.Itoa(res), nil
}

func main() {
	input_file := "sample.txt"
	// input_file := "input.txt"

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

}
