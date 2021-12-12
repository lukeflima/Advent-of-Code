use std::collections::HashMap;

fn part1() {
    let graph: HashMap<String, Vec<String>> = {
        let mut graph: HashMap<String, Vec<String>> = Default::default();
        let nodes_conn: Vec<Vec<String>> = std::fs::read_to_string("input")
            .unwrap()
            .as_mut_str()
            .trim()
            .split('\n')
            .map(|x| x.trim().split('-').map(String::from).collect())
            .collect();
        for conn in nodes_conn {
            if !graph.contains_key(&conn[0]) {
                graph.insert(conn[0].clone(), Default::default());
            }
            if !graph.contains_key(&conn[1]) {
                graph.insert(conn[1].clone(), Default::default());
            }
            graph.get_mut(&conn[0]).unwrap().push(conn[1].clone());
            graph.get_mut(&conn[1]).unwrap().push(conn[0].clone());
        }
        graph
    };
    let mut paths: usize = 0;
    let mut unfinesh_paths: Vec<Vec<String>> = vec![vec![String::from("start")]];

    while !unfinesh_paths.is_empty() {
        let path = unfinesh_paths.pop().unwrap();
        if path.last().unwrap() == "end" {
            paths += 1;
            continue;
        }
        for node in graph.get(&path[path.len() - 1]).unwrap() {
            if node.chars().next().unwrap().is_uppercase() || !path.contains(node) {
                unfinesh_paths.push(path.clone());
                unfinesh_paths.last_mut().unwrap().push(node.clone());
            }
        }
    }

    println!("part1 {}", paths);
}

fn part2() {
    let graph: HashMap<String, Vec<String>> = {
        let mut graph: HashMap<String, Vec<String>> = Default::default();
        let nodes_conn: Vec<Vec<String>> = std::fs::read_to_string("input")
            .unwrap()
            .as_mut_str()
            .trim()
            .split('\n')
            .map(|x| x.trim().split('-').map(String::from).collect())
            .collect();
        for conn in nodes_conn {
            if !graph.contains_key(&conn[0]) {
                graph.insert(conn[0].clone(), Default::default());
            }
            if !graph.contains_key(&conn[1]) {
                graph.insert(conn[1].clone(), Default::default());
            }
            graph.get_mut(&conn[0]).unwrap().push(conn[1].clone());
            graph.get_mut(&conn[1]).unwrap().push(conn[0].clone());
        }
        graph
    };
    let mut paths: usize = 0;
    let mut unfinesh_paths: Vec<(Vec<String>, bool)> = vec![(vec![String::from("start")], false)];

    while !unfinesh_paths.is_empty() {
        let (path, small_cave_revisit) = unfinesh_paths.pop().unwrap();
        if path.last().unwrap() == "end" {
            paths += 1;
            continue;
        }
        for node in graph.get(&path[path.len() - 1]).unwrap() {
            if node == "start" {
                continue;
            }
            let is_upper = node.chars().next().unwrap().is_uppercase();
            if !is_upper && !small_cave_revisit && path.iter().filter(|&x| *x == *node).count() == 1
            {
                unfinesh_paths.push((path.clone(), true));
            } else if is_upper || !path.contains(node) {
                unfinesh_paths.push((path.clone(), small_cave_revisit));
            } else {
                continue;
            }
            unfinesh_paths.last_mut().unwrap().0.push(node.clone());
        }
    }
    println!("part2 {}", paths);
}

fn main() {
    part1();
    part2();
}
