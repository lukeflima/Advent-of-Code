import sys

def part1(input: str) -> str:
    res = 0
    for bank_str in input.strip().split("\n"):
        bank = [int(i) for i in bank_str]
        largest_jolt = 0
        for i in range(len(bank)):
            num = bank[i] * 10
            if num < largest_jolt: continue
            for j in range(i+1, len(bank)):
                largest_jolt = max(largest_jolt, num + bank[j])
        res += largest_jolt

    return str(res)

def part2(input: str) -> str:
    res = 0
    for bank_str in input.strip().split("\n"):
        bank = [int(i) for i in bank_str]

        largest_jolt = 0
        last_digit_index = -1
        for index in range(12):
            number = 0
            for digit_index in range(last_digit_index + 1, len(bank) - 12 + index + 1):
                if bank[digit_index] > number:
                    number = bank[digit_index]
                    last_digit_index = digit_index
            largest_jolt = largest_jolt * 10 + number

        res += largest_jolt

    return str(res)

def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()