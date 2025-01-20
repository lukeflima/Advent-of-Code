use utils::parse_number;

fn part1() -> Result<(), std::io::Error> {
    let crabs: Vec<usize> = std::fs::read_to_string("input")
        .unwrap()
        .split(',')
        .map(parse_number)
        .collect();

    let max_depth = *crabs.iter().max().unwrap();

    let mut min_fuel_use_value = usize::MAX;
    for i in 0..max_depth {
        let mut fuel = 0_usize;
        for crab in &crabs {
            if i == *crab {
                continue;
            }
            fuel += std::cmp::max(*crab, i) - std::cmp::min(*crab, i);
        }
        min_fuel_use_value = std::cmp::min(min_fuel_use_value, fuel);
    }
    println!("part1 {}", min_fuel_use_value);

    Ok(())
}

fn part2() -> Result<(), std::io::Error> {
    let crabs: Vec<usize> = std::fs::read_to_string("input")
        .unwrap()
        .split(',')
        .map(parse_number)
        .collect();
    let max_depth = *crabs.iter().max().unwrap();

    let mut min_fuel_use_value = usize::MAX;
    for i in 0..max_depth {
        let mut fuel = 0;
        for crab in &crabs {
            if i == *crab {
                continue;
            }
            let depth = std::cmp::max(*crab, i) - std::cmp::min(*crab, i);
            fuel += depth * (depth + 1) / 2;
        }
        min_fuel_use_value = std::cmp::min(min_fuel_use_value, fuel );
    }

    println!("part2 {}", min_fuel_use_value);

    Ok(())
}

fn main() -> Result<(), std::io::Error> {
    part1()?;
    part2()?;
    Ok(())
}
