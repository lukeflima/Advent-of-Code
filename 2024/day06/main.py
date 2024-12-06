from collections import Counter


def get_map(input: str):
    map = [list(s.strip()) for s in input.splitlines()]
    guard_pos = (0,0)
    for i, row in enumerate(map):
        for j, pos in enumerate(row):
            if pos not in ".#":
                guard_pos = (i, j)
    direction = "top"
    match map[guard_pos[0]][guard_pos[1]]:
        case '^': direction = "top"
        case 'v': direction = "bottom"
        case '>': direction = "right"
        case '<': direction = "left"
    return map, guard_pos, direction
            
    

def part1(input: str):
    map, guard_pos, direction = get_map(input)
    map_w, map_h = len(map[0]), len(map)

    directions = {
        "top": {
            "dir": (-1, 0),
            "new_dir": "right"
        },
        "bottom":{
            "dir": (1, 0),
            "new_dir": "left"
        },
        "right":{
            "dir": (0, 1),
            "new_dir": "bottom"
        },
        "left":{
            "dir": (0, -1),
            "new_dir": "top"
        },
    }

    x, y = guard_pos
    map[x][y] = 'X'
    while True:
        dir = directions[direction]
        new_x, new_y = (x + dir["dir"][0], y + dir["dir"][1])
        if not (0 <= new_x < map_h and 0 <= new_y < map_w):
            map[x][y] = 'X'
            guard_pos = (new_x, new_y)
            break
        if map[new_x][new_y] == "#":
            direction = dir["new_dir"]
        else:
            map[x][y] = 'X'
            guard_pos = (new_x, new_y)
        x, y = guard_pos
    print("Part 1:", Counter([x for xs in map for x in xs])['X'])

    return 0

def part2(input: str):
    map, guard_pos, direction = get_map(input)
    map_w, map_h = len(map[0]), len(map)
    original_guard_pos, original_guard_direction = guard_pos, direction
    directions = {
        "top": {
            "dir": (-1, 0),
            "new_dir": "right"
        },
        "bottom":{
            "dir": (1, 0),
            "new_dir": "left"
        },
        "right":{
            "dir": (0, 1),
            "new_dir": "bottom"
        },
        "left":{
            "dir": (0, -1),
            "new_dir": "top"
        },
    }

    obstacle_positions = []
    for row in range(len(map)):
        for col in range(len(map[0])):
            guard_pos = original_guard_pos
            x, y = guard_pos
            direction = original_guard_direction
            patrol_positions: set[tuple[int, int, str]] = set() 
            while True:
                if (x, y, direction) in patrol_positions:
                    obstacle_positions.append((x, y))
                    break
                patrol_positions.add((x,y,direction))
                dir = directions[direction]
                new_x, new_y = (x + dir["dir"][0], y + dir["dir"][1])
                if not (0 <= new_x < map_h and 0 <= new_y < map_w):
                    break
                if map[new_x][new_y] == "#"  or (new_x, new_y) == (row, col):
                    direction = dir["new_dir"]
                else:
                    guard_pos = (new_x, new_y)
                    x, y = guard_pos
            
    print("Part 2:", len(obstacle_positions))
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())