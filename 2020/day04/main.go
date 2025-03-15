package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func part1(input string) (string, error) {
	required_feilds := []string{"byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"}
	passaports_str := strings.Split(input, "\n\n")
	res := 0
	for _, passaport_str := range passaports_str {
		passport := make(map[string]string)
		passaport_str = strings.ReplaceAll(passaport_str, "\n", " ")
		parts := strings.Split(passaport_str, " ")
		for _, part := range parts {
			kv := strings.Split(part, ":")
			passport[kv[0]] = kv[1]
		}
		valid := true
		for _, feild := range required_feilds {
			if _, ok := passport[feild]; !ok {
				valid = false
				break
			}
		}
		if valid {
			res++
		}
	}
	return strconv.Itoa(res), nil
}

func part2(input string) (string, error) {
	required_feilds := []string{"byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"}
	passaports_str := strings.Split(input, "\n\n")
	res := 0
	for _, passaport_str := range passaports_str {
		passport := make(map[string]string)
		passaport_str = strings.ReplaceAll(passaport_str, "\n", " ")
		parts := strings.Split(passaport_str, " ")
		for _, part := range parts {
			kv := strings.Split(part, ":")
			passport[kv[0]] = kv[1]
		}
		valid := true
		for _, feild := range required_feilds {
			if _, ok := passport[feild]; !ok {
				valid = false
				break
			}
		}
		if !valid {
			continue
		}

		if len(passport["byr"]) != 4 {
			continue
		}
		byr, err := strconv.Atoi(passport["byr"])
		if err != nil {
			continue
		}
		if byr < 1920 || byr > 2002 {
			continue
		}

		iyr, err := strconv.Atoi(passport["iyr"])
		if err != nil {
			continue
		}
		if iyr < 2010 || iyr > 2020 {
			continue
		}

		eyr, err := strconv.Atoi(passport["eyr"])
		if err != nil {
			continue
		}
		if eyr < 2020 || eyr > 2030 {
			continue
		}

		hgt := passport["hgt"]
		if strings.HasSuffix(hgt, "cm") {
			hgt_cm, err := strconv.Atoi(strings.TrimSuffix(hgt, "cm"))
			if err != nil {
				continue
			}
			if hgt_cm < 150 || hgt_cm > 193 {
				continue
			}
		} else if strings.HasSuffix(hgt, "in") {
			hgt_in, err := strconv.Atoi(strings.TrimSuffix(hgt, "in"))
			if err != nil {
				continue
			}
			if hgt_in < 59 || hgt_in > 76 {
				continue
			}
		} else {
			continue
		}

		hcl := passport["hcl"]
		if len(hcl) != 7 || hcl[0] != '#' {
			continue
		}
		valid = true
		for i := 1; i < len(hcl); i++ {
			if !((hcl[i] >= '0' && hcl[i] <= '9') || (hcl[i] >= 'a' && hcl[i] <= 'f')) {
				valid = false
				break
			}
		}
		if !valid {
			continue
		}
		ecl := passport["ecl"]
		if ecl != "amb" && ecl != "blu" && ecl != "brn" && ecl != "gry" && ecl != "grn" && ecl != "hzl" && ecl != "oth" {
			continue
		}
		pid := passport["pid"]
		if len(pid) != 9 {
			continue
		}
		_, err = strconv.Atoi(pid)
		if err != nil {
			continue
		}
		res++
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
