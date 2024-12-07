def get_calibrations(input: str):
    calibrations_str = [i.split(": ") for i in input.splitlines()]
    calibrations = [(int(ans), list(map(int, nums.split()))) for [ans, nums] in calibrations_str]
    return calibrations

def part1(input: str):
    calibrations = get_calibrations(input)
    res = 0
    for ans, nums in calibrations:
        leafs = [nums[0]]
        for num in nums[1:]:
            new_leafs = []
            while len(leafs) > 0:
                value = leafs.pop()
                new_leafs.append(value + num)
                new_leafs.append(value * num)
            leafs = new_leafs
        if any([i == ans for i in leafs]):
            res += ans
    print("Part 1:", res)
    return 0

def part2(input: str):
    calibrations = get_calibrations(input)
    res = 0
    for ans, nums in calibrations:
        leafs = [nums[0]]
        for num in nums[1:]:
            new_leafs = []
            while len(leafs) > 0:
                value = leafs.pop()
                new_leafs.append(value + num)
                new_leafs.append(value * num)
                new_leafs.append(int(str(value) + str(num)))
            leafs = new_leafs
        if any([i == ans for i in leafs]):
            res += ans
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