import sys
import functools
import operator

def part1(input: str) -> str:
    lines = input.rstrip().split("\n")
    operands = lines[-1].split()
    nums = [list(map(int, line.split())) for line in lines[:-1]]

    res = 0
    for i, op in enumerate(operands):
        if op == "+":
            res += sum(num_row[i] for num_row in nums)
        if op == "*":
            res += functools.reduce(operator.mul, (num_row[i] for num_row in nums), 1)

    return str(res)

def part2(input: str) -> str:
    lines = input.split("\n")
    
    res = 0
    i = len(lines[0]) - 1
    while i > 0:
        op = ""
        nums = []
        while True:
            num = 0
            for line in lines[:-1]:
                if line[i] != " ":
                    num = num * 10 + int(line[i])
            nums.append(num)
            if lines[-1][i] != " ":
                op = lines[-1][i]
                i -= 2
                break
            else:
                i -= 1

        assert op != "", "Op must be present"
        
        if op == "+":
            res += sum(nums)
        elif op == "*":
            res += functools.reduce(operator.mul, nums, 1)

    return str(res)

def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()