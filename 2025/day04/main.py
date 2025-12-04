import sys

class Point:
    x: int
    y: int

    def __init__(self, x, y):
        assert isinstance(x, int), f"x must be int found {type(x)}"
        assert isinstance(y, int), f"y must be int found {type(y)}"

        self.x = x
        self.y = y

    def __add__(self, other):
        if isinstance(other, Point):
            return Point(self.x + other.x, self.y + other.y)
        if isinstance(other, tuple) and len(other) == 2 and isinstance(other[0], int) and isinstance(other[1], int):
            return Point(self.x + other[0], self.y + other[1])
        if isinstance(other, int):
            return Point(self.x + other, self.y + other)
        raise ValueError(f"Add must have a Point, int or (int, int) found: {type(other)}")
    
    def __eq__(self, other):
        if isinstance(other, Point):
            return self.x == other.x and self.y == other.y
        if isinstance(other, tuple) and len(other) == 2 and isinstance(other[0], int) and isinstance(other[1], int):
            return self.x == other[0] and self.y == other[1]
        raise ValueError(f"Add must have a Point, int or (int, int) found: {type(other)}")

    def __hash__(self):
        return hash((self.x, self.y))

    def __repr__(self):
        return f"Point(x={self.x}, y={self.y})"
    

def in_grid(grid, p):
    if isinstance(p, Point):
        x, y = p.x, p.y
    elif isinstance(p, tuple) and len(p) == 2 and isinstance(p[0], int) and isinstance(p[1], int):
        x, y = p[0], p[1]
    else: 
        raise ValueError(f"`in_grid` must have a Point or (int, int) found: {type(p)}")
    return x >= 0 and y >=0 and y < len(grid) and x < len(grid[0])


DIRS = [
        Point( 0,  1),
        Point( 1,  1),
        Point( 1,  0),
        Point( 1, -1),
        Point( 0, -1),
        Point(-1, -1),
        Point(-1,  0),
        Point(-1,  1),
    ]

def part1(input: str) -> str:
    grid = input.strip().split('\n')
    rolls = set()
    for y in range(len(grid)):
        for x in range(len(grid[0])):
            if grid[y][x] == '@':
                rolls.add(Point(x, y))
    
    res = 0
    for roll in rolls:
        num_neighbours = sum(roll + dir in rolls for dir in DIRS)
        if num_neighbours < 4:
            res += 1

    return str(res)

def part2(input: str) -> str:
    grid = input.strip().split('\n')
    rolls = set()
    for y in range(len(grid)):
        for x in range(len(grid[0])):
            if grid[y][x] == '@':
                rolls.add(Point(x, y))

    res = 0
    while True:
        rolls_to_remove = set()
        for roll in rolls:
            num_neighbours = sum(roll + dir in rolls for dir in DIRS)
            if num_neighbours < 4:
                rolls_to_remove.add(roll)
        
        if len(rolls_to_remove) == 0: break
    
        res += len(rolls_to_remove)
        rolls = rolls - rolls_to_remove

    return str(res)

def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()