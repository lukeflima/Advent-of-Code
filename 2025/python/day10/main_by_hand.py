import sys
from collections import defaultdict
from heapq import heappush, heappop
import math 


DEBUG = False

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
    for pattern, buttons, _ in machines:
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


def print_c(c, name="Cost"):
    if not DEBUG: return
    
    print(f"{name}:  ", end="")
    for val in c:
        print(f"{val:8.3f}", end=" ")
    print()

def print_matrix(matrix, basis):
    if not DEBUG: return
    
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


def is_optimal(matrix):
    c = matrix[-1]
    return all(c[i] >= -1e-9 for i in range(len(c)-1))

def choose_next_basis(A, dual):
    c = [row[-1] for row in A[:-1]] + [0] if dual else A[-1]
    
    next = min(range(len(c) - 1), key=lambda i: c[i])
    
    if c[next] <= -1e-9:
        return next
    
    return -1

def choose_leaving_var(matrix, next_basis_var, using_psdeo, dual):
    n = len(matrix)
    m = len(matrix[0])-1

    k = 2 if using_psdeo else 1
    ratios = []
    if dual:
        for j in range(m-k):
            if matrix[next_basis_var][j] < -1e-9 and abs(matrix[-1][j]) > 1e-9:
                ratios.append((j, -matrix[-1][j]/ matrix[next_basis_var][j]))
    else:
        for i in range(n-k):
            if matrix[i][next_basis_var] > 1e-9:
                ratios.append((i, matrix[i][-1] / matrix[i][next_basis_var]))
    
    if len(ratios) == 0:
        return -1
    
    if DEBUG: print("Ratios", ratios)
    leaving = min(ratios, key=lambda x: x[1])[0]

    return leaving



def pivot(matrix, basis, next_basis_var, leaving, dual):
    if dual:
        next_basis_var, leaving = leaving, next_basis_var
    
    n = len(matrix)
    m = len(matrix[0])-1
    
    if DEBUG: print("Pivoting on row", leaving+1, "column", next_basis_var+1)

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


def simplex(matrix, basis=None, phase=1, dual=False):
    if dual:
        if DEBUG: print("Dual Simplex Method")

    n = len(matrix)
    m = len(matrix[0])-1
    
    if basis is None:
        basis = [m + i for i in range(n-1)]
        
        pseudo_objective = [0]*(m + n)
        for i in range(n-1):
            for j in range(m):
                pseudo_objective[j] -= matrix[i][j]
            pseudo_objective[-1] -= matrix[i][-1]

            matrix[i] = matrix[i][:-1] + [0] * (i) +[1] + [0]*(n - i - 2) + [matrix[i][-1]]
        
        matrix[-1] = matrix[-1][:-1] + [0]*(n-1) + [matrix[-1][-1]]
        m += n - 1
        
        matrix.append(pseudo_objective)
        n += 1
        
        if DEBUG: print(m,'x', n)
    
    print_matrix(matrix, basis)

    while True:
        next_basis_var = choose_next_basis(matrix, dual)
        if next_basis_var != -1:
            leaving = choose_leaving_var(matrix, next_basis_var, using_psdeo=phase == 1, dual=dual)
            if leaving == -1:
                if DEBUG: print("no col found")
                break
            pivot(matrix, basis, next_basis_var, leaving, dual)
            print_matrix(matrix, basis)
        else:
            if DEBUG: print("no row found")
            break

    #remove artificial variables from matrix
    if phase == 1:
        if abs(matrix[-1][-1]) > 1e-9:
            print("Must be 0 for feasable solution")
            print_matrix(matrix, basis)
            exit(1)
        
        new_matrix = []
        m -= len(basis)
        n -= 1
        for i in range(n):
            new_matrix.append(matrix[i][:m] + [matrix[i][-1]])
        matrix = new_matrix   
        print_matrix(matrix, basis)

        if DEBUG: print("Removing artificial variables from basis")
        for i in range(len(basis)):
            if basis[i] >= m:
                next_basis_var = -1
                for j in range(m):
                    if abs(matrix[i][j]) > 1e-9:
                        next_basis_var = j
                        break
                
                if next_basis_var == -1:
                    continue
                if DEBUG: print("Removing artificial basis variable x", basis[i], "with x", next_basis_var)
                pivot(matrix, basis, next_basis_var, i, dual)

        print_matrix(matrix, basis)
    
    return -matrix[-1][-1], basis, matrix

    
def solve_lp(c, A, b, basis=None, dual=False, c0=0):
    matrix = [A[i] + [b[i]] for i in range(len(b))]
    matrix.append(c+[c0])
    if basis is None:
        sol, basis, matrix = simplex(matrix, basis, 1, dual)
        if is_optimal(matrix):
            return sol, basis, matrix
    return simplex(matrix, basis, 2, dual)

def solve_mixedin(c, A, b, x=None, c0=0):
    if x is None:
        return solve_lp(c, A, b, c0=c0)
    
    matrix = [A[i] + [b[i]] for i in range(len(b))]
    matrix.append(c+[c0])
    basis = None
    iterations = 0
    dual = False
    while True:
        A = [row[:-1] for row in matrix[:-1]]
        b = [row[-1] for row in matrix[:-1]]
        c = matrix[-1][:-1]
        c0 = matrix[-1][-1]
        sol, basis, matrix = solve_lp(c, A, b, basis, dual, c0)
        if iterations > 100:
            break
        
        is_integer_solution = all(abs(matrix[i][-1] - round(matrix[i][-1])) < 1e-9 for i in range(len(matrix) -1) if basis[i] < len(x) and x[basis[i]])
        if is_integer_solution:
            if is_optimal(matrix):
                if DEBUG: print("Integer and optimal")
                break
            else:
                if DEBUG: print("Integer but no optimal")
                dual = False
                continue
        else:
            # find a basic integer variable that is not integer to cutting plane
            print_matrix(matrix, basis)
            for i in range(len(basis)):
                if x[i] and abs(matrix[i][-1] - round(matrix[i][-1])) >= 1e-9:
                    if DEBUG: print("Adding cutting plane for x", basis[i])
                    
                    new_row = [0.0]* (len(matrix[0]))
                    for j in range(len(matrix[i])):
                        new_row[j] = -matrix[i][j] + math.floor(matrix[i][j])
                    new_row[-1] = -matrix[i][-1] + math.floor(matrix[i][-1])
                    new_row.insert(-1, 1.0)  # new slack variable
                    
                    # adding new col
                    for i in range(len(matrix)):
                        matrix[i].insert(-1, 0.0)
                    
                    matrix.insert(-1, new_row)
                    basis.append(len(matrix[0]) -2)

                    dual = new_row[-1] < -1e-9
                    
                    print_matrix(matrix, basis)
                    break
            iterations += 1
    return sol, basis, matrix

def part2(input: str) -> str:
    machines = list(map(parse_machine, input.strip().split("\n")))
    res = 0
    fail = 0
    for index, (_, buttons, joltage) in enumerate(machines):
        matrix = set()
        for i, jolt in enumerate(joltage):
            row = [1.0 if i in button else 0.0 for button in buttons]
            row.append(float(jolt))
            matrix.add(tuple(row))
        matrix = [list(row) for row in matrix]
        matrix.append([1]*(len(matrix[0]) - 1) + [0])       
        
        A = [row[:-1] for row in matrix[:-1]]
        b = [row[-1] for row in matrix[:-1]]
        c = matrix[-1][:-1]
        sol, basis, matrix = solve_mixedin(c, A, b, x=[1]*len(c))
        
        sol = round(sol)
        res += sol
            
            
    return str(res)


def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()