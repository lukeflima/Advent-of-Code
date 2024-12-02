def part1(input):
    return 0

def part2(input):
    return 0

def main():
    with open("inputtest.txt") as input:
    #with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())