from collections import defaultdict
from astar import AStar
from dijkstar import Graph
from dijkstar.algorithm import NoPathError
from heapq import heappush, heappop
from inspect import ismethod
from itertools import count

def get_grid(input: str):
    return [list(line) for line in input.splitlines()]

def add_tuple(t1, t2):
    return (t1[0] + t2[0], t1[1] + t2[1])

class BasicAStar(AStar):
    def __init__(self, nodes):
        self.nodes = nodes

    def neighbors(self, n):
        pos, d = n
        yield (pos, (d + 1) % 4)
        yield (pos, (d - 1) % 4)
        npos = add_tuple(pos, dirs[d])
        if self.nodes[npos[0]][npos[1]] != "#":
            yield (npos, d)

    def distance_between(self, n1, n2):
        pos1, d1 = n1
        pos2, d2 = n2
        if pos1 == pos2:
            return 1000 * (1 + (1 - abs(d1 - d2) % 2))
        return 1

            
    def heuristic_cost_estimate(self, current, goal):
        return 1
    
    def is_goal_reached(self, current, goal):
        return current[0] == goal

dirs = [(0, 1), (-1, 0), (0, -1), (1, 0)]
                
def part1(input: str):
    grid = get_grid(input)

    inital_pos = (0,0)
    final_pos = (0,0)
    for i in range(len(grid)):
        for j in range(len(grid[0])):
            if grid[i][j] == "S":
                inital_pos = (i, j)
            if grid[i][j] == "E":
                final_pos = (i, j)

    path = list(BasicAStar(grid).astar((inital_pos, 0), final_pos) or [])
    cost = 0
    for (pos1, d1), (pos2, d2) in zip(path[:-1], path[1:]):
        if pos1 == pos2:
            cost += 1000 * (1 + (1 - abs(d1 - d2) % 2))
        else:
            cost += 1
    print("Part 1:", cost)
    return 0


