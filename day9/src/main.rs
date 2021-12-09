use utils::parse_number;

fn part1() {
    let heightmap: Vec<Vec<usize>> = std::fs::read_to_string("input")
        .unwrap()
        .as_mut_str()
        .trim()
        .split('\n')
        .map(|x| {
            x.chars()
                .map(|x| parse_number::<usize>(&x.to_string()))
                .collect()
        })
        .collect();

    let mut lowest: Vec<usize> = Default::default();
    for i in 0..heightmap.len() {
        for j in 0..heightmap[i].len() {
            let mut neighbours = [usize::MAX; 4];
            if i != 0 {
                neighbours[0] = heightmap[i - 1][j];
            }
            if i < heightmap.len() - 1 {
                neighbours[1] = heightmap[i + 1][j];
            }
            if j != 0 {
                neighbours[2] = heightmap[i][j - 1];
            }
            if j < heightmap[i].len() - 1 {
                neighbours[3] = heightmap[i][j + 1];
            }
            if heightmap[i][j] < *neighbours.iter().min().unwrap() {
                lowest.push(heightmap[i][j]);
            }
        }
    }

    let res: usize = lowest.iter().map(|x| x + 1).sum();
    println!("part1 {}", res);
}

#[derive(Default, Debug)]
struct Cell {
    value: usize,
    visited: bool,
}

fn part2() {}

fn main() {
    part1();
    part2();
}
