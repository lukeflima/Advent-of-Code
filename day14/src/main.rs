use std::collections::{HashMap, LinkedList};

use utils::get_lines_from_file;

fn part1() {
    let mut lines = get_lines_from_file("input");
    let mut pattern = lines.next().unwrap().unwrap();
    let mut rules: HashMap<String, char> = Default::default();
    for line in lines.map(Result::unwrap).filter(|x| !x.is_empty()) {
        let [key, value]: [String; 2] = line
            .split(" -> ")
            .map(String::from)
            .collect::<Vec<String>>()
            .try_into()
            .unwrap();
        rules.insert(key, value.chars().next().unwrap());
    }
    for _ in 0..10 {
        let mut buffer: LinkedList<char> = Default::default();
        buffer.push_back(pattern.chars().nth(0).unwrap());
        for i in 0..(pattern.len() - 1) {
            let pair = &pattern[i..=i + 1];
            buffer.push_back(*rules.get(pair).unwrap());
            buffer.push_back(pair.chars().nth(1).unwrap())
        }
        pattern = buffer.iter().collect();
    }
    let freq = pattern
        .chars()
        .fold(HashMap::<char, usize>::new(), |mut m, x| {
            *m.entry(x).or_default() += 1;
            m
        });
    let max = freq
        .iter()
        .max_by_key(|(_, v)| *v)
        .map(|(_, k)| *k)
        .unwrap();
    let min = freq
        .iter()
        .min_by_key(|(_, v)| *v)
        .map(|(_, k)| *k)
        .unwrap();
    println!("part1 {}", max - min);
}

fn part2() {}

fn main() {
    part1();
    part2();
}
