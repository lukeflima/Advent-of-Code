use utils::{get_sign_or_zero, parse_number};

fn in_target(x: i64, y: i64, xmin: i64, xmax: i64, ymin: i64, ymax: i64) -> bool {
    x >= xmin && x <= xmax && y >= ymin && y <= ymax
}

fn simulate(vx: i64, vy: i64, xmax: i64, xmin: i64, ymin: i64, ymax: i64) -> (i64, bool) {
    let mut x = 0;
    let mut y = 0;
    let mut vx = vx;
    let mut vy = vy;
    let mut max_height = i64::MIN;
    while !in_target(x, y, xmin, xmax, ymin, ymax) && x <= xmax && y >= ymin {
        max_height = std::cmp::max(max_height, y);
        x += vx;
        y += vy;
        vx -= get_sign_or_zero(vx);
        vy -= 1;
    }
    (max_height, in_target(x, y, xmin, xmax, ymin, ymax))
}

fn part1() {
    let [xmin, xmax, ymin, ymax]: [i64; 4] = std::fs::read_to_string("input")
        .unwrap()
        .split(':')
        .last()
        .unwrap()
        .split(',')
        .map(str::trim)
        .flat_map(|s| s.split('=').last().unwrap().split(".."))
        .map(parse_number)
        .collect::<Vec<i64>>()
        .try_into()
        .unwrap();

    let mut res = i64::MIN;
    let mut count = 0_i64;
    for vy in ymin..500 {
        for vx in 1..xmax + 1 {
            let (h, success) = simulate(vx, vy, xmax, xmin, ymin, ymax);
            if success {
                count += 1;
                res = std::cmp::max(res, h);
            }
        }
    }

    println!("part1 {}", res);
    println!("part2 {}", count);
}

fn part2() {}

fn main() {
    part1();
    part2();
}
