from collections import defaultdict

def get_map(input: str):
    return [list(line.strip()) for line in input.splitlines()]

def get_regions(x, y, crop, crops_map, visited, region):
    if x not in range(len(crops_map)) or y not in range(len(crops_map[0])):
        return 
    if crops_map[x][y] != crop:
        return 
    if (x, y) in visited:
        return 
    visited.add((x, y))
    region.add((x, y))
    for dx, dy in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
        nx, ny = x + dx, y + dy
        get_regions(nx, ny, crop, crops_map, visited, region)


def add_tuple(t1, t2):
    return (t1[0] + t2[0], t1[1] + t2[1])
def sub_tuple(t1, t2):
    return (t1[0] - t2[0], t1[1] - t2[1])

def part1(input: str):
    crops_map = get_map(input)

    visited: set[tuple[int, int]] = set()
    regions = defaultdict(list)
    for i in range(len(crops_map)):
        for j in range(len(crops_map[0])):
            if (i, j) in visited: continue
            region: set[tuple[int, int]] = set()
            crop = crops_map[i][j]
            get_regions(i, j, crop , crops_map, visited, region)
            regions[crop].append(region)
    
    res = 0
    dirs = [(0, 1), (1, 0), (0, -1), (-1, 0)]
    for crop in regions:
        for region in regions[crop]:
            area = len(region)
            perimeter = 0
            for r in region:
                for di in range(4) :
                    if add_tuple(r, dirs[di]) not in region:
                        perimeter += 1
            res += area * perimeter

    print("Part 1:", res)

    return 0

def part2(input: str):
    crops_map = get_map(input)

    visited: set[tuple[int, int]] = set()
    regions = defaultdict(list)
    for i in range(len(crops_map)):
        for j in range(len(crops_map[0])):
            if (i, j) in visited: continue
            region: set[tuple[int, int]] = set()
            crop = crops_map[i][j]
            get_regions(i, j, crop , crops_map, visited, region)
            regions[crop].append(region)
    
    res = 0
    dirs = [(0, 1), (1, 0), (0, -1), (-1, 0)]
    for crop in regions:
        for region in regions[crop]:
            area = len(region)
            perimeter_set = set()
            for r in region:
                for di in range(4):
                    if add_tuple(r, dirs[di]) not in region:
                        perimeter_set.add((r, di))
            seen = set()
            side_count = 0            
            for p, di in perimeter_set:
                if (p, di) in seen: continue
                seen.add((p, di))
                side_count += 1
                dir = dirs[(di + 1) % 4]
                for d in [dir, sub_tuple((0,0), dir)]:
                    np = p
                    while (np, di) in perimeter_set:
                        seen.add((np, di))
                        np = add_tuple(np, d)

            res += area * side_count

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