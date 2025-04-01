package main

import (
	"fmt"
	"os"
	"slices"
	"sort"
	"strconv"
	"strings"
)

func parseCups(input string) []int {
	cups := make([]int, len(input))
	for i := range input {
		cups[i] = int(input[i] - '0')
	}
	return cups
}

func remove(slice []int, s int) []int {
	return append(slice[:s], slice[s+1:]...)
}

func popRemoved(cups []int, i int) ([]int, []int) {
	removed := []int{}
	removed_index := []int{}
	for range 3 {
		i = (i + 1) % len(cups)
		removed = append(removed, cups[i])
		removed_index = append(removed_index, i)
	}
	sort.Slice(removed_index, func(i, j int) bool {
		return removed_index[i] > removed_index[j]
	})
	for _, i := range removed_index {
		cups = remove(cups, i)
	}
	return removed, cups
}

func findNextIndex(cups []int, num int) (int, int) {
	for {
		num -= 1
		index := slices.Index(cups, num)
		if index != -1 {
			return index, num
		}
		if num == 0 {
			num = 10
		}
	}
}

func part1(input string) (string, error) {
	cups := parseCups(input)
	curIndex := 0
	removed := []int{}
	for range 100 {
		cur := cups[curIndex]
		removed, cups = popRemoved(cups, curIndex)
		nextIndex, _ := findNextIndex(cups, cur)
		left := append(removed, cups[nextIndex+1:]...)
		cups = append(cups[:nextIndex+1], left...)
		curIndex = (slices.Index(cups, cur) + 1) % len(cups)
	}

	index1 := slices.Index(cups, 1)
	res := []byte{}
	for i := range len(cups) - 1 {
		res = append(res, byte(cups[(index1+i+1)%len(cups)]+'0'))
	}
	return string(res), nil
}

type Node[T any] struct {
	data  T
	right *Node[T]
	left  *Node[T]
}

type LinkedList[T any] struct {
	head *Node[T]
	tail *Node[T]
}

func (list *LinkedList[T]) push(value T) {
	if list.tail == nil {
		list.head = &Node[T]{data: value}
		list.tail = list.head
	} else {
		list.tail.right = &Node[T]{data: value, left: list.tail}
		list.tail = list.tail.right
	}
}

func listToLinkedList[T any](list []T) LinkedList[T] {
	linkedList := LinkedList[T]{}
	for _, value := range list {
		linkedList.push(value)
	}
	return linkedList
}

func getRemoved(cup *Node[int]) ([]int, []*Node[int]) {
	removed := []int{}
	removedNodes := []*Node[int]{}
	cur := cup
	for range 3 {
		cur = cur.right
		removed = append(removed, cur.data)
		removedNodes = append(removedNodes, cur)
	}
	cup.right = cur.right
	cur.right.left = cup
	return removed, removedNodes
}

func findNext(cur *Node[int], removed []int) int {
	num := cur.data
	for {
		num -= 1
		if num == 0 {
			num = 1_000_000
		}
		if !slices.Contains(removed, num) {
			return num
		}
	}
}

func part2(input string) (string, error) {
	cupsList := parseCups(input)
	cups := listToLinkedList(cupsList)
	m := slices.Max(cupsList)
	for m < 1_000_000 {
		m += 1
		cups.push(m)
	}
	cupToNode := map[int]*Node[int]{}
	for cur := cups.head; cur != nil; cur = cur.right {
		cupToNode[cur.data] = cur
	}

	cups.head.left = cups.tail
	cups.tail.right = cups.head

	cur := cups.head
	for range 10_000_000 {
		removed, removedNodes := getRemoved(cur)
		nextCup := findNext(cur, removed)

		next := cupToNode[nextCup]
		nextRight := next.right
		next.right = removedNodes[0]
		removedNodes[0].left = next
		removedNodes[2].right = nextRight
		nextRight.left = removedNodes[2]

		cur = cur.right
	}

	node1 := cupToNode[1]
	res := node1.right.data * node1.right.right.data

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
