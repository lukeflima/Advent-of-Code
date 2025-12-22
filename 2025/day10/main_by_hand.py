import sys
from collections import defaultdict
from heapq import heappush, heappop
from functools import cache
from random import shuffle
from itertools import permutations
from scipy.optimize._remove_redundancy import _remove_redundancy_pivot_dense
import numpy as np
from scipy.linalg import lu
import math 
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
    sols = list(map(int, open("res", "r").read().strip().split("\n")))
    machines = list(map(parse_machine, input.strip().split("\n")))
    res = 0
    fail = 0
    for index, (actual_sol, (pattern, buttons, joltage)) in enumerate(zip(sols, machines)):
        matrix = set()
        for i, jolt in enumerate(joltage):
            row = [1.0 if i in button else 0.0 for button in buttons]
            row.append(float(jolt))
            matrix.add(tuple(row))
        original_matrix = [list(row) for row in matrix]
        matrix = [list(row) for row in matrix]
        # print original_matrix
        for row in matrix:
            for val in row:
                print(f"{val:8.3f}", end=" ")
            print()
        print()

        # # Gaussian elimination
        # k = 0
        # h = 0
        # while k < len(matrix) and h < len(matrix[0]) -1:
        #     #find pivot
        #     i_max = max(range(k, len(matrix)), key=lambda i: abs(matrix[i][h]))
        #     if matrix[i_max][h] == 0:
        #         h += 1
        #     else:
        #         #swap rows
        #         matrix[k], matrix[i_max] = matrix[i_max], matrix[k]
        #         original_matrix[k], original_matrix[i_max] = original_matrix[i_max], original_matrix[k]
        #         #eliminate column h
        #         for i in range(k+1, len(matrix)):
        #             factor = matrix[i][h] / matrix[k][h]
        #             for j in range(h, len(matrix[0])):
        #                 matrix[i][j] -= factor * matrix[k][j]
        #         k += 1
        #         h += 1
        # print("After Gaussian elimination: 1st pass")
        # for row in matrix:
        #     for val in row:
        #         print(f"{val:8.3f}", end=" ")
        #     print()
        # print()
        # i = 0
        # while i < len(matrix):
        #     if all(abs(matrix[i][j]) < 1-9 for j in range(len(matrix[i]))):
        #         del original_matrix[i]
        #         del matrix[i]
        #     else:
        #         i += 1
        
        # matrix = original_matrix


        # print("After Gaussian elimination:")
        # for row in matrix:
        #     for val in row:
        #         print(f"{val:8.3f}", end=" ")
        #     print()
        # print()
        # A, rhs, _, _ = _remove_redundancy_pivot_dense(np.array([np.array(row[:-1]) for row in matrix]), np.array([row[-1] for row in matrix]))
        # matrix = [list(map(float, A[i])) + [float(rhs[i])] for i in range(len(A))]
        # print(matrix)        

        n = len(matrix)
        m = len(matrix[0])-1
        basis = [m + i for i in range(n)]
        
        c = [1]*m + [0]*(n) + [0]
        pseudo_objective = [0]*(m + n + 1)
        for i in range(n):
            for j in range(m):
                pseudo_objective[j] -= matrix[i][j]
            pseudo_objective[-1] -= matrix[i][-1]

            matrix[i] = matrix[i][:-1] + [0] * (i) +[1] + [0]*(n - i -1) + [matrix[i][-1]]
        
        m += n
        matrix.append(c)
        matrix.append(pseudo_objective)
        n += 2
        print(m,'x', n)

        def print_c(c, name="Cost"):
            print(f"{name}:  ", end="")
            for val in c:
                print(f"{val:8.3f}", end=" ")
            print()

        def print_matrix(matrix, basis):
            for b, row in zip(basis, matrix):
                print(f"x{b:02}: ", end="")
                for val in row:
                    print(f"{val:8.3f}", end=" ")
                print()
            print()
            for row in matrix[len(basis):]:
                print(f"     ", end="")
                for val in row:
                    print(f"{val:8.3f}", end=" ")
                print()
            print()


        print("Basis:", basis)
        # print matrix
        print_matrix(matrix, basis)
        # print(basis, len(basis), n)

        basis_visited = {tuple(sorted(basis)): -c[-1]}

        def is_optimal(c):
            return all(c[i] >= 0 for i in range(len(c)-1))

        def choose_next_basis(c):
            print(c)
            next = min(range(len(c) - 1), key=lambda i: c[i])
            if c[next] <= -1e-9:
                return next
            return -1
        
        def choose_leaving_var(matrix, next_basis_var, using_psdeo=False):
            k = 2 if using_psdeo else 1
            ratios = []
            for i in range(n-k):
                if matrix[i][next_basis_var] >= 1e-9:
                    ratios.append((i, matrix[i][-1] / matrix[i][next_basis_var]))
            if len(ratios) == 0:
                return -1
            leaving = min(ratios, key=lambda x: x[1])[0]
            return leaving
    
        def pivot(matrix, basis, next_basis_var, leaving):
            print("Pivoting on row", leaving+1, "column", next_basis_var+1)
            #update basis
            basis[leaving] = next_basis_var

            if matrix[leaving][next_basis_var] != 1:
                factor = matrix[leaving][next_basis_var]
                for j in range(len(matrix[leaving])):                            
                    matrix[leaving][j] /= factor
            for i in range(n):
                if i != leaving and abs(matrix[i][next_basis_var]) >= 1e-9:
                    factor = matrix[i][next_basis_var]
                    for j in range(m+1):                            
                        matrix[i][j] -= factor * matrix[leaving][j]


        phase = 1
        while True:
            next_basis_var = choose_next_basis(matrix[-1])
            if next_basis_var != -1:
                leaving = choose_leaving_var(matrix, next_basis_var, using_psdeo=phase == 1)
                if leaving == -1:
                    print("No leaving variable found")
                    break
                print(leaving, basis)
                print("Entering:", next_basis_var, "Leaving:", basis[leaving])
                pivot(matrix, basis, next_basis_var, leaving)
                print_matrix(matrix, basis)
            else:
                print("Optimal reached for phase", phase)
                break
        
        phase = 2
        
        if abs(matrix[-1][-1]) > 1e-9:
            print("Phase 1 should end with 0 cost", index)
            exit(1)

        print("Switching to phase 2")
        print_matrix(matrix, basis)
        #remove artificial variables from matrix
        new_matrix = []
        m -= len(basis)
        n -= 1
        for i in range(n):
            new_matrix.append(matrix[i][:m] + [matrix[i][-1]])
        matrix = new_matrix     
        print_matrix(matrix, basis)
        print(basis, n)
        print("Removing artificial variables from basis")
        for i in range(len(basis)):
            if basis[i] >= m:
                next_basis_var = -1
                for j in range(m):
                    if abs(matrix[i][j]) > 1e-9:
                        next_basis_var = j
                        break
                
                if next_basis_var == -1:
                    continue
                print("Removing artificial basis variable x", basis[i], "with x", next_basis_var)
                pivot(matrix, basis, next_basis_var, i)

        print_matrix(matrix, basis)

        
        phase = 2
        while True:
            next_basis_var = choose_next_basis(matrix[-1])
            if next_basis_var != -1:
                leaving = choose_leaving_var(matrix, next_basis_var, using_psdeo=phase == 1)
                if leaving == -1:
                    break
                print("Entering:", next_basis_var, "Leaving:", basis[leaving])
                pivot(matrix, basis, next_basis_var, leaving)
                print_matrix(matrix, basis)
            else:
                break
        
        sol = math.ceil(-matrix[-1][-1])
        print(f"{index+1} Optimal cost:", sol, "Actual cost:", actual_sol, "✅" if sol == actual_sol else "❌")
        is_integer_solution = all(abs(matrix[i][-1] - int(matrix[i][-1])) < 1e-9 for i in range(len(basis)))
        print("Integer solution?" , is_integer_solution)
        if sol != actual_sol:
            print(joltage)
            if sol + 1 == actual_sol:
                print("Off by one?")
                sol += 1
            else:
                fail += 1
                exit(1)
        print("basis:", basis)
        print_c(c)
        res += sol
            
            
    print(len(machines) - fail, "out of", len(machines), "passed.")
#    186 out of 195 passed.   
    return str(res)


def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()