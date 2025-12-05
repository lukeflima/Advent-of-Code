import sys

def part1(input: str) -> str:
    [ranges_block, ingredientes_ids_block] = input.split("\n\n")
    ranges = [list(map(int, ranges_str.split("-"))) for ranges_str in ranges_block.strip().split("\n")]
    ingredientes_ids = list(map(int, ingredientes_ids_block.strip().split("\n")))

    res = 0
    for ingredientes_id in ingredientes_ids:
        for [a, b] in ranges:
            if ingredientes_id in range(a, b+1):
                res += 1
                break

    return str(res)


def part2(input: str) -> str:
    [ranges_block, _] = input.split("\n\n")
    ranges = [list(map(int, ranges_str.split("-"))) for ranges_str in ranges_block.strip().split("\n")]
    
    for i, [a, b] in enumerate(ranges):
        for j, [c, d] in enumerate(ranges):
            if i == j: continue
            compare_range = range(c, d+1)
            if a in compare_range:
                a = d + 1
            if b in compare_range:
                b = c - 1
        ranges[i] = [a, b]
    
    return str(sum(len(range(a, b+1)) for [a, b] in ranges)
)

def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()