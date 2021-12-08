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
    let lines = get_lines_from_file("input");
    let mut res = 0;
    for line in lines.flatten() {
        let mut seven_segment_count = [""; 10];
        let [input, output]: [Vec<&str>; 2] = line
            .split('|')
            .map(str::trim)
            .map(|x| x.split(' ').collect())
            .collect::<Vec<Vec<&str>>>()
            .try_into()
            .unwrap();
        for i in &input {
            if i.len() == 2 {
                seven_segment_count[1] = i
            };
            if i.len() == 4 {
                seven_segment_count[4] = i
            };
            if i.len() == 3 {
                seven_segment_count[7] = i
            };
            if i.len() == 7 {
                seven_segment_count[8] = i
            };
        }
        seven_segment_count[6] = input
            .iter()
            .find(|x| x.len() == 6 && !seven_segment_count[1].chars().all(|c| x.contains(c)))
            .unwrap();
        let f = seven_segment_count[6]
            .chars()
            .find(|x| seven_segment_count[1].contains(*x))
            .unwrap();
        seven_segment_count[3] = input
            .iter()
            .find(|x| x.len() == 5 && seven_segment_count[1].chars().all(|c| x.contains(c)))
            .unwrap();
        seven_segment_count[5] = input
            .iter()
            .find(|x| x.len() == 5 && !seven_segment_count.contains(x) && x.contains(f))
            .unwrap();
        seven_segment_count[2] = input
            .iter()
            .find(|x| x.len() == 5 && !seven_segment_count.contains(x))
            .unwrap();
        let e = seven_segment_count[6]
            .chars()
            .find(|x| !seven_segment_count[5].contains(*x))
            .unwrap();
        seven_segment_count[0] = input
            .iter()
            .find(|x| x.len() == 6 && !seven_segment_count.contains(x) && x.contains(e))
            .unwrap();
        seven_segment_count[9] = input
            .iter()
            .find(|x| x.len() == 6 && !seven_segment_count.contains(x))
            .unwrap();

        let mut output_res = 0;
        for num in output {
            output_res *= 10;
            for (i, seven_segment_str) in seven_segment_count.iter().enumerate() {
                if seven_segment_str.len() == num.len()
                    && seven_segment_str.chars().all(|x| num.contains(x))
                {
                    output_res += i;
                }
            }
        }

        res += output_res;
    }

    println!("part2 {}", res);

    Ok(())
}

fn main() -> Result<(), std::io::Error> {
    part1()?;
    part2()?;
    Ok(())
}
