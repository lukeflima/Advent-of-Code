import sys
from functools import cache

def part1(input: str) -> str:
    devices = [line.split(": ") for line in input.strip().split('\n')]
    devices = {device: outputs.split() for [device, outputs] in devices}

    queue = ["you"]
    count = 0
    while len(queue) > 0:
        device = queue.pop()
        if device == "out":
            count += 1
            continue
        for next in devices[device]:
            queue.append(next)

    return str(count)

def part2(input: str) -> str:
    devices = [line.split(": ") for line in input.strip().split('\n')]
    devices = {device: outputs.split() for [device, outputs] in devices}
    
    @cache
    def dfs(node: str, found_fft=False, found_dac=False) -> int:
        if node == "out":
            return 1 if found_fft and found_dac else 0
        
        total = 0
        for next in devices[node]:
            total += dfs(next, found_fft or next == "fft", found_dac or next == "dac")

        return total
    
    return str(dfs("svr"))

def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()