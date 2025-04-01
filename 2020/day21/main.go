package main

import (
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"
)

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

func parseIngridients(line string) ([]string, []string) {
	parts := strings.Split(line, " (")
	allergens_str := strings.Split(parts[1][:len(parts[1])-1], "contains ")[1]
	return strings.Split(parts[0], " "), strings.Split(allergens_str, ", ")
}

func part1(input string) (string, error) {
	lines := strings.Split(input, "\n")
	allergens := make(map[string]Set[string])
	ingredients := make(map[string]int)

	for _, line := range lines {
		ingr, allerg := parseIngridients(line)

		for _, i := range ingr {
			ingredients[i]++
		}

		ingrSet := makeSetFromList(ingr)
		for _, a := range allerg {
			if _, exists := allergens[a]; !exists {
				allergens[a] = ingrSet
			} else {
				allergens[a] = allergens[a].interssection(ingrSet)
			}
		}
	}

	res := 0
	for ing, count := range ingredients {
		possible := false
		for _, a := range allergens {
			if a[ing] {
				possible = true
				break
			}
		}
		if !possible {
			res += count
		}
	}

	return strconv.Itoa(res), nil
}

func part2(input string) (string, error) {
	lines := strings.Split(input, "\n")
	allergens := make(map[string]Set[string])
	ingredients := make(map[string]int)

	for _, line := range lines {
		ingr, allerg := parseIngridients(line)

		for _, i := range ingr {
			ingredients[i]++
		}

		ingrSet := makeSetFromList(ingr)
		for _, a := range allerg {
			if _, exists := allergens[a]; !exists {
				allergens[a] = ingrSet
			} else {
				allergens[a] = allergens[a].interssection(ingrSet)
			}
		}
	}

	allergenMap := make(map[string]string)
	for len(allergenMap) < len(allergens) {
		for allergen, ingredients := range allergens {
			if _, mapped := allergenMap[allergen]; mapped {
				continue
			}

			possibleIngredients := make([]string, 0)
			for ingredient := range ingredients {
				alreadyMapped := false
				for _, mappedIngr := range allergenMap {
					if mappedIngr == ingredient {
						alreadyMapped = true
						break
					}
				}
				if !alreadyMapped {
					possibleIngredients = append(possibleIngredients, ingredient)
				}
			}

			if len(possibleIngredients) == 1 {
				allergenMap[allergen] = possibleIngredients[0]
			}
		}
	}

	allergenList := make([]string, 0, len(allergenMap))
	for allergen := range allergenMap {
		allergenList = append(allergenList, allergen)
	}
	sort.Strings(allergenList)

	dangerousIngredients := make([]string, len(allergenList))
	for i, allergen := range allergenList {
		dangerousIngredients[i] = allergenMap[allergen]
	}

	return strings.Join(dangerousIngredients, ","), nil
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
