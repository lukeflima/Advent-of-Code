from collections import Counter, defaultdict, deque
from heapq import heappop, heappush


def get_grid(input: str):
    return [list(line) for line in input.splitlines()]

dirs = [(0, 1), (-1, 0), (0, -1), (1, 0)]

def add_tuple(t1, t2):
    return (t1[0] + t2[0], t1[1] + t2[1])
def manh_dist_tuple(t1, t2):
    return abs(t1[0] - t2[0]) + abs(t1[1] - t2[1])
                
def part1(input: str):
    grid = get_grid(input)

    inital_pos = (0,0)
    final_pos = (0,0)
    for i in range(len(grid)):
        for j in range(len(grid[0])):
            if grid[i][j] == "S":
                inital_pos = (i, j)
            if grid[i][j] == "E":
                final_pos = (i, j)
    
    heap = [(0, inital_pos, [inital_pos])]
    seen = set() #defaultdict(list)
    final_path_list = []
    pos_time = {}
    while len(heap) > 0:
        time, pos, path = heappop(heap)
        if pos == final_pos:
            pos_time[pos] = time    
            final_path_list = path
            break
        if pos in seen:
            continue
        seen.add(pos)
        pos_time[pos] = time
        for dir in dirs:
            npos = add_tuple(pos, dir)
            nx, ny = npos
            if 0 < nx < len(grid) - 1 and 0 < ny < len(grid[0]) - 1:
                if grid[nx][ny] != "#":
                    heappush(heap, (time + 1, npos, path + [npos]))

    def print_grid(target):
        for i in range(len(grid)):
            for j in range(len(grid[0])):
                if target and target == (i, j):
                    print("X", end="")
                else:
                    print(grid[i][j], end="")
            print()
    
    final_path = set(final_path_list)
    times_saved = []
    for pos in final_path_list[:-1]:
        for dir in dirs:
            npos = add_tuple(pos, dir)
            nx, ny = npos
            if 0 < nx < len(grid) - 1 and 0 < ny < len(grid[0]) - 1:
                if grid[nx][ny] == "#":
                    for dir in dirs:
                        nnpos = add_tuple(npos, dir)
                        if nnpos != pos and nnpos in final_path:
                            time_saved = pos_time[nnpos] - pos_time[pos] - 2
                            if time_saved > 0:
                                times_saved.append(time_saved)
                
    print("Part 1:", sum(1 for i in times_saved if i >= 100))
    return 0

def part2(input: str):
    grid = get_grid(input)

    inital_pos = (0,0)
    final_pos = (0,0)
    for i in range(len(grid)):
        for j in range(len(grid[0])):
            if grid[i][j] == "S":
                inital_pos = (i, j)
            if grid[i][j] == "E":
                final_pos = (i, j)
    
    heap = [(0, inital_pos, [inital_pos])]
    seen = set()
    final_path_list = []
    while len(heap) > 0:
        time, pos, path = heappop(heap)
        if pos == final_pos:  
            final_path_list = path
            break
        if pos in seen:
            continue
        seen.add(pos)
        for dir in dirs:
            npos = add_tuple(pos, dir)
            nx, ny = npos
            if 0 < nx < len(grid) - 1 and 0 < ny < len(grid[0]) - 1:
                if grid[nx][ny] != "#":
                    heappush(heap, (time + 1, npos, path + [npos]))
    
    optimal_time = len(final_path_list) - 1
    res = 0
    for i1, p1 in enumerate(final_path_list):
        for i2, p2 in enumerate(final_path_list):
            dist = manh_dist_tuple(p1, p2)
            if dist <= 20:
                if i1 + dist + (optimal_time - i2) <= optimal_time - 100:
                    res += 1

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