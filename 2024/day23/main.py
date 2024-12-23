from collections import defaultdict
from functools import partial
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


def _find_cliques(graph, node, cliques, clique):
    password = tuple(sorted(clique))
    if password in cliques: return
    cliques.add(password)

    for neigh in graph[node]:
        neigh_neighs = graph[neigh]
        if neigh not in clique and all(n in neigh_neighs for n in clique):
            _find_cliques(graph, neigh, cliques, {*clique, neigh})

def find_cliques(graph, node):
    cliques = set()
    _find_cliques(graph, node, cliques, {node}) 
    return cliques


def part2(input: str):
    graph = get_graph(input)
    cliques = set()
    for node in graph:
        cliques |= find_cliques(graph, node)    
    largest = max((c for c in cliques if any(n for n in c if n.startswith("t"))), key=len)
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