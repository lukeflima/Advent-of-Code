use utils::parse_number;

fn part1() {
    let heightmap: Vec<Vec<usize>> = std::fs::read_to_string("input")
        .unwrap()
        .as_mut_str()
        .trim()
        .split('\n')
        .map(|x| {
            x.trim()
                .chars()
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

fn visit(
    basins: &mut Vec<Vec<usize>>,
    heightmap: &mut Vec<Vec<Cell>>,
    i: usize,
    j: usize,
    basin_index: usize,
) {
    if heightmap[i][j].visited || heightmap[i][j].value == 9 {
        return;
    }
    if basin_index == 0 {
        basins.push(Default::default());
    }
    basins.last_mut().unwrap().push(heightmap[i][j].value);
    heightmap[i][j].visited = true;
    if i != 0 {
        visit(basins, heightmap, i - 1, j, basin_index + 1);
    }
    if i < heightmap.len() - 1 {
        visit(basins, heightmap, i + 1, j, basin_index + 1);
    }
    if j != 0 {
        visit(basins, heightmap, i, j - 1, basin_index + 1);
    }
    if j < heightmap[i].len() - 1 {
        visit(basins, heightmap, i, j + 1, basin_index + 1);
    }
}

fn part2() {
    let mut heightmap: Vec<Vec<Cell>> = std::fs::read_to_string("input")
        .unwrap()
        .as_mut_str()
        .trim()
        .split('\n')
        .map(|x| {
            x.trim()
                .chars()
                .map(|x| Cell {
                    value: parse_number::<usize>(&x.to_string()),
                    visited: false,
                })
                .collect()
        })
        .collect();
    let mut basins: Vec<Vec<usize>> = Default::default();
    for i in 0..heightmap.len() {
        for j in 0..heightmap[i].len() {
            visit(&mut basins, &mut heightmap, i, j, 0);
        }
    }
    basins.sort_by(|a, b| {
        let a_size = a.len();
        let b_size = b.len();
        a_size.cmp(&b_size)
    });
    let res: usize = basins
        .iter()
        .skip(basins.len() - 3)
        .map(|x| x.len())
        .product();
    println!("part2 {}", res);
}

fn main() {
    part1();
    part2();
}
