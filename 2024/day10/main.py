import functools


def get_grid(input: str):
    return [list(map(int, line)) for line in input.splitlines()]


def dfg(grid, x: int, y: int, visited_nines: set[tuple[int, int]], value: int = -1):
    if not (0 <= x < len(grid) and 0 <= y < len(grid[0])):
        return 0

    cell = grid[x][y]
    if cell == value + 1:
        if cell == 9:
            if (x, y) not in visited_nines:
                visited_nines.add((x,y))
                return 1
            return 0
        new_dfg = functools.partial(dfg, grid = grid, visited_nines=visited_nines, value = cell)
        return new_dfg(x=x, y=y+1) + new_dfg(x=x+1, y=y) + new_dfg(x=x, y=y-1) + new_dfg(x=x-1, y=y)

    return 0

def dfg2(grid, x: int, y: int, value: int = -1):
    if not (0 <= x < len(grid) and 0 <= y < len(grid[0])):
        return 0

    cell = grid[x][y]
    if cell == value + 1:
        if cell == 9:
            return 1
        new_dfg = functools.partial(dfg2, grid = grid, value = cell)
        return new_dfg(x=x, y=y+1) + new_dfg(x=x+1, y=y) + new_dfg(x=x, y=y-1) + new_dfg(x=x-1, y=y)

    return 0


def part1(input: str):
    grid = get_grid(input)
    res = 0
    for row in range(len(grid)):
        for col in range(len(grid[0])):
            if grid[row][col] == 0:
                visited_nines: set[tuple[int, int]] = set()
                res += dfg(grid, row, col, visited_nines)

    print("Part 1:", res)

    return 0

def part2(input: str):
    grid = get_grid(input)
    res = 0
    for row in range(len(grid)):
        for col in range(len(grid[0])):
            if grid[row][col] == 0:
                res += dfg2(grid, row, col)

    print("Part 2:", res)
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())