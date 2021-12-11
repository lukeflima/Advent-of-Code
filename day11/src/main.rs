use utils::parse_number;

#[derive(Default, Debug)]
struct Cell {
    value: usize,
    visited: bool,
    flashed: bool,
}

fn flash_neighbours(i: usize, j: usize, octupus: &mut Vec<Vec<Cell>>, flash_count: &mut usize) {
    let list_neighbours_index: [(i64, i64); 8] = [
        (-1, -1),
        (-1, 0),
        (-1, 1),
        (0, -1),
        (0, 1),
        (1, -1),
        (1, 0),
        (1, 1),
    ];
    for (ni, nj) in list_neighbours_index {
        let ni = i as i64 + ni;
        let nj = j as i64 + nj;
        if ni >= 0 && ni < octupus.len() as i64 && nj >= 0 && nj < octupus[0].len() as i64 {
            visit(flash_count, octupus, ni as usize, nj as usize, true);
        }
    }
}

fn visit(flash_count: &mut usize, octupus: &mut Vec<Vec<Cell>>, i: usize, j: usize, flashed: bool) {
    if octupus[i][j].flashed {
        return;
    }
    if flashed {
        octupus[i][j].value += 1;
    }
    if !octupus[i][j].visited {
        octupus[i][j].visited = true;
        octupus[i][j].value += 1;
    }
    if octupus[i][j].value > 9 {
        octupus[i][j].flashed = true;
        octupus[i][j].value = 0;
        *flash_count += 1;
        flash_neighbours(i, j, octupus, flash_count);
    }
}

fn solve() {
    let mut octupus: Vec<Vec<Cell>> = std::fs::read_to_string("input")
        .unwrap()
        .as_mut_str()
        .trim()
        .split('\n')
        .map(|x| {
            x.trim()
                .chars()
                .map(|x| Cell {
                    value: parse_number::<usize>(&x.to_string()),
                    flashed: false,
                    visited: false,
                })
                .collect()
        })
        .collect();
    let mut flash_count: usize = 0;
    let mut c = 0;
    loop {
        for i in 0..octupus.len() {
            for j in 0..octupus[i].len() {
                visit(&mut flash_count, &mut octupus, i, j, false);
            }
        }
        if c + 1 == 100 {
            println!("part1 {}", flash_count);
        }
        if octupus.iter().flatten().all(|x| x.flashed) {
            println!("part2 {}", c + 1);
            break;
        }
        for row in &mut octupus {
            for oct in row {
                oct.flashed = false;
                oct.visited = false;
            }
        }
        c += 1;
    }
}

fn main() {
    solve();
}
