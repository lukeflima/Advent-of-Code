// STOLEN FROM: https://github.com/Mandrenkov/Contests/blob/077e3177965280d39903288a713c951fc1a199c8/Advent%20of%20Code%202021/src/day_23.rs

use std::cmp::Ordering;
use std::collections::BinaryHeap;
use std::collections::HashMap;
use std::fmt;

/// Solves the Day 23 Part 1 puzzle with respect to the given input.
pub fn part_1(input: String) {
    let mut lines = input.lines().skip(2);
    let top = lines.next().unwrap();
    let bot = lines.next().unwrap();

    let start = State {
        cost: 0,
        pods: [
            // Room A
            Pod {
                pos: 11,
                clr: top.chars().nth(3).unwrap(),
                fin: false,
            },
            Pod {
                pos: 12,
                clr: bot.chars().nth(3).unwrap(),
                fin: false,
            },
            Pod {
                pos: 13,
                clr: 'A',
                fin: true,
            },
            Pod {
                pos: 14,
                clr: 'A',
                fin: true,
            },
            // Room B
            Pod {
                pos: 15,
                clr: top.chars().nth(5).unwrap(),
                fin: false,
            },
            Pod {
                pos: 16,
                clr: bot.chars().nth(5).unwrap(),
                fin: false,
            },
            Pod {
                pos: 17,
                clr: 'B',
                fin: true,
            },
            Pod {
                pos: 18,
                clr: 'B',
                fin: true,
            },
            // Room C
            Pod {
                pos: 19,
                clr: top.chars().nth(7).unwrap(),
                fin: false,
            },
            Pod {
                pos: 20,
                clr: bot.chars().nth(7).unwrap(),
                fin: false,
            },
            Pod {
                pos: 21,
                clr: 'C',
                fin: true,
            },
            Pod {
                pos: 22,
                clr: 'C',
                fin: true,
            },
            // Room D
            Pod {
                pos: 23,
                clr: top.chars().nth(9).unwrap(),
                fin: false,
            },
            Pod {
                pos: 24,
                clr: bot.chars().nth(9).unwrap(),
                fin: false,
            },
            Pod {
                pos: 25,
                clr: 'D',
                fin: true,
            },
            Pod {
                pos: 26,
                clr: 'D',
                fin: true,
            },
        ],
    };

    let cost = solve(start).unwrap();
    println!("{}", cost);
}

/// Solves the Day 23 Part 2 puzzle with respect to the given input.
pub fn part_2(input: String) {
    let mut lines = input.lines().skip(2);
    let top = lines.next().unwrap();
    let bot = lines.next().unwrap();

    let start = State {
        cost: 0,
        pods: [
            // Room A
            Pod {
                pos: 11,
                clr: top.chars().nth(3).unwrap(),
                fin: false,
            },
            Pod {
                pos: 12,
                clr: 'D',
                fin: false,
            },
            Pod {
                pos: 13,
                clr: 'D',
                fin: false,
            },
            Pod {
                pos: 14,
                clr: bot.chars().nth(3).unwrap(),
                fin: false,
            },
            // Room B
            Pod {
                pos: 15,
                clr: top.chars().nth(5).unwrap(),
                fin: false,
            },
            Pod {
                pos: 16,
                clr: 'C',
                fin: false,
            },
            Pod {
                pos: 17,
                clr: 'B',
                fin: false,
            },
            Pod {
                pos: 18,
                clr: bot.chars().nth(5).unwrap(),
                fin: false,
            },
            // Room C
            Pod {
                pos: 19,
                clr: top.chars().nth(7).unwrap(),
                fin: false,
            },
            Pod {
                pos: 20,
                clr: 'B',
                fin: false,
            },
            Pod {
                pos: 21,
                clr: 'A',
                fin: false,
            },
            Pod {
                pos: 22,
                clr: bot.chars().nth(7).unwrap(),
                fin: false,
            },
            // Room D
            Pod {
                pos: 23,
                clr: top.chars().nth(9).unwrap(),
                fin: false,
            },
            Pod {
                pos: 24,
                clr: 'A',
                fin: false,
            },
            Pod {
                pos: 25,
                clr: 'C',
                fin: false,
            },
            Pod {
                pos: 26,
                clr: bot.chars().nth(9).unwrap(),
                fin: false,
            },
        ],
    };

    let cost = solve(start).unwrap();
    println!("{}", cost);
}

