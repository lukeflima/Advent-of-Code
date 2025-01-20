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
        buffer.push_back(pattern.chars().next().unwrap());
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
    let (min, max) = freq
        .iter()
        .fold((usize::MAX, 0), |(min, max), (_, v)| (*v.min(&min), *v.max(&max)));

    println!("part1 {}", max - min);
}

fn part2() {
    let mut lines = get_lines_from_file("input");
    let pattern = lines.next().unwrap().unwrap();
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
    let mut freq: HashMap<String, usize> = Default::default();
    for i in 0..(pattern.len() - 1) {
        let pair = String::from(&pattern[i..=i + 1]);
        *freq.entry(pair).or_default() += 1;
    }
    for _ in 0..40 {
        let mut new_freq = freq.clone();
        for (pair, f) in freq {
            let c = *rules.get(&pair).unwrap();
            let next_pair_1: String = [pair.chars().next().unwrap(), c].iter().collect();
            let next_pair_2: String = [c, pair.chars().nth(1).unwrap()].iter().collect();
            *new_freq.entry(pair).or_default() -= f;
            *new_freq.entry(next_pair_1).or_default() += f;
            *new_freq.entry(next_pair_2).or_default() += f;
        }
        freq = new_freq;
    }
    let mut flat_freq: HashMap<char, usize> = Default::default();
    for (pair, f) in freq {
        let [c1, c2]: [char; 2] = pair.chars().collect::<Vec<char>>().try_into().unwrap();
        *flat_freq.entry(c1).or_default() += f;
        *flat_freq.entry(c2).or_default() += f;
    }
    *flat_freq
        .entry(pattern.chars().next().unwrap())
        .or_default() += 1;
    *flat_freq
        .entry(pattern.chars().last().unwrap())
        .or_default() += 1;
    let count_freq: Vec<usize> = flat_freq.values().map(| f| *f / 2).collect();
    let (min, max) = count_freq
        .iter()
        .fold((usize::MAX, 0), |(min, max), v| (*v.min(&min), *v.max(&max)));
    println!("part2 {:?}", max - min);
}

fn main() {
    part1();
    part2();
}
