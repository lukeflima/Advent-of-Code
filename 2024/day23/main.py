from collections import defaultdict
from itertools import combinations
import networkx as nx

def get_graph(input: str):
    graph: dict[str, set[str]] = defaultdict(set)
    for line in input.splitlines():
        [left, right] = line.split("-")
        graph[left].add(right)
        graph[right].add(left)
    return graph

def part1(input: str):
    graph = get_graph(input)
    computers = list(graph.keys())
    conected_triple = []
    for c1, c2, c3 in combinations(computers, 3):
        if not c1.startswith("t") and not c2.startswith("t") and not c3.startswith("t"):
            continue
        if c2 in graph[c1] and c3 in graph[c1] and c1 in graph[c2] and c3 in graph[c2] and c1 in graph[c3] and c2 in graph[c3]:
            conected_triple.append((c1,c2,c3))
    
    print("Part 1:", len(conected_triple))
    return 0

def part2(input: str):
    graph = nx.Graph()
    for line in input.splitlines():
        [left, right] = line.split("-")
        graph.add_node(left)
        graph.add_node(right)
        graph.add_edge(left, right)
        graph.add_edge(right, left)
    
    cycles = nx.find_cliques(graph)
    largest = sorted(set(max(cycles, key=len)))
    print("Part 2:", ','.join(largest))
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())