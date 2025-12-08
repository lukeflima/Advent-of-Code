import sys
import math
from collections import defaultdict

def distance(p1, p2):
    d = 0
    for c1, c2 in zip(p1, p2):
        d += (c1 - c2)**2
    return math.sqrt(d)

def part1(input: str) -> str:
    boxes = [tuple(map(int, line.split(","))) for line in input.strip().split("\n")]
    
    distances = []
    for i, box1 in enumerate(boxes):
        for j, box2 in enumerate(boxes[i+1:]):
            distances.append((distance(box1, box2), i, i + j + 1))
    distances.sort(key=lambda d: d[0])

    parent = [i for i in range(len(boxes))]
    def ufind(x):
        if parent[x] != x:
            return ufind(parent[x])
        return x
    
    def union(x, y):
        parent[ufind(y)] = ufind(x) 

    for _, box1, box2 in distances[:1000]:
        if ufind(box1) != ufind(box2):
            union(box1, box2)
    
    circuits_sizes = defaultdict(int)
    for box in range(len(boxes)):
        circuits_sizes[ufind(box)] += 1
    circuits_sizes = list(circuits_sizes.values())
    circuits_sizes.sort(reverse=True)
    return str(circuits_sizes[0] * circuits_sizes[1] * circuits_sizes[2])

def part2(input: str) -> str:
    boxes = [tuple(map(int, line.split(","))) for line in input.strip().split("\n")]
    
    distances = []
    for i, box1 in enumerate(boxes):
        for j, box2 in enumerate(boxes[i+1:]):
            distances.append((distance(box1, box2), i, i + j + 1))
    distances.sort(key=lambda d: d[0])

    parent = [i for i in range(len(boxes))]
    def ufind(x):
        if parent[x] != x:
            return ufind(parent[x])
        return x
    
    def union(x, y):
        parent[ufind(y)] = ufind(x) 
    unions = 0
    res = 0
    for _, box1, box2 in distances:
        if ufind(box1) != ufind(box2):
            union(box1, box2)
            unions += 1
            if unions + 1 == len(boxes):
                res = boxes[box1][0] * boxes[box2][0]
                break

    return str(res)

def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()