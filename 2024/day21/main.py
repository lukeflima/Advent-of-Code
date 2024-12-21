from functools import cache
from itertools import permutations


num_keypad = {
    "7": (3, 2),
    "8": (3, 1),
    "9": (3, 0),
    "4": (2, 2),
    "5": (2, 1),
    "6": (2, 0),
    "1": (1, 2),
    "2": (1, 1),
    "3": (1, 0),
    "E": (0, 2),
    "0": (0, 1),
    "A": (0, 0),
}

robot_keypad = {
    "A": (1, 0),
    "^": (1, 1),
    "E": (1, 2),
    ">": (0, 0),
    "v": (0, 1),
    "<": (0, 2),
}

dirs = {
    "^": (1, 0),
    ">": (0, -1),
    "v": (-1, 0),
    "<": (0, 1),
}

NUM_KEYPAD_INDEX = 0
ROBOT_KEYPAD_INDEX = 1
keypads = [num_keypad, robot_keypad]


def add_tuple(t1, t2):
    return (t1[0] + t2[0], t1[1] + t2[1])
def sub_tuple(t1, t2):
    return (t1[0] - t2[0], t1[1] - t2[1])

@cache
def get_move(pos_i, dest_i, keypad_index):
    keypad = keypads[keypad_index]
    pos, dest = keypad[pos_i], keypad[dest_i]
    out = ""
    dx, dy = sub_tuple(dest, pos)
    out += ("^" if dx > 0 else "v")*abs(dx)
    out += ("<" if dy > 0 else ">")*abs(dy)
    moves_set = set(''.join(moves) + "A" for moves in permutations(out))
    
    # Remove moves that passes through empty pad
    good_moves = []
    for moves in moves_set:
        cpos = pos
        for move in moves[:-1]:
            cpos = add_tuple(cpos, dirs[move])
            if cpos == keypad["E"]:
                break
        else:
            good_moves.append(moves)
    return good_moves

@cache
def get_cost(pos, dest, keypad_index, depth = 0):  
    if depth == 0:
        return len(min(get_move(pos, dest, ROBOT_KEYPAD_INDEX), key=len))

    moves = get_move(pos, dest, keypad_index)
    best_cost = float("inf")
    for move in moves:
        prev = "A"
        cost = 0
        for key in move:
            cost += get_cost(prev, key, ROBOT_KEYPAD_INDEX, depth - 1)
            prev = key
        best_cost = min(best_cost, cost)

    return best_cost

def part1(input: str):
    codes = input.splitlines()
    res = 0
    for code in codes:
        cost = 0
        prev = "A"
        for key in code:
            cost += get_cost(prev, key, NUM_KEYPAD_INDEX, 2)
            prev = key

        res += cost * int(code[:-1])

    print("Part 1:", res)
    return 0

def part2(input: str):
    codes = input.splitlines()
    res = 0
    for code in codes:
        cost = 0
        prev = "A"
        for key in code:
            cost += get_cost(prev, key, NUM_KEYPAD_INDEX, 25)
            prev = key

        res += cost * int(code[:-1])

    print("Part 2:", res)
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())