/// Solves the Day 23 puzzle with respect to the given input.
fn solve(start: State) -> Option<usize> {
    let mut costs: HashMap<String, usize> = HashMap::new();
    costs.insert(start.to_string(), start.cost);

    let mut heap = BinaryHeap::new();
    heap.push(start);

    while let Some(state) = heap.pop() {
        if is_goal_state(&state) {
            return Some(state.cost);
        }

        let repr = state.to_string();
        if state.cost > *costs.get(&repr).unwrap() {
            continue;
        }

        for next_state in get_next_states(&state) {
            let repr = next_state.to_string();
            if costs.contains_key(&repr) && next_state.cost >= *costs.get(&repr).unwrap() {
                continue;
            }

            heap.push(next_state);
            costs.insert(repr, next_state.cost);
        }
    }

    None
}

/// Represents a state of the diagram, ordered by cumulative energy cost.
#[derive(Copy, Clone, Debug, Eq, PartialEq)]
struct State {
    cost: usize,
    pods: [Pod; 16],
}

impl Ord for State {
    fn cmp(&self, other: &Self) -> Ordering {
        other
            .cost
            .cmp(&self.cost)
            .then_with(|| self.pods.cmp(&other.pods))
    }
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}


impl fmt::Display for State {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let s: String = self.to_chars().iter().collect();
        write!(f, "{}", s)
    }
}
impl State {
    /// Converts this state into an array of characters.
    fn to_chars(self) -> [char; 27] {
        let mut chars: [char; 27] = ['.'; 27];
        for pod in self.pods {
            chars[pod.pos] = pod.clr;
        }
        chars
    }


    /// Draws a (colourful!) representation of the given state.
    #[allow(dead_code)]
    fn draw(&self) {
        let chars = self.to_chars();

        let get = |pos: usize| match chars[pos] {
            'A' => "A",
            'B' => "B",
            'C' => "C",
            'D' => "D",
            _ => ".",
        };

        println!("Cost = {}.\n", self.cost);

        print!(" ");
        for i in 0..11 {
            print!("{}", get(i));
        }
        println!();

        for row in 0..4 {
            print!("  ");
            for room in 0..4 {
                print!(" {}", get(4 * room + 11 + row));
            }
            println!();
        }

        let line = (0..40).map(|_| '-').collect::<String>();
        println!("{}", line);
    }
}

/// Represents an amphipod (or "pod") instance in the diagram.
#[derive(Copy, Clone, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
struct Pod {
    pos: usize,
    clr: char,
    fin: bool,
}

impl Pod {
    /// Returns the energy required to move this pod to an adjacent cell.
    fn energy(&self) -> usize {
        match self.clr {
            'A' => 1,
            'B' => 10,
            'C' => 100,
            'D' => 1000,
            _ => panic!(),
        }
    }
}

/// Reports whether all the pods in the given state are in their respective rooms.
fn is_goal_state(state: &State) -> bool {
    state.to_string() == "...........AAAABBBBCCCCDDDD"
}

/// Returns all the successors to the given state.
fn get_next_states(state: &State) -> Vec<State> {
    let mut next_states = Vec::new();

    for (i, pod) in state.pods.iter().enumerate() {
        if pod.fin {
            continue;
        }

        if pod.pos <= 10 {
            if let Some(next_state) = get_next_state_from_hallway(state, i) {
                next_states.push(next_state);
            }
            continue;
        }

        for next_state in get_next_state_from_room(state, i) {
            next_states.push(next_state);
        }
    }

    next_states
}

