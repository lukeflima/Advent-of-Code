package main

import (
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

func contains_in_bag(target, bag_name string, bags map[string]([]string)) bool {
	bag := bags[bag_name]
	if len(bag) == 0 {
		return false
	}

	if slices.Contains(bag, target) {
		return true
	}

	for _, b := range bag {
		if contains_in_bag(target, b, bags) {
			return true
		}
	}

	return false
}

func part1(input string) (string, error) {
	bags_str := strings.Split(strings.TrimSpace(input), "\n")
	bags := make(map[string]([]string))
	for _, bag_str := range bags_str {
		bag_parts := strings.Split(bag_str, " bags contain ")
		bag := bag_parts[0]
		contains := strings.Split(bag_parts[1], ", ")
		for _, contain := range contains {
			if strings.Contains(contain, "no other") {
				continue
			}
			contain_parts := strings.Split(contain, " ")
			contain_bag := strings.Join(contain_parts[1:len(contain_parts)-1], " ")
			bags[bag] = append(bags[bag], contain_bag)
		}
	}
	res := 0
	for bag_name := range bags {
		if contains_in_bag("shiny gold", bag_name, bags) {
			res++
		}
	}

	return strconv.Itoa(res), nil
}

type Bag struct {
	name   string
	amount int
}

func number_of_bags(bag_name string, bags map[string]([]Bag)) int {
	bag := bags[bag_name]
	if len(bag) == 0 {
		return 0
	}

	res := 0
	for _, b := range bag {
		res += b.amount + b.amount*number_of_bags(b.name, bags)
	}

	return res
}

func part2(input string) (string, error) {
	bags_str := strings.Split(strings.TrimSpace(input), "\n")
	bags := make(map[string]([]Bag))
	for _, bag_str := range bags_str {
		bag_parts := strings.Split(bag_str, " bags contain ")
		bag := bag_parts[0]
		contains := strings.Split(bag_parts[1], ", ")
		for _, contain := range contains {
			if strings.Contains(contain, "no other") {
				continue
			}
			contain_parts := strings.Split(contain, " ")
			amount, err := strconv.Atoi(contain_parts[0])
			if err != nil {
				return "", err
			}
			contain_bag := Bag{
				name:   strings.Join(contain_parts[1:len(contain_parts)-1], " "),
				amount: amount,
			}
			bags[bag] = append(bags[bag], contain_bag)
		}
	}
	res := number_of_bags("shiny gold", bags)

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
