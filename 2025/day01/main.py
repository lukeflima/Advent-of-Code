import sys

def part1(input: str) -> str:
    pointer = 50
    res = 0
    for command in input.split("\n"):
        if len(command) == 0: continue
        rotation = int(command[1:])
        if command[0] == "L": rotation = -rotation

        pointer = (pointer + rotation) % 100
        if pointer == 0: res += 1

    return str(res)

def part2(input: str) -> str:
    pointer = 50
    res = 0
    for command in input.split("\n"):
        if len(command) == 0: continue
        rotation = int(command[1:])
        if command[0] == "L": rotation = -rotation

        revolutions, pointer = divmod(pointer + rotation, 100)
        res += abs(revolutions)

    return str(res)

def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()