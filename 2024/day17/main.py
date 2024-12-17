from z3 import Solver, sat, BoolVector, Xor, Or, If

def get_program_and_registers(input: str):
    [registers_str, program_str] = input.split("\n\n")
    registers = [int(line.split(": ")[1].strip()) for line in registers_str.splitlines()]
    program = list(map(int, program_str.split(": ")[1].strip().split(",")))
    return program, registers


def part1(input: str):
    program, registers = get_program_and_registers(input)
    pc = 0
    output = []
    while pc < len(program):
        opcode = program[pc]
        literal = program[pc + 1]
        combo = literal if literal <= 3 else registers[literal - 4]
        if   opcode == 0: #adv
            registers[0] = int(registers[0]/(2**combo))
            pc += 2
        elif opcode == 1: #bxl
            registers[1] ^= literal
            pc += 2
        elif opcode == 2: #bst
            registers[1] = combo % 8
            pc += 2
        elif opcode == 3: #jnz
            if registers[0] != 0:
                pc = literal
            else:
                pc += 2
        elif opcode == 4: #bxc
            registers[1] = registers[1] ^ registers[2]
            pc += 2
        elif opcode == 5: #out
            output.append(str(combo % 8))
            pc += 2
        elif opcode == 6: #bdv
            registers[1] = int(registers[0]/(2**combo))
            pc += 2
        elif opcode == 7: #cdv
            registers[2] = int(registers[0]/(2**combo))
            pc += 2

    print("Part 1:", ','.join(output))
    return 0


def part2(input: str):
    program, _ = get_program_and_registers(input)

    def xor_bv3_num(bv3, num):
        return [Xor(bi, ni) for bi, ni in zip(bv3, (bool((num >> i) & 1) for i in range(3)))]
    def xor_bv3s(bv31, bv32):
        return [Xor(bi1, bi2) for bi1, bi2 in zip(bv31, bv32)]

    outs = BoolVector("A", 3*len(program))
    solver = Solver()
    A = outs
    # solver.add(Or(A[-1], A[-2], A[-3]))
    solver.add(Or(A[0], A[1], A[2]))
    for i, target in enumerate(program):
        # B <= A & 7
        B = [A[0], A[1], A[2]]
        # B <= B ^ 5
        B = xor_bv3_num(B, 5)
        # C <= A // (2 ^ B)
        B_val = B[0] + 2 * B[1] + 4 * B[2]
        C = [False] * 3
        for j in range(8):
            C[0] = Or(C[0], If(B_val == j, A[j + 0] if j + 0 < len(A) else False, False))
            C[1] = Or(C[1], If(B_val == j, A[j + 1] if j + 1 < len(A) else False, False))
            C[2] = Or(C[2], If(B_val == j, A[j + 2] if j + 2 < len(A) else False, False))
        # B <= B ^ 6
        B = xor_bv3_num(B, 6)
        # A <= A >> 3
        A = A[3:]
        # B <= B ^ C
        B = xor_bv3s(B, C)
        # out B
        for j in range(3):
            solver.add(B[j] == bool((target >> j)& 1))

    check = solver.check()
    res = 0
    if check == sat:
        sol = solver.model()
        for i, ai in enumerate(outs):
            res += bool(sol[ai]) * (2**i)
    
    print("Part 2:", res)
    return 0



def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret
    # if ret := part2_z3(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())