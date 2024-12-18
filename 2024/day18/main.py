from heapq import heappop, heappush


def get_bytes(input: str):
    return [tuple(map(int, line.split(",")))[::-1] for line in input.splitlines()]

def add_tuple(t1, t2):
    return (t1[0] + t2[0], t1[1] + t2[1])

def part1(input: str):
    bytes = get_bytes(input)
    width = height = 71
    grid = [["." for _ in range(height)] for _ in range(width)]
    
    for (i, j) in bytes[:1024]:
        grid[i][j] = "#"

    dirs = [(0, 1), (-1, 0), (0, -1), (1, 0)]
    heap = [(0, (0,0))]
    seen = set()
    res = 0
    while len(heap) > 0:
        cur, pos = heappop(heap)
        if pos in seen:
            continue
        seen.add(pos)
        if pos == (width - 1, height - 1):
            res = cur 
            break
        for dir in dirs:
            npos = add_tuple(pos, dir)
            nx, ny = npos
            if 0 <= nx < width and 0 <= ny < height and grid[nx][ny] == ".":
                heappush(heap, (cur + 1, npos))

    print("Part 1:", res)
    return 0

def part2(input: str):
    bytes = get_bytes(input)
    width = height = 71
    max_bytes = 1024
    grid = [["." for _ in range(height)] for _ in range(width)]
    
    for (i, j) in bytes[:max_bytes]:
        grid[i][j] = "#"

    dirs = [(0, 1), (-1, 0), (0, -1), (1, 0)]

    cur_byte = max_bytes
    res = -1
    while res != 0:
        # print(cur_byte)
        nbx, nby = bytes[cur_byte]
        grid[nbx][nby] = "#"
        heap = [(0, (0,0))]
        seen = set()
        res = 0
        while len(heap) > 0:
            cur, pos = heappop(heap)
            if pos in seen:
                continue
            seen.add(pos)
            if pos == (width - 1, height - 1):
                res = cur 
                break
            for dir in dirs:
                npos = add_tuple(pos, dir)
                nx, ny = npos
                if 0 <= nx < width and 0 <= ny < height and grid[nx][ny] == ".":
                    heappush(heap, (cur + 1, npos))
        cur_byte += 1
    rx, ry = bytes[cur_byte - 1][::-1]
    print("Part 2:", f"{rx},{ry}")
    return 0


def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())