from collections import deque

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
    stack = deque([(0, (0,0))])
    seen = set()
    res = 0
    while len(stack) > 0:
        cur, pos = stack.popleft()
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
               stack.append((cur + 1, npos))

    print("Part 1:", res)
    return 0

def part2(input: str):
    bytes = get_bytes(input)
    width = height = 71
    
    def connected(max_bytes):
        grid = [["." for _ in range(height)] for _ in range(width)]
        for (i, j) in bytes[:max_bytes]:
            grid[i][j] = "#"

        dirs = [(0, 1), (-1, 0), (0, -1), (1, 0)]    
        stack = deque([(0,0)])
        seen = set()
        while len(stack) > 0:
            pos = stack.popleft()
            if pos in seen:
                continue
            seen.add(pos)
            if pos == (width - 1, height - 1):
                return True
                break
            for dir in dirs:
                npos = add_tuple(pos, dir)
                nx, ny = npos
                if 0 <= nx < width and 0 <= ny < height and grid[nx][ny] == ".":
                    stack.append(npos)
        return False
    
    # binary search
    lo = 0
    hi = len(bytes) - 1
    while lo < hi:
        mi = (lo + hi)//2
        if connected(mi + 1):
            lo = mi + 1
        else:
            hi = mi
    
    rx, ry = bytes[lo][::-1]
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