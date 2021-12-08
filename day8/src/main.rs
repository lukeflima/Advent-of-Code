use utils::get_lines_from_file;

fn part1() -> Result<(), std::io::Error> {
    let lines = get_lines_from_file("input");
    let wanted_sizes = [2, 3, 4, 7];
    let mut res: usize = 0;
    for line in lines.flatten() {
        let sizes: Vec<usize> = line
            .split('|')
            .nth(1)
            .unwrap()
            .trim()
            .split(' ')
            .map(str::len)
            .collect();
        for size in sizes {
            if wanted_sizes.contains(&size) {
                res += 1;
            }
        }
    }

    println!("part1 {}", res);

    Ok(())
}

fn part2() -> Result<(), std::io::Error> {
    Ok(())
}

fn main() -> Result<(), std::io::Error> {
    part1()?;
    part2()?;
    Ok(())
}
