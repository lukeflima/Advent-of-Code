def part1(input: str):
    lines = [i.strip() for i in input.splitlines()]
    n = 0
    TARGET = 'XMAS'
    for j in range(len(lines)):
        for i in range(len(lines[0])):
            c = lines[j][i]
            if c == 'X':
                if lines[j][i:i+4] == TARGET:
                    n+=1
                if lines[j][i-3:i+1] == TARGET[::-1]:
                    n+=1
                if j+3 < len(lines):
                  if all(lines[j+ix][i] == x for ix, x in enumerate(TARGET)):
                      n+=1
                if j-3 >= 0:
                  if all(lines[j-ix][i] == x for ix, x in enumerate(TARGET)):
                      n+=1
                if j-3 >= 0 and i-3 >= 0:
                    if all(lines[j-ix][i-ix] == x for ix, x in enumerate(TARGET)):
                        n+=1
                if j-3 >= 0 and i+3 < len(lines[0]):
                  if all(lines[j-ix][i+ix] == x for ix, x in enumerate(TARGET)):
                      n+=1
                if j+3 < len(lines) and i+3 < len(lines[0]):
                  if all(lines[j+ix][i+ix] == x for ix, x in enumerate(TARGET)):
                      n+=1
                if j+3 < len(lines) and i-3 >= 0 :
                  if all(lines[j+ix][i-ix] == x for ix, x in enumerate(TARGET)):
                        n+=1

    print("Part 1:", n)
    return 0

def part2(input):
    lines = [i.strip() for i in input.splitlines()]
    n = 0
    TARGET = 'MAS'

    def is_target(dig):
        return dig == TARGET or dig == TARGET[::-1]
    
    for j in range(len(lines)):
        for i in range(len(lines[0])):
            c = lines[j][i]
            if c == 'A':
               if j-1 >= 0 and j+1 < len(lines) and i-1 >= 0 and i+1 < len(lines[0]):
                   dig1 = ''.join([lines[j-1][i-1], lines[j][i], lines[j+1][i+1]])
                   dig2 = ''.join([lines[j-1][i+1], lines[j][i], lines[j+1][i-1]])
                   if is_target(dig1) and is_target(dig2):
                       n+=1

    print("Part 2:", n)
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())