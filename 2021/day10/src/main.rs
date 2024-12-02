use std::collections::HashMap;

use utils::get_lines_from_file;

fn part1() {
    let lines = get_lines_from_file("input");
    let bracks = HashMap::from([('}', '{'), (')', '('), (']', '['), ('>', '<')]);
    let bracks_points = HashMap::from([(')', 3), (']', 57), ('}', 1197), ('>', 25137)]);
    let mut res: usize = 0;
    for line in lines.map(Result::unwrap) {
        let mut chunck_q: Vec<char> = Default::default();
        for c in line.chars() {
            if bracks.contains_key(&c) {
                if *chunck_q.last().unwrap() == *bracks.get(&c).unwrap() {
                    chunck_q.pop();
                } else {
                    res += bracks_points.get(&c).unwrap();
                    break;
                }
            } else {
                chunck_q.push(c);
            }
        }
    }

    println!("part1 {}", res);
}

fn part2() {
    let lines = get_lines_from_file("input");
    let bracks = HashMap::from([('}', '{'), (')', '('), (']', '['), ('>', '<')]);
    let bracks_points = HashMap::from([('(', 1), ('[', 2), ('{', 3), ('<', 4)]);
    let mut result: Vec<usize> = Default::default();
    for line in lines.map(Result::unwrap) {
        let mut chunck_q: Vec<char> = Default::default();
        let mut ended = true;
        for c in line.chars() {
            if bracks.contains_key(&c) {
                if *chunck_q.last().unwrap() == *bracks.get(&c).unwrap() {
                    chunck_q.pop();
                } else {
                    ended = false;
                    break;
                }
            } else {
                chunck_q.push(c);
            }
        }
        if ended {
            let mut res: usize = 0;
            for c in chunck_q.iter().rev() {
                res = res * 5 + bracks_points.get(c).unwrap();
            }
            result.push(res);
        }
    }
    result.sort_unstable();
    println!("part2 {:?}", result[result.len() / 2]);
}

fn main() {
    part1();
    part2();
}
