def get_keys_and_locks(input: str):
    grids = map(str.splitlines, input.split("\n\n"))
    keys = []
    locks = []
    for grid in grids:
        if grid[0] == "#####":
            locks.append(grid)
        elif grid[-1] == "#####":
            keys.append(grid)
        else:
            assert False, "unreachable"
    return keys, locks


def part1(input: str):
    keys, locks = get_keys_and_locks(input)

    locks_heigts = []
    for lock in locks:
        heights = []
        for j in range(len(lock[0])):
            height = -1
            for i in range(len(lock)):
                if lock[i][j] == "#":
                    height += 1
            heights.append(height)
        locks_heigts.append(heights)

    keys_heigts = []
    for key in keys:
        heights = []
        for j in range(len(key[0])):
            height = -1
            for i in range(len(key)):
                if key[len(key) - i - 1][j] == "#":
                    height += 1
            heights.append(height)
        keys_heigts.append(heights)
    
    res = 0
    for lock in locks_heigts:
        for key in keys_heigts:
            if all((kh + lh) <= 5 for lh, kh in zip(lock, key)):
                res += 1
    print("Part 1:", res)
    return 0

def part2(input: str):
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())