# Stolen from Dijkstar (https://github.com/wylee/Dijkstar)
def single_source_shortest_paths(graph, s, d=None, annex=None, cost_func=None,
                                 heuristic_func=None):
    """Find path from node ``s`` to all other nodes or just to ``d``.

    ``graph``
        An adjacency list that's structured as a dict of dicts (see
        :class:`dijkstra.graph.Graph`). Other than the structure, no
        other assumptions are made about the types of the nodes or edges
        in the graph. If ``cost_func`` isn't specified, edges will be
        assumed to be values that can be compared directly (e.g.,
        numbers, or any other comparable type).

    ``s``
        Start node.

    ``d``
        Destination node. If ``d`` is not specified, the algorithm is
        run normally (i.e., the paths from ``s`` to all reachable nodes
        are found). If ``d`` is specified, the algorithm is stopped when
        a path to ``d`` has been found.

    ``annex``
        Another graph that can be used to augment ``graph`` without
        altering it.

    ``cost_func``
        A function to apply to each edge to modify its base cost. The
        arguments it will be passed are the current node, a neighbor of
        the current node, the edge that connects the current node to
        that neighbor, and the edge that was previously traversed to
        reach the current node.

    ``heuristic_func``
        A function to apply at each iteration to guide the algorithm
        toward the destination (typically) instead of fanning out. It
        gets passed the same args as ``cost_func``.

    ``debug``
        If set, return additional info that may be useful for debugging.

    Returns
        A predecessor map with the following form::

            {v => (u, e, cost from v to u over e), ...}

        If ``debug`` is set, additional debugging info will be returned
        also. Currently, this info includes costs from ``s`` to reached
        nodes and the set of visited nodes.

    """
    # Operate on the underlying data dict to potentially improve
    # performance.
    if ismethod(getattr(graph, 'get_data', None)):
        graph = graph.get_data()
    if ismethod(getattr(annex, 'get_data', None)):
        annex = annex.get_data()

    counter = count()

    shortests_from=defaultdict(set)

    # Current known costs of paths from s to all nodes that have been
    # reached so far. Note that "reached" is not the same as "visited".
    costs = {s: 0}

    # Predecessor map for each node that has been reached from ``s``.
    # Keys are nodes that have been reached; values are tuples of
    # predecessor node, edge traversed to reach predecessor node, and
    # cost to traverse the edge from the predecessor node to the reached
    # node.
    predecessors = {s: (None, None, None)}

    # A priority queue of nodes with known costs from s. The nodes in
    # this queue are candidates for visitation. Nodes are added to this
    # queue when they are reached (but only if they have not already
    # been visited).
    visit_queue = [(0, next(counter), s)]

    # Nodes that have been visited. Once a node has been visited, it
    # won't be visited again. Note that in this context "visited" means
    # a node has been selected as having the lowest known cost (and it
    # must have been "reached" to be selected).
    visited = set()

    while visit_queue:
        # In the nodes remaining in the graph that have a known cost
        # from s, find the node, u, that currently has the shortest path
        # from s.
        cost_of_s_to_u, _, u = heappop(visit_queue)

        if u == d:
            break

        if u in visited:
            # This will happen when u has been reached from multiple
            # nodes before being visited (because multiple entries for
            # u will have been added to the visit queue).
            continue

        visited.add(u)

        if annex and u in annex:
            neighbors = annex[u]
        else:
            neighbors = graph[u] if u in graph else None

        if not neighbors:
            # u has no outgoing edges
            continue

        # The edge crossed to get to u
        prev_e = predecessors[u][1]

        # Check each of u's neighboring nodes to see if we can update
        # its cost by reaching it from u.
        for v in neighbors:
            # Don't backtrack to nodes that have already been visited.
            if v in visited:
                continue

            e = neighbors[v]

            # Get the cost of the edge running from u to v.
            cost_of_e = cost_func(u, v, e, prev_e) if cost_func else e

            # Cost of s to u plus the cost of u to v across e--this
            # is *a* cost from s to v that may or may not be less than
            # the current known cost to v.
            cost_of_s_to_u_plus_cost_of_e = cost_of_s_to_u + cost_of_e

            # When there is a heuristic function, we use a
            # "guess-timated" cost, which is the normal cost plus some
            # other heuristic cost from v to d that is calculated so as
            # to keep us moving in the right direction (generally more
            # toward the goal instead of away from it).
            if heuristic_func:
                additional_cost = heuristic_func(u, v, e, prev_e)
                cost_of_s_to_u_plus_cost_of_e += additional_cost

            if v not in costs or costs[v] > cost_of_s_to_u_plus_cost_of_e:
                # If the current known cost from s to v is greater than
                # the cost of the path that was just found (cost of s to
                # u plus cost of u to v across e), update v's cost in
                # the cost list and update v's predecessor in the
                # predecessor list (it's now u). Note that if ``v`` is
                # not present in the ``costs`` list, its current cost
                # is considered to be infinity.
                costs[v] = cost_of_s_to_u_plus_cost_of_e
                predecessors[v] = (u, e, cost_of_e)
                heappush(visit_queue, (cost_of_s_to_u_plus_cost_of_e, next(counter), v))
                shortests_from[v] = {u}
            elif v not in costs or costs[v] == cost_of_s_to_u_plus_cost_of_e:
                predecessors[v] = (u, e, cost_of_e)
                shortests_from[v].add(u)

    if d is not None and d not in costs:
        raise NoPathError('Could not find a path from {0} to {1}'.format(s, d))

    return shortests_from

def part2(input: str):
    grid = get_grid(input)

    graph = Graph()
    inital_pos = (0,0)
    final_pos = (0,0)
    for i in range(len(grid)):
        for j in range(len(grid[0])):
            cell = grid[i][j]
            if cell != "#":
                for di in range(4):
                    graph.add_edge((i, j, di), (i, j, (di + 1) % 4), 1000)
                    graph.add_edge((i, j, di), (i, j, (di - 1) % 4), 1000)
                    ni, nj = add_tuple((i, j), dirs[di])
                    if grid[ni][nj] != "#":
                        graph.add_edge((i, j, di), (ni, nj, di), 1)
            if cell == "S":
                inital_pos = (i, j)
            if cell == "E":
                final_pos = (i, j)
    shortests_from = single_source_shortest_paths(graph, (inital_pos[0], inital_pos[1], 0))
    
    stack = [(final_pos[0], final_pos[1], 1)]
    gnodes_plus_dir: set[tuple[int, int, int]] = set(stack)
    while len(stack) > 0:
        for other in shortests_from[stack.pop(-1)]:
            if other not in gnodes_plus_dir:
                gnodes_plus_dir.add(other)
                stack.append(other)
    gnodes = set(x[:2] for x in gnodes_plus_dir)
    print("Part 2:", len(gnodes))
    return 0


def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())