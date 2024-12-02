def get_lists(input):
    l1 = []
    l2 = []
    lines = input.split("\n")
    for line in lines:
        [i, j] = line.split()
        l1.append(int(i))
        l2.append(int(j))
    return l1, l2

def part1(input):
    l1, l2 = get_lists(input)
    
    l1.sort()
    l2.sort()
    print("Part 1:", sum(abs(i - j) for i, j in zip(l1, l2)))

    return 0

def part2(input):
    l1, l2 = get_lists(input)

    s = 0
    for i in l1:
        s += i * sum(1 for j in l2 if i == j)
    
    print("Part 2:", s)

    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())