use utils::get_lines_from_file;

fn cosume(count: &mut Vec<usize>, line: &str) {
    for (i, c) in line.chars().enumerate() {
        if count.len() < i + 1 {
            count.push(0);
        }
        count[i] += (c == '0') as usize;
    }
}

fn part1() -> Result<(), std::io::Error> {
    let mut lines = get_lines_from_file("./input");

    let line = lines.next().unwrap().unwrap();
    let num_bits = line.len();
    let mut count: Vec<usize> = Default::default();
    cosume(&mut count, &line);

    let mut num_lines = 1;
    for line in lines.map(|s| s.unwrap()) {
        num_lines += 1;
        cosume(&mut count, &line);
    }

    let mut gamma: u64 = 0;
    for i in count {
        gamma = (gamma << 1) | (i >= num_lines / 2) as u64;
    }
    let epsilon = !gamma & ((1 << num_bits) - 1);

    println!("part1 {}", gamma * epsilon);

    Ok(())
}

fn part2() -> Result<(), std::io::Error> {
    let lines = get_lines_from_file("./input")
        .map(|s| s.unwrap())
        .collect::<Vec<String>>();

    let num_bits = lines[0].len();

    let co2 = {
        let mut co2_list = lines.clone();

        let mut bit: usize = 0;
        while bit < num_bits && co2_list.len() != 1 {
            let mut count: Vec<usize> = Default::default();
            let mut num_lines = 0;
            for line in &co2_list {
                num_lines += 1;
                cosume(&mut count, line);
            }
            let most_commun_bit: Vec<char> = count
                .into_iter()
                .map(|c| {
                    match c.cmp(&(num_lines/2)) {
                        std::cmp::Ordering::Greater => '1',
                        std::cmp::Ordering::Equal => '=',
                        std::cmp::Ordering::Less => '0',
                    }
                })
                .collect();
            co2_list.retain(|s| {
                    let most = most_commun_bit[bit];
                    let c = s.chars().nth(bit).unwrap();
                    if most == '=' {
                        return c == '0';
                    }
                    c == most
                });
            bit += 1;
        }
        usize::from_str_radix(&co2_list[0], 2).unwrap()
    };

    let oxygen = {
        let mut oxygen_list = lines.clone();

        let mut bit: usize = 0;
        while bit < num_bits && oxygen_list.len() != 1 {
            let mut count: Vec<usize> = Default::default();
            let mut num_lines = 0;
            for line in &oxygen_list {
                num_lines += 1;
                cosume(&mut count, line);
            }
            let most_commun_bit: Vec<char> = count
                .into_iter()
                .map(|c| {
                    match c.cmp(&(num_lines/2)) {
                        std::cmp::Ordering::Greater => '1',
                        std::cmp::Ordering::Equal => '=',
                        std::cmp::Ordering::Less => '0',
                    }
                })
                .collect();
            oxygen_list.retain(|s| {
                    let most = most_commun_bit[bit];
                    let c = s.chars().nth(bit).unwrap();
                    if most == '=' {
                        return c == '1';
                    }
                    c != most
                });
            bit += 1;
        }
        usize::from_str_radix(&oxygen_list[0], 2).unwrap()
    };

    println!("part2 {}", oxygen * co2);

    Ok(())
}

fn main() -> Result<(), std::io::Error> {
    part1()?;
    part2()?;
    Ok(())
}
