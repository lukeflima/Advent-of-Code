use std::io::{prelude::*, BufReader};

fn parse_i64(string: String) -> i64 {
    string
        .trim()
        .parse::<i64>()
        .unwrap_or_else(|_| panic!("wrong input `{}`", string))
}

fn get_lines(filename: &str) -> std::io::Lines<BufReader<std::fs::File>> {
    let file = std::fs::File::open(filename).unwrap();
    let reader = BufReader::new(file);
    reader.lines()
}

fn part1() -> Result<(), std::io::Error> {
    let lines = get_lines("./input");

    let mut prev_depth: i64 = -1;
    let mut count: i64 = 0;

    for line in lines.map(|l| l.unwrap()) {
        let depth = parse_i64(line);

        count += (prev_depth != -1 && depth - prev_depth > 0) as i64;
        prev_depth = depth;
    }

    println!("part1 {}", count);

    Ok(())
}

const WINDOW_SIZE: usize = 3;

fn part2() -> Result<(), std::io::Error> {
    let mut lines = get_lines("./input");

    let mut count: i64 = 0;
    let mut window: [i64; WINDOW_SIZE] = [0; WINDOW_SIZE];

    for item in &mut window {
        let line = lines.next().unwrap().unwrap();
        let depth = parse_i64(line);
        *item = depth;
    }

    let mut i = 0;
    for line in lines.map(|l| l.unwrap()) {
        let depth = parse_i64(line);
        let sum = window.iter().sum::<i64>();
        let next_sum = sum - window[i] + depth;
        count += (sum < next_sum) as i64;
        window[i] = depth;
        i = (i + 1) % WINDOW_SIZE;
    }

    println!("part2 {}", count);

    Ok(())
}

fn main() -> Result<(), std::io::Error> {
    part1()?;
    part2()?;
    Ok(())
}
