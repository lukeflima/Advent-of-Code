from collections import defaultdict, deque
from heapq import heappush, heappop

def get_grid(input: str):
    return [list(line) for line in input.splitlines()]

dirs = [(0, 1), (-1, 0), (0, -1), (1, 0)]

def add_tuple(t1, t2):
    return (t1[0] + t2[0], t1[1] + t2[1])
                
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

    heap = [(0, inital_pos, 0)]
    seen = set()
    min_cost = float("inf")
    while len(heap) > 0:
        cost, pos, di = heappop(heap)

        if (pos, di) in seen: continue
        seen.add((pos, di))

        if pos == final_pos:
            min_cost = cost
            break

        heappush(heap, (cost + 1000, pos, (di + 1)%4))
        heappush(heap, (cost + 1000, pos, (di - 1)%4))

        new_pos = add_tuple(pos, dirs[di])
        if grid[new_pos[0]][new_pos[1]] != "#":
            heappush(heap, (cost + 1, new_pos, di))
        

    print("Part 1:", min_cost)
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

    def adjacents(pos, di, grid):
        yield (1000, pos, (di + 1) % 4)
        yield (1000, pos, (di - 1) % 4)
        npos = add_tuple(pos, dirs[di])
        if grid[npos[0]][npos[1]] != "#":
            yield (1, npos, di)

    heap = [(0, inital_pos, 0)]
    lowest_cost: dict[tuple[tuple[int, int], int], int | float] = defaultdict(lambda : float("inf"))
    lowest_cost[(inital_pos, 0)] =  0
    back_track: dict[tuple[tuple[int, int], int], set[tuple[tuple[int, int], int]]] = defaultdict(set)
    min_cost = float("inf")
    end_states = set()
    while heap:
        cost, pos, di = heappop(heap)

        if cost > lowest_cost[(pos, di)]: continue

        if pos == final_pos:
            if cost > min_cost: break
            min_cost = cost
            end_states.add((pos, di))

        for added_cost, npos, ndi in adjacents(pos, di, grid):
            new_cost = cost + added_cost
            lowest = lowest_cost[(npos, ndi)]
            if new_cost > lowest: continue
            if new_cost < lowest:
                back_track[(npos, ndi)] = set() 
                lowest_cost[(npos, ndi)] = new_cost
            back_track[(npos, ndi)].add((pos, di))
            heappush(heap, (new_cost, npos, ndi))

    stack = deque(end_states)
    seats_pos_plus_dir = set(end_states)
    while stack:
        for last in back_track.get(stack.popleft(), []):
            if last in seats_pos_plus_dir: continue
            seats_pos_plus_dir.add(last)
            stack.append(last)
    seat_pos = set(x[0] for x in seats_pos_plus_dir)
    print("Part 2:", len(seat_pos))
    return 0


def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())