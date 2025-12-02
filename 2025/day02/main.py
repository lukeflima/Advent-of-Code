import sys


def part1(input: str) -> str:
    ranges = [[int(i) for i in range_str.split("-")] for range_str in input.strip().split(",")]
    
    res = 0
    for r in ranges:
        for num in range(r[0], r[1] + 1):
            num_str = str(num)
            mid = len(num_str) // 2
            if len(num_str) % 2 == 0 and num_str[:mid] == num_str[mid:]:
                res += num

    return str(res)


def part2(input: str) -> str:
    ranges = [[int(i) for i in range_str.split("-")] for range_str in input.strip().split(",")]
    
    res = 0
    for r in ranges:
        for num in range(r[0], r[1] + 1):
            num = str(num)
            for i in range(1, 1 + len(num)//2):
                pred = num[:i]
                if all(num[j:j+i] == pred for j in range(i, len(num), i)):
                    res += int(num)
                    break

    return str(res)

def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()