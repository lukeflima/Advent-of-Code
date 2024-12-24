from collections import Counter, defaultdict, deque
from itertools import combinations
import random


def get_wires_and_operations(input:str):
    [wires_str, operations_str] = input.split("\n\n")
    wires_list = [line.split(": ") for line in wires_str.splitlines()]
    wires = {name: int(value) for [name, value] in wires_list}
    operations_list = [line.split(" -> ") for line in operations_str.splitlines()]
    operations = []
    for [operation_str, output] in operations_list:
        [lhr, op, rhr] = operation_str.split()
        operations.append((lhr, op, rhr, output))
    return wires, operations

def part1(input: str):
    wires, operations = get_wires_and_operations(input)
    operations_finished = [False] * len(operations)
    while not all(operations_finished):
        for i, (lhr, op, rhr, output) in enumerate(operations):
            if not operations_finished[i] and lhr in wires and rhr in wires:
                if op == "AND":
                    wires[output] = wires[lhr] & wires[rhr]
                elif op == "OR":
                    wires[output] = wires[lhr] | wires[rhr]
                elif op == "XOR":
                    wires[output] = wires[lhr] ^ wires[rhr]
                operations_finished[i] = True
    res = int('0b'+''.join([str(wires[r]) for r in sorted(reg for reg in wires if reg[0] == 'z')])[::-1], 2)
    for i in range(46):
        zi = f"z{i:02}"
        assert wires[zi] == (res >> i) & 1
    print("Part 1:", res)
    return 0

# from z3 import *  # noqa: E402

def get_z(wires, operations):
    wires = {} | wires
    operations_finished = [False] * len(operations)
    while not all(operations_finished):
        runs = 0
        for i, (lhr, op, rhr, output) in enumerate(operations):
            if not operations_finished[i] and lhr in wires and rhr in wires:
                runs += 1
                if op == "AND":
                    wires[output] = wires[lhr] & wires[rhr]
                elif op == "OR":
                    wires[output] = wires[lhr] | wires[rhr]
                elif op == "XOR":
                    wires[output] = wires[lhr] ^ wires[rhr]
                operations_finished[i] = True
        if runs == 0:
            break
    return int('0b'+''.join([str(wires[r]) for r in sorted(reg for reg in wires if reg[0] == 'z')])[::-1], 2)

def part2(input: str):
    wires, operations = get_wires_and_operations(input)
   
    operations_original = list(operations)
    wires_to_operations = defaultdict(list)
    output_to_operations = {}
    for i, (lhr, _, rhr, output) in enumerate(operations):
        wires_to_operations[lhr].append(i)
        wires_to_operations[rhr].append(i)
        output_to_operations[output] = i

    x = int('0b'+''.join([str(wires[r]) for r in sorted(reg for reg in wires if reg[0] == 'x')])[::-1], 2)
    y = int('0b'+''.join([str(wires[r]) for r in sorted(reg for reg in wires if reg[0] == 'y')])[::-1], 2)
    z = x + y
    
    swaps = []
    swaps.append(("z19", "vvf"))
    swaps.append(("dck", "fgn"))
    swaps.append(("z37", "nvh"))
    swaps.append(("z12", "qdg"))
    for op1i, op2i in swaps:
        op1 = operations_original[output_to_operations[op1i]]
        op2 = operations_original[output_to_operations[op2i]]
        operations[output_to_operations[op1i]] = (*op1[:-1], op2[-1])
        operations[output_to_operations[op2i]] = (*op2[:-1], op1[-1])

    # found = False
    # while not found:
    #     x = random.randint(0, 2**45)
    #     y = random.randint(0, 2**45)
    #     z = x + y
    #     for i in range(45):
    #         wires[f"x{i:02}"] = (x >> i) & 1
    #         wires[f"y{i:02}"] = (y >> i) & 1
    #     wrong_z = get_z(wires, operations)
    #     for i in range(46):
    #         if (z >> i) & 1 != (wrong_z >> i) & 1 :
    #             print(i)
    #             found = True

    # with open("graph.dot", "w") as f:
    #     f.write('strict digraph {\n')
    #     for n1, op, n2, out in operations:
    #         f.write(f'   {n1} -> {out} [label={op}]\n')    
    #         f.write(f'   {n2} -> {out} [label={op}]\n')    
    #     f.write('}\n')

    list_of_swaps = []
    for swap in swaps:
        list_of_swaps.extend(swap)
    print("Part 2:", ','.join(sorted(list_of_swaps)))
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    main()