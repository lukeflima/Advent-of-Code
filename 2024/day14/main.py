from collections import defaultdict
from functools import reduce
import operator
import cv2
import numpy as np

def get_robots(input: str):
    robots = []
    for line in input.splitlines():
        values = line.split()
        p = tuple(map(int, values[0].split("=")[1].split(',')))
        v = tuple(map(int, values[1].split("=")[1].split(',')))
        robots.append((p, v))
    return robots

def add_tuple(t1, t2):
    return (t1[0] + t2[0], t1[1] + t2[1])
def mod_tuple(t1, t2):
    return (t1[0]%t2[0], t1[1]%t2[1])
def scale_tuple(t1, t2):
    return (t1[0]*t2, t1[1]*t2)

def part1(input: str):
    robots = get_robots(input)
    w, h = 101, 103
    seconds = 100
    final: dict[tuple[int, int], int] = defaultdict(int)
    for p, v in robots:
        final[mod_tuple(add_tuple(p, scale_tuple(v, seconds)), (w, h))] += 1
    quadrants: dict[int, int] = defaultdict(int)
    mx, my = w//2, h//2
    for p, v in final.items():
        if   p[0] < mx and p[1] < my:
            quadrants[0] += v
        elif p[0] < mx and p[1] > my:
            quadrants[1] += v
        elif p[0] > mx and p[1] < my:
            quadrants[2] += v
        elif p[0] > mx and p[1] > my:
            quadrants[3] += v
    res = reduce(operator.mul, quadrants.values(), 1)
    print("Part 1:", res)
    return 0

def part2(input: str):
    robots = get_robots(input)
    w, h = 101, 103
    seconds = 1
    while True:
        robots_pos_rn = set([mod_tuple(add_tuple(p, scale_tuple(v, seconds)), (w, h)) for p, v in robots])
        if len(robots_pos_rn) == len(robots):
            im = np.zeros((w,h))
            for x, y in robots_pos_rn:
                im[x][y] = 255
            cv2.imwrite(f"{seconds}.png", im)
            cv2.waitKey(0) 
            break
        seconds += 1
    print("Part 2:", seconds)
    return 0


def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())