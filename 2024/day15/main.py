def get_grid_and_movements(input: str):
    grid_str, movements_str = input.split("\n\n")
    grid = [list(i.strip()) for i in grid_str.splitlines()]
    movements = list(''.join(movements_str.splitlines()))
    return grid, movements

def add_tuple(t1, t2):
    return (t1[0] + t2[0], t1[1] + t2[1])
def scale_tuple(t1, t2):
    return (t1[0]*t2, t1[1]*t2)
def mul_tuple(t1, t2):
    return (t1[0]*t2[0], t1[1]*t2[1])

def part1(input: str):
    grid, movements = get_grid_and_movements(input)
    walls = set()
    boxes = set()
    robots_pos = (0,0)
    dirs = {
        "^": (-1,  0),
        ">": ( 0,  1),
        "<": ( 0, -1),
        "v": ( 1,  0),
    }
    for i in range(len(grid)):
        for j in range(len(grid[0])):
            cell = grid[i][j]
            if cell == "#":
                walls.add((i, j))
            elif cell == "O":
                boxes.add((i, j))
            elif cell == "@":
                robots_pos = (i, j)
    for movement in movements:
        dir = dirs[movement]
        move_pos = add_tuple(robots_pos, dir)
        if move_pos in walls: continue
        if move_pos in boxes:
            last_box = add_tuple(move_pos, dir)
            while last_box in boxes:
                last_box = add_tuple(last_box, dir)
            if last_box not in walls:
                boxes.remove(move_pos)
                boxes.add(last_box)
                robots_pos = move_pos
        else:
            robots_pos = move_pos
        
       
    # for i in range(len(grid)):
    #     for j in range(len(grid[0])):
    #         cell = (i, j)
    #         if cell in walls:
    #             print("#", end="")
    #         elif cell in boxes:
    #             print("O", end="")
    #         elif cell == robots_pos:
    #             print("@", end="")
    #         else:
    #             print(".", end="")
    #     print("")
    
    print("Part 1:", sum(i * 100 + j for i, j in boxes))
    return 0


class Box:
    left: tuple[int, int]
    right: tuple[int, int]

    def __init__(self, left, right):
        self.left = left
        self.right = right

    def __repr__(self):
        return f"Box(left={self.left}, right={self.right})"

    def __contains__(self, p):
        return p == self.left or p == self.right

    def move(self, dir):
        return Box(add_tuple(self.left, dir), add_tuple(self.right, dir))

def part2(input: str):
    grid, movements = get_grid_and_movements(input)
    walls = set()
    boxes: dict[tuple[int, int], Box] = {}
    robots_pos = (0,0)
    dirs = {
        "^": (-1,  0),
        ">": ( 0,  1),
        "<": ( 0, -1),
        "v": ( 1,  0),
    }
    for i in range(len(grid)):
        for j in range(len(grid[0])):
            cell = grid[i][j]
            left_side, right_side = (i, j*2), (i, j*2 +1)
            if cell == "#":
                walls.add(left_side)
                walls.add(right_side)
            elif cell == "O":
                box = Box(left_side, right_side)
                boxes[left_side] = box
                boxes[right_side] = box
            elif cell == "@":
                robots_pos = left_side
    
    for movement in movements:
        dir = dirs[movement]
        move_pos = add_tuple(robots_pos, dir)
        if move_pos in walls: continue
        if move_pos in boxes:
            box = boxes[move_pos]
            boxes_moved = set([box])
            next_check = [box]
            while len(next_check) > 0:
                b = next_check.pop()
                b = b.move(dir)
                if b.right in boxes:
                    box = boxes[b.right]
                    if box not in boxes_moved:
                        boxes_moved.add(box)
                        next_check.append(box)
                if b.left in boxes:
                    box = boxes[b.left]
                    if box not in boxes_moved:
                        boxes_moved.add(box)
                        next_check.append(box)
                
            if all(box.right not in walls and box.left not in walls for box in map(lambda x: x.move(dir), boxes_moved)):
                for box in boxes_moved:
                    del boxes[box.right]
                    del boxes[box.left]
                for box in boxes_moved:
                    new_box = box.move(dir)
                    boxes[new_box.right] = new_box
                    boxes[new_box.left] = new_box
                robots_pos = move_pos
        else:
            robots_pos = move_pos

    # skip = False
    # for i in range(len(grid)):
    #     for j in range(len(grid[0]*2)):
    #         if skip:
    #             skip = False
    #             continue
    #         cell = (i, j)
    #         right_cell = (i, j + 1)
    #         if cell in walls:
    #             print("#", end="")
    #         elif cell in boxes and right_cell in boxes:
    #             print("[]", end="")
    #             skip = True
    #         elif cell == robots_pos:
    #             print("@", end="")
    #         else:
    #             print(".", end="")
    #     print("")

    print("Part 2:", sum(b.left[0] * 100 + b.left[1] for b in set(boxes.values())))
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())