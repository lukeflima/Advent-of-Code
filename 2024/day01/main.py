def part1(input):
    l1 = []
    l2 = []
    lines = input.split("\n")
    for line in lines:
        [i, j] = line.split()
        l1.append(int(i))
        l2.append(int(j))
    
    l1.sort()
    l2.sort()
    print("Part 1: ", sum(abs(i - j) for i, j in zip(l1, l2)))

    return 0

def part2(input):
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    #if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())