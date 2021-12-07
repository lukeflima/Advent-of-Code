use utils::{get_lines_from_file, parse_number};

#[derive(Default)]
struct Pos {
    horizontal: i64,
    depth: i64,
    aim: i64,
}

impl Pos {
    fn run_cmd_part1(&mut self, cmd: &str, value: i64) {
        match cmd {
            "up" => self.depth -= value,
            "down" => self.depth += value,
            "forward" => self.horizontal += value,
            _ => unreachable!(),
        }
    }

    fn run_cmd_part2(&mut self, cmd: &str, value: i64) {
        match cmd {
            "up" => self.aim -= value,
            "down" => self.aim += value,
            "forward" => {
                self.horizontal += value;
                self.depth += value * self.aim;
            }
            _ => unreachable!(),
        }
    }

    fn get_mult(self) -> i64 {
        self.horizontal * self.depth
    }
}

fn part1() -> Result<(), std::io::Error> {
    let lines = get_lines_from_file("./input");

    let mut pos: Pos = Default::default();

    for line in lines.map(|s| s.unwrap()) {
        let [cmd, value]: [&str; 2] = line.split(" ").collect::<Vec<&str>>().try_into().unwrap();
        let value: i64 = parse_number(value);
        pos.run_cmd_part1(cmd, value);
    }

    println!("part1 {}", pos.get_mult());

    Ok(())
}

fn part2() -> Result<(), std::io::Error> {
    let lines = get_lines_from_file("./input");

    let mut pos: Pos = Default::default();

    for line in lines.map(|s| s.unwrap()) {
        let [cmd, value]: [&str; 2] = line.split(" ").collect::<Vec<&str>>().try_into().unwrap();
        let value: i64 = parse_number(value);
        pos.run_cmd_part2(cmd, value)
    }

    println!("part2 {}", pos.get_mult());

    Ok(())
}

fn main() -> Result<(), std::io::Error> {
    part1()?;
    part2()?;
    Ok(())
}
