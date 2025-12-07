import sys
from functools import cache

def part1(input: str) -> str:
    grid = input.strip().split('\n')
    emitter_x = -1
    for i, c in enumerate(grid[0]):
        if c == 'S':
            emitter_x = i
    assert emitter_x != -1

    splits = 0
    rays = [(emitter_x, 1)]
    visited = set()
    while len(rays) > 0:
        ray = rays.pop()
        next_pos = (ray[0], ray[1] + 1)

        if next_pos[0] < 0 or next_pos[1] < 0 or next_pos[0] >= len(grid[0]) or next_pos[1] >= len(grid): 
            continue
        if ray in visited:
            continue
        visited.add(ray)

        if grid[next_pos[1]][next_pos[0]] == '^':
            splits += 1
            rays.append((next_pos[0] + 1, next_pos[1]))
            rays.append((next_pos[0] - 1, next_pos[1]))
        else:
            rays.append(next_pos)

    return str(splits)


def part2(input: str) -> str:
    grid = input.strip().split('\n')
    emitter_x = -1
    for i, c in enumerate(grid[0]):
        if c == 'S':
            emitter_x = i
    assert emitter_x != -1

    @cache
    def get_num_timelines(ray):
        next_pos = (ray[0], ray[1] + 1)
        
        if next_pos[0] < 0 or next_pos[1] < 0 or next_pos[0] >= len(grid[0]) or next_pos[1] >= len(grid): 
            return 1
        
        if grid[next_pos[1]][next_pos[0]] == '^':
            return get_num_timelines((next_pos[0] + 1, next_pos[1])) + get_num_timelines((next_pos[0] - 1, next_pos[1]))
        
        return get_num_timelines(next_pos)

    return str(get_num_timelines((emitter_x, 1)))

def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()