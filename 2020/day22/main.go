package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func parsePlayer(block string) []int {
	deck := []int{}
	for _, line := range strings.Split(block, "\n")[1:] {
		num, _ := strconv.Atoi(line)
		deck = append(deck, num)
	}
	return deck
}

func pop[T any](l []T) (T, []T) {
	return l[0], l[1:]
}

func part1(input string) (string, error) {
	blocks := strings.Split(input, "\n\n")
	player1 := parsePlayer(blocks[0])
	player2 := parsePlayer(blocks[1])
	topdeck1 := -1
	topdeck2 := -1
	for len(player1) > 0 && len(player2) > 0 {
		topdeck1, player1 = pop(player1)
		topdeck2, player2 = pop(player2)
		if topdeck1 > topdeck2 {
			player1 = append(player1, topdeck1, topdeck2)
		} else {
			player2 = append(player2, topdeck2, topdeck1)
		}
	}
	winner_player := player1
	if len(player2) > 0 {
		winner_player = player2
	}

	res := 0
	lenght := len(winner_player)
	for i, card := range winner_player {
		res += card * (lenght - i)
	}

	return strconv.Itoa(res), nil
}

var gameCount int = 1

func copySlice[T any](list []T) []T {
	return append([]T{}, list...)
}

func play_game(player1, player2 []int, game int, hands map[string]bool) (int, []int) {
	player1str := fmt.Sprint(player1)
	player2str := fmt.Sprint(player2)
	if hands[player1str] || hands[player2str] {
		return 1, player1
	}
	hands[player1str] = true
	hands[player2str] = true

	if len(player1) == 0 {
		return 2, player2
	}
	if len(player2) == 0 {
		return 1, player1
	}

	topdeck1 := -1
	topdeck2 := -1
	topdeck1, player1 = pop(player1)
	topdeck2, player2 = pop(player2)
	winner := 2
	if topdeck1 > topdeck2 {
		winner = 1
	}
	if topdeck1 <= len(player1) && topdeck2 <= len(player2) {
		gameCount += 1
		winner, _ = play_game(copySlice(player1[:topdeck1]), copySlice(player2[:topdeck2]), gameCount, make(map[string]bool))
	}

	if winner == 1 {
		player1 = append(player1, topdeck1, topdeck2)
	} else {
		player2 = append(player2, topdeck2, topdeck1)
	}

	return play_game(player1, player2, game, hands)
}

func part2(input string) (string, error) {
	blocks := strings.Split(input, "\n\n")
	player1 := parsePlayer(blocks[0])
	player2 := parsePlayer(blocks[1])

	hands := make(map[string]bool)
	_, deck := play_game(player1, player2, gameCount, hands)

	res := 0
	lenght := len(deck)
	for i, card := range deck {
		res += card * (lenght - i)
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
