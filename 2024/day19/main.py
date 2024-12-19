from functools import cache

def get_patterns_and_designs(input: str):
    [patterns_str, designs_str] = input.split("\n\n")
    patterns = patterns_str.split(", ")
    designs = designs_str.strip().splitlines()
    return patterns, designs


def part1(input: str):
    patterns, designs = get_patterns_and_designs(input)
    def search(target: str, patterns_list: list[str], seen):
        pattern_srt = ''.join(patterns_list)
        if pattern_srt == target:
            return patterns_list
        if pattern_srt in seen:
            return []
        seen.add(pattern_srt)
        if target.startswith(pattern_srt):
            for pattern in patterns:
                design = search(target, patterns_list + [pattern], seen)
                if design:
                    return design
        return []
    patterns_lists = []
    for design in designs:
        pattern_list = search(design, [], set())
        patterns_lists.append(pattern_list)

    print("Part 1:", sum(1 for i in patterns_lists if i))
    return 0

def part2(input: str):
    patterns, designs = get_patterns_and_designs(input)

    @cache
    def search(target: str):
        if len(target) == 0:
            return 1
        res = 0
        for pattern in patterns:
            if target.startswith(pattern):
                res += search(target[len(pattern):])
        return res

    print("Part 2:", sum(search(design) for design in designs))
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())