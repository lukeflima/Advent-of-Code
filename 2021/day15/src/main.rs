use std::cmp::Ordering;
use std::collections::BinaryHeap;

use utils::{get_lines_from_file, parse_number};

// Dijkstra’s algorithm stoled from https://doc.rust-lang.org/std/collections/binary_heap/index.html#examples
#[derive(Copy, Clone, Eq, PartialEq)]
struct State {
    cost: usize,
    position: usize,
}

// The priority queue depends on `Ord`.
// Explicitly implement the trait so the queue becomes a min-heap
// instead of a max-heap.
impl Ord for State {
    fn cmp(&self, other: &Self) -> Ordering {
        // Notice that the we flip the ordering on costs.
        // In case of a tie we compare positions - this step is necessary
        // to make implementations of `PartialEq` and `Ord` consistent.
        other
            .cost
            .cmp(&self.cost)
            .then_with(|| self.position.cmp(&other.position))
    }
}

// `PartialOrd` needs to be implemented as well.
impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

// Each node is represented as a `usize`, for a shorter implementation.
#[derive(Debug)]
struct Edge {
    node: usize,
    cost: usize,
}

// Dijkstra's shortest path algorithm.

// Start at `start` and use `dist` to track the current shortest distance
// to each node. This implementation isn't memory-efficient as it may leave duplicate
// nodes in the queue. It also uses `usize::MAX` as a sentinel value,
// for a simpler implementation.
fn shortest_path(adj_list: &[Vec<Edge>], start: usize, goal: usize) -> Option<usize> {
    // dist[node] = current shortest distance from `start` to `node`
    let mut dist: Vec<_> = (0..adj_list.len()).map(|_| usize::MAX).collect();

    let mut heap = BinaryHeap::new();

    // We're at `start`, with a zero cost
    dist[start] = 0;
    heap.push(State {
        cost: 0,
        position: start,
    });

    // Examine the frontier with lower cost nodes first (min-heap)
    while let Some(State { cost, position }) = heap.pop() {
        // Alternatively we could have continued to find all shortest paths
        if position == goal {
            return Some(cost);
        }

        // Important as we may have already found a better way
        if cost > dist[position] {
            continue;
        }

        // For each node we can reach, see if we can find a way with
        // a lower cost going through this node
        for edge in &adj_list[position] {
            let next = State {
                cost: cost + edge.cost,
                position: edge.node,
            };

            // If so, add it to the frontier and continue
            if next.cost < dist[next.position] {
                heap.push(next);
                // Relaxation, we have now found a better way
                dist[next.position] = next.cost;
            }
        }
    }

    // Goal not reachable
    None
}
const NEIGHBOURS: [(i64, i64); 4] = [(-1, 0), (0, -1), (0, 1), (1, 0)];
fn part1() {
    let riskmap: Vec<Vec<usize>> = get_lines_from_file("sample")
        .map(Result::unwrap)
        .map(|x| x.chars().map(|x| parse_number(&x.to_string())).collect())
        .collect();
    let mut graph: Vec<Vec<Edge>> = Default::default();
    for i in 0..riskmap.len() {
        for j in 0..riskmap[i].len() {
            let mut edges: Vec<Edge> = Default::default();
            for (x, y) in NEIGHBOURS {
                let i = i as i64 + x;
                let j = j as i64 + y;
                if i >= 0 && i < riskmap.len() as i64 && j >= 0 && j < riskmap[0].len() as i64 {
                    let i = i as usize;
                    let j = j as usize;
                    edges.push(Edge {
                        node: i * riskmap.len() + j,
                        cost: riskmap[i][j],
                    })
                }
            }
            graph.push(edges);
        }
    } //
    let min_path_risk = shortest_path(&graph, 0, graph.len() - 1).unwrap();
    println!("part1 {}", min_path_risk);
}

fn part2() {
    let mut riskmap: Vec<Vec<usize>> = get_lines_from_file("input")
        .map(Result::unwrap)
        .map(|x| x.chars().map(|x| parse_number(&x.to_string())).collect())
        .collect();
    let fixed_riskmap = riskmap.clone();
    for i in 1..=4 {
        let mut cur_tile: Vec<Vec<usize>> = fixed_riskmap
            .clone()
            .iter()
            .map(|x| {
                x.iter()
                    .map(|x| {
                        let r = *x + i;
                        if r > 9 {
                            r % 9
                        } else {
                            r
                        }
                    })
                    .collect()
            })
            .collect();
        for i in 0..riskmap.len() {
            riskmap[i].append(&mut cur_tile[i]);
        }
    }
    let fixed_riskmap = riskmap.clone();
    for i in 1..=4 {
        let mut cur_tile: Vec<Vec<usize>> = fixed_riskmap
            .clone()
            .iter()
            .map(|x| {
                x.iter()
                    .map(|x| {
                        let r = *x + i;
                        if r > 9 {
                            r % 9
                        } else {
                            r
                        }
                    })
                    .collect()
            })
            .collect();
        riskmap.append(&mut cur_tile);
    }
    let mut graph: Vec<Vec<Edge>> = Default::default();
    for i in 0..riskmap.len() {
        for j in 0..riskmap[i].len() {
            let mut edges: Vec<Edge> = Default::default();
            for (x, y) in NEIGHBOURS {
                let i = i as i64 + x;
                let j = j as i64 + y;
                if i >= 0 && i < riskmap.len() as i64 && j >= 0 && j < riskmap[0].len() as i64 {
                    let i = i as usize;
                    let j = j as usize;
                    edges.push(Edge {
                        node: i * riskmap.len() + j,
                        cost: riskmap[i][j],
                    })
                }
            }
            graph.push(edges);
        }
    }
    let min_path_risk = shortest_path(&graph, 0, graph.len() - 1).unwrap();
    println!("part2 {}", min_path_risk);
}

fn main() {
    part1();
    part2();
}
