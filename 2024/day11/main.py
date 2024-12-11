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


@lru_cache(maxsize=None)
def rule(stone, rounds):
    result = 0
    if rounds == 0:
        return 1
    if stone == 0:
        result = rule(1, rounds-1)
    elif len(str(stone))%2 == 0:
        mid_point = len(str(stone))//2
        result += rule(int(str(stone)[:mid_point]), rounds - 1)
        result += rule(int(str(stone)[mid_point:]), rounds - 1)
    else:
        result = rule(stone * 2024, rounds - 1)
    return result


def part2(input: str):
    stones = list(map(int, get_stones(input)))
    print("Part 2:", sum(rule(stone, 75) for stone in stones))
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())