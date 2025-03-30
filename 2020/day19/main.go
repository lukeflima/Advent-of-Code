package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type RuleType int

const (
	Char  RuleType = iota
	Chain RuleType = iota
)

type Rule struct {
	typ    RuleType
	num    int
	char   rune
	chains [][]int
}

func parseLine(line string) Rule {
	parts := strings.Split(line, ": ")
	rule_num, _ := strconv.Atoi(parts[0])
	if strings.HasPrefix(parts[1], "\"") {
		return Rule{
			num:  rule_num,
			typ:  Char,
			char: rune(parts[1][1]),
		}
	}
	parts = strings.Split(parts[1], " | ")
	chains := [][]int{}
	for _, chain_str := range parts {
		chain := []int{}
		ps := strings.Split(chain_str, " ")
		for _, r := range ps {
			num, _ := strconv.Atoi(r)
			chain = append(chain, num)
		}
		chains = append(chains, chain)
	}
	return Rule{
		num:    rule_num,
		typ:    Chain,
		chains: chains,
	}
}

func applyRule(message string, ruleNum int, rules map[int]Rule) (bool, int) {
	rule := rules[ruleNum]

	switch rule.typ {
	case Char:
		return strings.HasPrefix(message, string(rule.char)), 1
	case Chain:
		for _, chain := range rule.chains {
			matches := true
			consumed := 0
			for _, r := range chain {
				m, c := applyRule(message[consumed:], r, rules)
				if m == false {
					matches = false
					break
				}
				consumed += c
			}
			if matches {
				return true, consumed
			}
		}
		return false, 0
	}
	panic("Unreachable")
}

func part1(input string) (string, error) {
	blocks := strings.Split(input, "\n\n")

	rules := make(map[int]Rule)
	for _, line := range strings.Split(blocks[0], "\n") {
		rule := parseLine(line)
		rules[rule.num] = rule
	}
	res := 0
	for _, line := range strings.Split(blocks[1], "\n") {
		if ok, cosumed := applyRule(line, 0, rules); ok && cosumed == len(line) {
			res += 1
		}
	}
	return strconv.Itoa(res), nil
}

func applyRuleP2Possibles(message string, ruleNum int, rules map[int]Rule) []int {
	rule := rules[ruleNum]

	switch rule.typ {
	case Char:
		if strings.HasPrefix(message, string(rule.char)) {
			return []int{1}
		}
		return []int{}
	case Chain:
		possible := []int{}
		for _, chain := range rule.chains {
			currentPossible := []int{0}
			for _, r := range chain {
				newPossible := []int{}
				for _, cp := range currentPossible {
					for _, sp := range applyRuleP2Possibles(message[cp:], r, rules) {
						newPossible = append(newPossible, cp+sp)
					}
				}
				currentPossible = newPossible
				if len(currentPossible) == 0 {
					break
				}
			}
			possible = append(possible, currentPossible...)
		}
		return possible
	}
	panic("Unreachable")
}

func applyRuleP2(message string, ruleNum int, rules map[int]Rule) bool {
	for _, p := range applyRuleP2Possibles(message, ruleNum, rules) {
		if p == len(message) {
			return true
		}
	}
	return false
}

func part2(input string) (string, error) {
	blocks := strings.Split(input, "\n\n")

	rules := make(map[int]Rule)
	for _, line := range strings.Split(blocks[0], "\n") {
		rule := parseLine(line)
		rules[rule.num] = rule
	}

	rules[8] = parseLine("8: 42 | 42 8")
	rules[11] = parseLine("11: 42 31 | 42 11 31")

	res := 0
	for _, line := range strings.Split(blocks[1], "\n") {
		if applyRuleP2(line, 0, rules) {
			res++
		}
	}
	return strconv.Itoa(res), nil
}

func main() {
	input_file := "input.txt"
	// input_file := "sample.txt"

	input_bytes, err := os.ReadFile(input_file)
	if err != nil {
		fmt.Println("Error:", err)
		os.Exit(1)
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
