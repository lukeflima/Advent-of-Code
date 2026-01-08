import sys

def part1(input: str) -> str:
    blocks = input.strip().split("\n\n")
    areas = blocks.pop()
    areas = [area.split(":") for area in areas.split("\n")]
    areas = [(tuple(map(int,area[0].split("x"))), list(map(int,area[1].split()))) for area in areas]
    presents = [block.count("#") for block in blocks]
    
    res = 0
    for (area_dim, presents_to_fit) in areas:
        area = area_dim[0] * area_dim[1]
        area_presents = sum(presents[i]*v for i, v in enumerate(presents_to_fit))
        if area_presents <= area:
            res += 1

    return str(res)

def part2(input: str) -> str:
    return ""

def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()