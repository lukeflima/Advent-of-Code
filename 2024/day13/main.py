import numpy as np

def get_games(input: str):
    # [(a, b, prize), ...]
    games = []
    for i in input.split('\n\n'):
        [a_line, b_line, prize_line] = i.splitlines()
        a = tuple([int(n.split("+")[1]) for n in a_line.split(": ")[1].split(', ')])
        b = tuple([int(n.split("+")[1]) for n in b_line.split(": ")[1].split(', ')])
        prize = tuple([int(n.split("=")[1]) for n in prize_line.split(": ")[1].split(', ')])
        games.append((a, b, prize))
    return games
    
def add_tuple(t1, t2):
    return (t1[0] + t2[0], t1[1] + t2[1])
def sub_tuple(t1, t2):
    return (t1[0] - t2[0], t1[1] - t2[1])
def div_tuple(t1, t2):
    return (t1[0]/t2[0], t1[1]/t2[1])
def mod_tuple(t1, t2):
    return (t1[0]%t2[0], t1[1]%t2[1])
def scale_tuple(t1, t2):
    return (t1[0]*t2, t1[1]*t2)

def part1(input: str):
    games = get_games(input)
    res = 0
    for a, b, prize in games:
        a_presses = 0
        wins = []
        cur = (0, 0)
        b_presses = 100
        while b_presses >= 0:
            cur = scale_tuple(b, b_presses)
            dif = sub_tuple(prize, cur)
            if mod_tuple(dif, a) == (0, 0):
                a_presses = int(div_tuple(dif, a)[0])
                if a_presses >= 0 and add_tuple(scale_tuple(a, a_presses), scale_tuple(b, b_presses)) == prize:
                    wins.append(a_presses*3 + b_presses)
            b_presses -= 1

        if len(wins) > 0:
            res += min(wins)
        
    print("Part 1", res)
    return 0

def part2(input: str):
    games = get_games(input)
    res = 0
    for a, b, prize in games:
        prize = add_tuple(prize, (10_000_000_000_000, 10_000_000_000_000))
        solution = np.linalg.solve(np.array([a, b]).T, [[prize[0]],[prize[1]]])
        a_presses, b_presses = round(solution[0,0]), round(solution[1,0])
        if add_tuple(scale_tuple(a, a_presses), scale_tuple(b, b_presses)) == prize:
            res += int(a_presses*3 + b_presses)
           
    print("Part 2", res)
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())