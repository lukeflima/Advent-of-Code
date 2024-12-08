from collections import defaultdict


def get_antenas(input: str):
    lines = input.splitlines()
    antenas_list = [(i, x, y) for x, line in enumerate(lines) for y, i in enumerate(line) if i.isalpha() or i.isdigit()]
    w, h = len(lines[0]), len(lines)
    antenas: dict[str, list[tuple[int, int]]] = defaultdict(list)
    for i, x, y in antenas_list:
        antenas[i].append((x,y))
    return antenas, w, h


def part1(input: str):
    antenas, w, h = get_antenas(input)
    antinodes: set[tuple[int, int]] = set()
    for freq in antenas:
        ants = antenas[freq]
        for a1 in ants:
            for a2 in ants:
                if a1 == a2:
                    continue
                d = (a1[0] - a2[0], a1[1] - a2[1])
                an1 = (a1[0] + d[0], a1[1] + d[1])
                an2 = (a2[0] - d[0], a2[1] - d[1])
                if 0 <= an1[0] < w and 0 <= an1[1] < h:
                    antinodes.add(an1)
                if 0 <= an2[0] < w and 0 <= an2[1] < h:
                    antinodes.add(an2)
    
    # for i, line in enumerate(input.splitlines()):
    #     for j, c in enumerate(line):
    #         if (i, j) in antinodes:
    #             print("#", end="")
    #         else:
    #             print(c, end="")
    #     print()

    print("Part 1:", len(antinodes))
    return 0

def part2(input: str):
    antenas, w, h = get_antenas(input)
    antinodes: set[tuple[int, int]] = set()
    for freq in antenas:
        ants = antenas[freq]
        for a1 in ants:
            for a2 in ants:
                if a1 == a2:
                    continue
                d = (a1[0] - a2[0], a1[1] - a2[1])
                an = (a1[0] + d[0], a1[1] + d[1])
                while 0 <= an[0] < w and 0 <= an[1] < h:
                    antinodes.add(an)
                    an = (an[0] + d[0], an[1] + d[1])
                an = (a2[0] + d[0], a2[1] + d[1])
                while 0 <= an[0] < w and 0 <= an[1] < h:
                    antinodes.add(an)
                    an = (an[0] - d[0], an[1] - d[1])
    
    # for i, line in enumerate(input.splitlines()):
    #     for j, c in enumerate(line):
    #         if (i, j) in antinodes:
    #             print("#", end="")
    #         else:
    #             print(c, end="")
    #     print()

    print("Part 2:", len(antinodes))
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())