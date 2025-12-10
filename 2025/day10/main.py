import sys
from collections import defaultdict
from heapq import heappush, heappop
import z3

def pattern_to_num(pattern):
    n = 0
    for i in pattern[::-1]:
        n = (n<<1) | (1 if i == '#' else 0)
    return n


def parse_machine(line: str):
    blocks = line.split("] (")
    pattern = blocks[0][1:]
    blocks = blocks[1].split(") {")
    buttons = [set(map(int, btn_str[1:-1].split(","))) for btn_str in ("(" + blocks[0] + ")").split()]
    joltage = list(map(int, blocks[1][:-1].split(",")))
    return pattern, buttons, joltage


def apply_button(state, button):
    for b in button:
        state = state ^ (1 << b)
    return state


def part1(input: str) -> str:
    machines = list(map(parse_machine, input.strip().split("\n")))

    res = 0
    for pattern, buttons, joltage in machines:
        graph = defaultdict(list)
        for i in range(2**len(pattern)):
            for b in buttons:
                graph[i].append(apply_button(i, b))

        num_pattern = pattern_to_num(pattern)
        queue = [(0, 0)]
        visited = set()
        while len(queue) > 0:
            presses, p = heappop(queue)
            
            if p == num_pattern:
                res += presses
                break

            if p in visited: continue
            visited.add(p)

            for n in graph[p]:
                heappush(queue, (presses + 1, n))

    return str(res)


def part2(input: str) -> str:
    machines = list(map(parse_machine, input.strip().split("\n")))
    res = 0
    for pattern, buttons, joltage in machines:
        vars = [z3.Int(f'x{i}') for i in range(len(buttons))]
        
        s = z3.Optimize()
        for i, jolt in enumerate(joltage):
            equation = 0
            for j, button in enumerate(buttons):
                if i in button:
                    equation += vars[j]
            s.add(equation == jolt)
        
        for var in vars:
            s.add(var >= 0)
        
        s.minimize(sum(vars))
        
        assert s.check() == z3.sat, f"Unsat {joltage}"
        
        m = s.model()
        res += sum(m[var].as_long() for var in vars)

    return str(res)

def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()