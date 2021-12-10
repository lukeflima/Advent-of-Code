use std::fs;

use utils::parse_number;

fn solve() -> Result<(), std::io::Error> {
    let mut fishes_per_day = [0_usize; 9];
    for i in fs::read_to_string("input").unwrap().split(',') {
        let i: usize = parse_number(i);
        fishes_per_day[i] += 1;
    }
    for i in 0..256 {
        if i == 80 {
            let num_fishes: usize = fishes_per_day.into_iter().sum();
            println!("part1 {}", num_fishes);
        }
        let new_fishes = fishes_per_day[0];
        for i in 0..(fishes_per_day.len() - 1) {
            fishes_per_day[i] = fishes_per_day[i + 1];
        }
        fishes_per_day[6] += new_fishes;
        fishes_per_day[8] = new_fishes;
    }
    let num_fishes: usize = fishes_per_day.into_iter().sum();
    println!("part2 {}", num_fishes);

    Ok(())
}

fn main() -> Result<(), std::io::Error> {
    solve()?;
    Ok(())
}
