use std::collections::{HashSet, VecDeque};

use itertools::Itertools;
use utils::parse_number;

fn rotate_point(point: [i64; 3], orientation: usize) -> [i64; 3] {
    let [x, y, z] = point;

    match orientation {
        0 => [x, y, z],
        1 => [x, z, -y],
        2 => [x, -y, -z],
        3 => [x, -z, y],
        4 => [-x, y, -z],
        5 => [-x, z, y],
        6 => [-x, -y, z],
        7 => [-x, -z, -y],
        8 => [y, x, -z],
        9 => [y, z, x],
        10 => [y, -x, z],
        11 => [y, -z, -x],
        12 => [-y, x, z],
        13 => [-y, z, -x],
        14 => [-y, -x, -z],
        15 => [-y, -z, x],
        16 => [z, x, y],
        17 => [z, y, -x],
        18 => [z, -x, -y],
        19 => [z, -y, x],
        20 => [-z, x, -y],
        21 => [-z, y, x],
        22 => [-z, -x, y],
        23 => [-z, -y, -x],
        _ => panic!("Invalid orientation. Must be between 0 and 23."),
    }
}

fn add_points(p1: [i64; 3], p2: [i64; 3]) -> [i64; 3] {
    let [x1, y1, z1] = p1;
    let [x2, y2, z2] = p2;
    [x1 + x2, y1 + y2, z1 + z2]
}

fn sub_points(p1: [i64; 3], p2: [i64; 3]) -> [i64; 3] {
    let [x1, y1, z1] = p1;
    let [x2, y2, z2] = p2;
    [x1 - x2, y1 - y2, z1 - z2]
}

fn manhattan_dist(p1: [i64; 3], p2: [i64; 3]) -> i64 {
    let [x1, y1, z1] = p1;
    let [x2, y2, z2] = p2;
    (x1 - x2).abs() + (y1 - y2).abs() + (z1 - z2).abs()
}

fn get_intersection(beacons: &HashSet<[i64; 3]>, scanner_src: &HashSet<[i64; 3]>) -> Option<(HashSet<[i64; 3]>, [i64;3])> {
    for point_ref in beacons.iter() {
        for orientation in 0..24 {
            let scanner: HashSet<_> = scanner_src.iter().map(|p| rotate_point(*p, orientation)).collect();
            for point in &scanner {
                let scanner_center = sub_points(*point_ref, *point);
                let offseted_points: HashSet<_> = scanner.iter().map(|p| add_points(*p, scanner_center)).collect();
                let count = beacons.intersection(&offseted_points).count();
                if count >= 12 {
                    return Some((offseted_points, scanner_center));
                }
            }
        }
    }
    None
}

fn part1() {
    let input = std::fs::read_to_string("input").unwrap();
    let scanners: Vec<HashSet<_>> = input.split("\n\n")
        .map(|s| 
            s.trim().split("\n").skip(1).map(|v| {
                let mut vec: [i64; 3] = [0; 3];
                for (i, v) in v.split(",").enumerate() { 
                    vec[i] = parse_number(v);
                }
                vec
            }).collect()
        ).collect();
    
    let mut iter = scanners.iter();
    let mut beacons: HashSet<_> = iter.next().unwrap().clone();
    let mut centers = vec![[0,0,0]; scanners.len()];
    let mut stack: VecDeque<_> = iter.enumerate().map(|(i, v)| (i + 1, v)).collect();
    while !stack.is_empty() {
        let (i, scanner) = stack.pop_front().unwrap();
        let intersection = get_intersection(&beacons, scanner);
        if let Some((intersection, center)) = intersection {
            centers[i] = center;
            beacons.extend(intersection);
        } else {
            stack.push_back((i, scanner));
        }
    }
    
    let max_dist = centers.iter().combinations(2).map(|ps| {
        let (p1, p2) = (*ps[0], *ps[1]);
        manhattan_dist(p1, p2)
    }).max().unwrap();

    println!("part1 {}", beacons.len());
    println!("part2 {}", max_dist);
}

fn part2() {
    let _input = std::fs::read_to_string("input").unwrap();
}

fn main() {
    part1();
    part2();
}
 