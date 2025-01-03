fn add_tuples(p1: (usize, usize), p2: (usize, usize)) -> (usize, usize) {
    let (x1, y1) = p1;
    let (x2, y2) = p2;
    (x1 + x2, y1 + y2)
}

fn mod_tuples(p1: (usize, usize), p2: (usize, usize)) -> (usize, usize) {
    let (x1, y1) = p1;
    let (x2, y2) = p2;
    (x1 % x2, y1 % y2)
}


fn part1() {
    let input = std::fs::read_to_string("input").unwrap().trim().to_string();
    let mut grid: Vec<Vec<_>> = input.split("\n").map(|line| line.chars().collect()).collect();
    let dimentions = (grid.len(), grid[0].len());
    let mut steps = 0;
    loop {
        let mut num_moves = 0;
        steps += 1;
        for turn in 0..2 {
            let mut new_grid = grid.clone();
            let (cucumber, dir) = if turn == 1 { ('v', (1, 0)) } else {('>', (0, 1))};
            for (i, row) in grid.iter().enumerate(){
                for (j, cell) in row.iter().enumerate() {
                    if *cell == cucumber {
                        let (nx, ny) = mod_tuples(add_tuples((i, j), dir), dimentions);
                        if grid[nx][ny] == '.' {
                            new_grid[nx][ny] = cucumber;
                            new_grid[i][j] = '.';
                            num_moves += 1;
                        }
                    }
                }
            }
            grid = new_grid;
        }
        if num_moves == 0 {
            break;
        }
    }
    println!("part1 {}", steps);
}

fn part2() {
    let input = std::fs::read_to_string("input").unwrap().trim().to_string();
}

fn main() {
    part1();
    part2();
}