/// Returns all the successors to the given state where the provided hallway pod moves.
fn get_next_state_from_hallway(state: &State, index: usize) -> Option<State> {
    let chars = state.to_chars();
    let pod = state.pods[index];

    let is_dot = |x: &char| *x == '.';
    let is_allowed = |x: &&char| **x == '.' || **x == pod.clr;

    let room = "ABCD".find(pod.clr).unwrap();
    let door = 2 + 2 * room;

    let beg = 11 + 4 * room;
    let end = beg + 4;

    if chars[beg..end].iter().filter(is_allowed).count() < 4 {
        return None;
    }

    let path = if pod.pos < door {
        (pod.pos + 1)..door
    } else {
        door..pod.pos
    };

    if !chars[path].iter().all(is_dot) {
        return None;
    }

    let mut next_pods: [Pod; 16] = state.pods;
    let next_slot = chars[beg..end].iter().rposition(is_dot).unwrap();
    let next_pos = beg + next_slot;
    next_pods[index] = Pod {
        pos: next_pos,
        clr: pod.clr,
        fin: true,
    };

    let next_cost = state.cost + pod.energy() * dist(pod.pos, next_pos);

    Some(State {
        cost: next_cost,
        pods: next_pods,
    })
}

/// Returns all the successors to the given state where the provided room pod moves.
fn get_next_state_from_room(state: &State, index: usize) -> Vec<State> {
    let chars = state.to_chars();
    let pod = state.pods[index];

    let is_dot = |x: &char| *x == '.';

    let room = (pod.pos - 11) / 4;
    let door = 2 + 2 * room;

    let beg = 11 + 4 * room;
    let end = pod.pos;

    if !chars[beg..end].iter().all(is_dot) {
        return vec![];
    }

    let mut next_states = Vec::new();

    for (pos, char) in chars.iter().enumerate().take(11).skip(door + 1)  {
        if *char != '.' {
            break;
        } else if pos == 2 || pos == 4 || pos == 6 || pos == 8 {
            continue;
        }

        let mut next_pods: [Pod; 16] = state.pods;
        next_pods[index] = Pod {
            pos,
            clr: pod.clr,
            fin: false,
        };

        let next_cost = state.cost + pod.energy() * dist(pod.pos, pos);

        let next_state = State {
            cost: next_cost,
            pods: next_pods,
        };
        next_states.push(next_state);
    }

    for pos in (0..door).rev() {
        if chars[pos] != '.' {
            break;
        } else if pos == 2 || pos == 4 || pos == 6 || pos == 8 {
            continue;
        }

        let mut next_pods: [Pod; 16] = state.pods;
        next_pods[index] = Pod {
            pos,
            clr: pod.clr,
            fin: false,
        };

        let next_cost = state.cost + pod.energy() * dist(pod.pos, pos);

        let next_state = State {
            cost: next_cost,
            pods: next_pods,
        };
        next_states.push(next_state);
    }

    next_states
}

/// Returns the L1 norm between the given positions.
fn dist(pos_1: usize, pos_2: usize) -> usize {
    let (r1, c1) = coords(pos_1);
    let (r2, c2) = coords(pos_2);

    let dr = (r1 as isize - r2 as isize).unsigned_abs();
    let dc = (c1 as isize - c2 as isize).unsigned_abs();
    dr + dc
}

/// Returns the Cartesian coordinates of the given position.
fn coords(pos: usize) -> (usize, usize) {
    if pos < 11 {
        return (0, pos);
    }

    let col = 2 + 2 * ((pos - 11) / 4);
    let row = 1 + ((pos - 11) % 4);
    (row, col)
}

fn main() {
    let input = std::fs::read_to_string("input").unwrap().trim().to_string();
    part_1(input.clone());
    part_2(input);
}