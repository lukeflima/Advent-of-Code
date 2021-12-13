use std::collections::HashSet;

use utils::{get_lines_from_file, parse_number};

fn part1() {
    let lines = get_lines_from_file("input");
    let mut grid: HashSet<(usize, usize)> = Default::default();
    let mut folds: Vec<(char, usize)> = Default::default();
    let mut width: usize = 0;
    let mut height: usize = 0;
    for line in lines.map(Result::unwrap).filter(|x| !x.is_empty()) {
        if line.starts_with("fold along") {
            let [axis, value]: [&str; 2] = line
                .split(' ')
                .nth(2)
                .unwrap()
                .split('=')
                .collect::<Vec<&str>>()
                .try_into()
                .unwrap();
            let value: usize = parse_number(value);
            folds.push((axis.chars().next().unwrap(), value));
        } else {
            let [x, y]: [usize; 2] = line
                .split(',')
                .map(parse_number)
                .collect::<Vec<usize>>()
                .try_into()
                .unwrap();
            width = std::cmp::max(x, width);
            height = std::cmp::max(y, height);
            grid.insert((x, y));
        }
    }
    let (axis, value) = folds.into_iter().next().unwrap();
    let radius = std::cmp::min(value, if axis == 'y' { height } else { width } - value);
    for (x, y) in grid.clone().into_iter() {
        if axis == 'y' && y >= value {
            grid.remove(&(x, y));
            if y == value {
                continue;
            }
            let dist = y - value;
            if dist <= radius {
                let point = (x, value - dist);
                if !grid.contains(&point) {
                    grid.insert(point);
                }
            }
        }
        if axis == 'x' && x > value {
            grid.remove(&(x, y));
            if x == value {
                continue;
            }
            let dist = x - value;
            if dist <= radius {
                let point = (value - dist, y);
                if !grid.contains(&point) {
                    grid.insert(point);
                }
            }
        }
    }

    println!("part1 {}", grid.len());
}

fn part2() {
    let lines = get_lines_from_file("input");
    let mut grid: HashSet<(usize, usize)> = Default::default();
    let mut folds: Vec<(char, usize)> = Default::default();
    let mut width: usize = 0;
    let mut height: usize = 0;
    for line in lines.map(Result::unwrap).filter(|x| !x.is_empty()) {
        if line.starts_with("fold along") {
            let [axis, value]: [&str; 2] = line
                .split(' ')
                .nth(2)
                .unwrap()
                .split('=')
                .collect::<Vec<&str>>()
                .try_into()
                .unwrap();
            let value: usize = parse_number(value);
            folds.push((axis.chars().next().unwrap(), value));
        } else {
            let [x, y]: [usize; 2] = line
                .split(',')
                .map(parse_number)
                .collect::<Vec<usize>>()
                .try_into()
                .unwrap();
            width = std::cmp::max(x, width);
            height = std::cmp::max(y, height);
            grid.insert((x, y));
        }
    }
    for (axis, value) in folds {
        let radius = std::cmp::min(value, if axis == 'y' { height } else { width } - value);
        for (x, y) in grid.clone().into_iter() {
            if axis == 'y' && y >= value {
                grid.remove(&(x, y));
                if y == value {
                    continue;
                }
                let dist = y - value;
                if dist <= radius {
                    let point = (x, value - dist);
                    if !grid.contains(&point) {
                        grid.insert(point);
                    }
                }
            }
            if axis == 'x' && x >= value {
                grid.remove(&(x, y));
                if x == value {
                    continue;
                }
                let dist = x - value;
                if dist <= radius {
                    let point = (value - dist, y);
                    if !grid.contains(&point) {
                        grid.insert(point);
                    }
                }
            }
        }
        if axis == 'y' {
            height = value;
        }
        if axis == 'x' {
            width = value;
        }
    }

    println!("part2");
    for j in 0..height {
        for i in 0..width {
            print!("{}", if grid.contains(&(i, j)) { "#" } else { "." });
        }
        println!();
    }
}

fn main() {
    part1();
    part2();
}
