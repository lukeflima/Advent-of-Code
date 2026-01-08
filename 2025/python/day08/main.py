import sys
import math

def distance(p1, p2):
    d = 0
    for c1, c2 in zip(p1, p2):
        d += (c1 - c2)**2
    return math.sqrt(d)

def part1(input: str) -> str:
    boxes = [tuple(map(int, line.split(","))) for line in input.strip().split("\n")]
    
    distances = []
    for i, box1 in enumerate(boxes):
        for box2 in boxes[i+1:]:
            distances.append((distance(box1, box2), box1, box2))
    distances.sort(key=lambda d: d[0])

    circuits = [set([box]) for box in boxes]
    box_to_circuit = {box: i for i, box in enumerate(boxes)}
    for _, box1, box2 in distances[:1000]:
        if box_to_circuit[box1] != box_to_circuit[box2]:
            circuits2_index = box_to_circuit[box2]
            for box in circuits[circuits2_index]:
                circuits[box_to_circuit[box1]].add(box)
                box_to_circuit[box] = box_to_circuit[box1]
            circuits[circuits2_index] = set()
    
    circuits_sizes = [len(circuit) for circuit in circuits if len(circuit)]
    circuits_sizes.sort(reverse=True)
    return str(circuits_sizes[0] * circuits_sizes[1] * circuits_sizes[2])

def part2(input: str) -> str:
    boxes = [tuple(map(int, line.split(","))) for line in input.strip().split("\n")]
    
    distances = []
    for i, box1 in enumerate(boxes):
        for box2 in boxes[i+1:]:
            distances.append((distance(box1, box2), box1, box2))
    distances.sort(key=lambda d: d[0])

    circuits = [set([box]) for box in boxes]
    box_to_circuit = {box: i for i, box in enumerate(boxes)}
    res = 0
    for _, box1, box2 in distances:
        if box_to_circuit[box1] != box_to_circuit[box2]:
            circuits2_index = box_to_circuit[box2]
            for box in circuits[circuits2_index]:
                circuits[box_to_circuit[box1]].add(box)
                box_to_circuit[box] = box_to_circuit[box1]
            circuits[circuits2_index] = set()
            if len(circuits[box_to_circuit[box1]]) == len(boxes):
                res = box1[0] * box2[0]
                break

    return str(res)

def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()