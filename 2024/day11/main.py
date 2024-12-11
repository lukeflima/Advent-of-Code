from collections import defaultdict
from functools import lru_cache
import json

def get_stones(input: str):
    return input.strip().split()

def part1(input: str):
    stones = get_stones(input)
    for i in range(0, 25):
        new_stones = []
        for stone in stones:
            if stone == '0':
                new_stones.append('1')
            elif len(stone)%2 == 0:
                mid_point = len(stone)//2
                new_stones.append(str(int(stone[:mid_point])))
                new_stones.append(str(int(stone[mid_point:])))
            else:
                new_stones.append(str(int(stone) * 2024))
        stones = new_stones
    print("Part 1:", len(stones))

    return 0

def part2(input: str):
    original_input = input

    # GEN MAP
    # map_digit_to_rounds: dict[int, dict[int, int]] = defaultdict(dict)
    # for digit in range(10):
    #     print(digit)
    #     input = str(digit)
    #     map_digit_to_rounds[digit][0] = 1
    #     stones = list(map(int, get_stones(input)))
    #     for i in range(0, 45):
    #         new_stones = []
    #         for stone in stones:                    
    #             stone_str = str(stone)
    #             if stone == 0:
    #                 new_stones.append(1)
    #             elif len(stone_str)%2 == 0:
    #                 mid_point = len(stone_str)//2
    #                 new_stones.append(int(stone_str[:mid_point]))
    #                 new_stones.append(int(stone_str[mid_point:]))
    #             else:
    #                 new_stones.append(stone * 2024)
    #         map_digit_to_rounds[digit][i + 1] = len(new_stones)
    #         stones = new_stones
    # json.dump(map_digit_to_rounds, open("map.json", "w"))

    map_digit_to_rounds = json.load(open("map.json"))
    map_digit_to_rounds = {int(k):{int(k1):v1 for k1,v1 in v.items()} for k,v in map_digit_to_rounds.items()}
    stones = list(map(int, get_stones(original_input)))
    digits = []
    rounds = 75
    for i in range(0, rounds):
        new_stones = []
        for stone in stones:
            if stone in map_digit_to_rounds and rounds - i in map_digit_to_rounds[stone] :
                digits.append((stone, i))
                continue
            stone_str = str(stone)
            if stone == 0:
                new_stones.append(1)
            elif len(stone_str)%2 == 0:
                mid_point = len(stone_str)//2
                new_stones.append(int(stone_str[:mid_point]))
                new_stones.append(int(stone_str[mid_point:]))
            else:
                new_stones.append(stone * 2024)
        stones = new_stones


    print("Part 2:", len(stones) + sum(map_digit_to_rounds[d][i - j + 1] for d, j in digits))
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())