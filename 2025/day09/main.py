import sys
from functools import cache

def part1(input: str) -> str:
    red_tiles = [tuple(map(int, line.split(','))) for line in input.strip().split("\n")]
    
    biggest_area_rec = 0
    for i, t1 in enumerate(red_tiles):
        for t2 in red_tiles[i+1:]:
            biggest_area_rec = max(biggest_area_rec, (abs(t1[0] - t2[0]) + 1)*(abs(t1[1] - t2[1])+1))
    
    return str(biggest_area_rec)

# Deepseek ftw
def part2(input_str: str) -> str:
    red_tiles = [tuple(map(int, line.split(','))) for line in input_str.strip().split("\n")]
    n = len(red_tiles)
    
    polygon = red_tiles + [red_tiles[0]]
    
    def point_in_polygon(px, py):
        for i in range(n):
            x1, y1 = polygon[i]
            x2, y2 = polygon[i + 1]
            if x1 == x2 and px == x1 and min(y1, y2) <= py <= max(y1, y2):
                return True
            if y1 == y2 and py == y1 and min(x1, x2) <= px <= max(x1, x2):
                return True
        
        inside = False
        for i in range(n):
            x1, y1 = polygon[i]
            x2, y2 = polygon[i + 1]
            if ((y1 > py) != (y2 > py)) and (px < (x2 - x1) * (py - y1) / (y2 - y1) + x1):
                inside = not inside
        return inside
    
    xs = sorted({x for x, _ in red_tiles})
    ys = sorted({y for _, y in red_tiles})
    
    x_to_idx = {x: i for i, x in enumerate(xs)}
    y_to_idx = {y: i for i, y in enumerate(ys)}
    
    w = len(xs) - 1
    h = len(ys) - 1

    inside_grid = [[False] * h for _ in range(w)]
    for i in range(w):
        for j in range(h):
            cx = (xs[i] + xs[i + 1]) / 2
            cy = (ys[j] + ys[j + 1]) / 2
            inside_grid[i][j] = point_in_polygon(cx, cy)
    
    prefix_sum = [[0] * (h + 1) for _ in range(w + 1)]
    for i in range(w):
        for j in range(h):
            is_inside = 1 if inside_grid[i][j] else 0
            prefix_sum[i + 1][j + 1] = (prefix_sum[i + 1][j] + prefix_sum[i][j + 1] - prefix_sum[i][j] + is_inside)
    
    def calc_actual_area(x1, y1, x2, y2):
        return prefix_sum[x2][y2] - prefix_sum[x1][y2] - prefix_sum[x2][y1] + prefix_sum[x1][y1]
    
    biggest_area_rec = 0
    for i, (x1, y1) in enumerate(red_tiles):
        idx1_x, idx1_y = x_to_idx[x1], y_to_idx[y1]
        
        for x2, y2 in red_tiles:
            idx2_x, idx2_y = x_to_idx[x2], y_to_idx[y2]
            
            min_idx_x = min(idx1_x, idx2_x)
            max_idx_x = max(idx1_x, idx2_x)
            min_idx_y = min(idx1_y, idx2_y)
            max_idx_y = max(idx1_y, idx2_y)
                
            expected_area = (max_idx_x - min_idx_x) * (max_idx_y - min_idx_y)
            actual_area = calc_actual_area(min_idx_x, min_idx_y, max_idx_x, max_idx_y)
            if actual_area == expected_area:
                biggest_area_rec = max(biggest_area_rec, (abs(x1 - x2) + 1)*(abs(y1 - y2) + 1))
    
    return str(biggest_area_rec)


def main():
    if len(sys.argv) != 2: print("Usage: main.py input.txt"); exit(1)
    with open(sys.argv[1]) as infile: input = infile.read()
    print("Part 1:", part1(input))
    print("Part 2:", part2(input))

if __name__ == "__main__":
    main()