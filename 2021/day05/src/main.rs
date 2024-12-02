use std::cmp::{max, min};
use utils::{get_lines_from_file, get_sign_or_zero, parse_number};

#[derive(Debug)]
struct Point {
    x: usize,
    y: usize,
}

#[derive(Debug)]
struct Line {
    begin: Point,
    end: Point,
}

fn parse_line(line: &str) -> Line {
    let [b_x, b_y, e_x, e_y]: [usize; 4] = line
        .split(" -> ")
        .map(|s| s.split(',').map(parse_number))
        .flatten()
        .collect::<Vec<usize>>()
        .try_into()
        .unwrap();

    Line {
        begin: Point { x: b_x, y: b_y },
        end: Point { x: e_x, y: e_y },
    }
}

fn create_grid(height: usize, width: usize) -> Vec<Vec<Option<usize>>> {
    let mut grid: Vec<Vec<Option<usize>>> = Default::default();
    for i in 0..width {
        grid.push(Vec::new());
        for _ in 0..height {
            grid[i].push(None);
        }
    }
    grid
}

#[allow(dead_code)]
fn print_grid(grid: &[Vec<Option<usize>>]) {
    for i in grid {
        for c in i {
            match c {
                Some(s) => print!("{}", s),
                None => print!("."),
            }
        }
        println!();
    }
    println!();
}

fn part1() -> Result<(), std::io::Error> {
    let file_lines = get_lines_from_file("input");
    let mut lines: Vec<Line> = Default::default();
    let mut width = 0;
    let mut height = 0;
    for line in file_lines.filter_map(Result::ok) {
        let line = parse_line(&line);
        width = max(max(width, line.begin.x + 1), line.end.x + 1);
        height = max(max(height, line.begin.y + 1), line.end.y + 1);
        lines.push(line);
    }

    let mut grid = create_grid(height, width);

    for line in lines {
        if line.begin.x == line.end.x || line.begin.y == line.end.y {
            let begin_x = min(line.begin.x, line.end.x);
            let end_x = max(line.begin.x, line.end.x) + 1;
            let begin_y = min(line.begin.y, line.end.y);
            let end_y = max(line.begin.y, line.end.y) + 1;
            for grid_x in grid.iter_mut().take(end_x).skip(begin_x) {
                for grid_x_y in grid_x.iter_mut().take(end_y).skip(begin_y) {
                    match grid_x_y {
                        Some(s) => *grid_x_y = Some(*s + 1),
                        None => *grid_x_y = Some(1),
                    }
                }
            }
        }
    }

    let count: usize = grid
        .into_iter()
        .flatten()
        .flatten()
        .filter(|x| *x >= 2)
        .count();

    println!("part1 {}", count);

    Ok(())
}

fn part2() -> Result<(), std::io::Error> {
    let file_lines = get_lines_from_file("input");
    let mut lines: Vec<Line> = Default::default();
    let mut width = 0;
    let mut height = 0;
    for line in file_lines.filter_map(Result::ok) {
        let line = parse_line(&line);
        width = max(max(width, line.begin.x + 1), line.end.x + 1);
        height = max(max(height, line.begin.y + 1), line.end.y + 1);
        lines.push(line);
    }

    let mut grid = create_grid(height, width);

    for line in lines {
        let mut cur_x = line.begin.x as i64;
        let mut cur_y = line.begin.y as i64;
        let x_dir = get_sign_or_zero(line.end.x as i64 - cur_x);
        let y_dir = get_sign_or_zero(line.end.y as i64 - cur_y);
        loop {
            let x = cur_x as usize;
            let y = cur_y as usize;
            match grid[x][y] {
                Some(s) => grid[x][y] = Some(s + 1),
                None => grid[x][y] = Some(1),
            }
            if cur_x as usize == line.end.x && cur_y as usize == line.end.y {
                break;
            }
            cur_x += x_dir;
            cur_y += y_dir;
        }
    }

    let count: usize = grid
        .into_iter()
        .flatten()
        .flatten()
        .filter(|x| *x >= 2)
        .count();

    println!("part2 {}", count);

    Ok(())
}

fn main() -> Result<(), std::io::Error> {
    part1()?;
    part2()?;
    Ok(())
}
