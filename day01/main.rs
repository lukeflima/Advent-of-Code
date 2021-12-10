use utils::{get_lines_from_file, parse_number};

fn part1() -> Result<(), std::io::Error> {
    let lines = get_lines_from_file("./input");

    let mut prev_depth: i64 = -1;
    let mut count: i64 = 0;

    for line in lines.map(|l| l.unwrap()) {
        let depth: i64 = parse_number(&line);

        count += (prev_depth != -1 && depth - prev_depth > 0) as i64;
        prev_depth = depth;
    }

    println!("part1 {}", count);

    Ok(())
}

const WINDOW_SIZE: usize = 3;

fn part2() -> Result<(), std::io::Error> {
    let mut lines = get_lines_from_file("./input");

    let mut count: i64 = 0;
    let mut window: [i64; WINDOW_SIZE] = [0; WINDOW_SIZE];

    for item in &mut window {
        let line = lines.next().unwrap().unwrap();
        let depth: i64 = parse_number(&line);
        *item = depth;
    }

    let mut i = 0;
    for line in lines.map(|l| l.unwrap()) {
        let depth: i64 = parse_number(&line);
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
