use std::collections::HashMap;

fn add_points(p1: [i64; 2], p2: [i64; 2]) -> [i64; 2] {
    let [x1, y1] = p1;
    let [x2, y2] = p2;
    [x1 + x2, y1 + y2]
}

fn part1() {
    let input = std::fs::read_to_string("input").unwrap().trim().to_string();
    let blocks: Vec<_> = input.split("\n\n").collect();
    let get_value = | c: char | -> usize{ 
        if c == '.' { 0usize } 
        else if c == '#'{ 1usize }
        else { unreachable!("Not in the grid"); }
    };
    let algorithm: Vec<_> = blocks[0].trim().chars().map(get_value).collect();
    let image_lines: Vec<_> = blocks[1].split('\n').collect();
    let mut image = HashMap::new();
    let mut min_i = -1i64;
    let mut min_j = -1i64;
    let mut max_i = image_lines.len() as i64 + 1;
    let mut max_j = image_lines[0].len() as i64 + 1;
    for (i, line) in image_lines.iter().enumerate() {
        let line = line.trim().as_bytes();
        for (j, c) in line.iter().enumerate() {
            image.insert([i as i64, j as i64], get_value(*c as char));
        }
    }

    let dirs = [
        [-1, -1], [-1, 0], [-1, 1],
        [ 0, -1], [ 0, 0] ,[ 0, 1],
        [ 1, -1], [ 1, 0], [ 1, 1]
    ];
    
    for a in 0..2 {
        let mut output = HashMap::new();
        for i in min_i..max_i {
            for j in min_j..max_j {
                let pixel = [i, j];
                // dbg!(pixel);
                let mut val = 0usize;
                for dir in dirs {
                    let cur_pixel = add_points(pixel, dir);
                    // dbg!(cur_pixel, image.get(&cur_pixel));
                    val = (val << 1) | image.get(&cur_pixel).unwrap_or(if a % 2 == 0 { &0 } else { &1 });
                }
                // dbg!(val);
                output.insert(pixel, algorithm[val]);
                // dbg!(pixel);
            }
        }
        image = output;
        min_i -= 1;
        min_j -= 1;
        max_i += 1;
        max_j += 1;
        
        
    }

    let res: usize = image.values().sum();
    println!("part1 {}", res);
}

fn part2() {
    let input = std::fs::read_to_string("input").unwrap().trim().to_string();
    let blocks: Vec<_> = input.split("\n\n").collect();
    let get_value = | c: char | -> usize{ 
        if c == '.' { 0usize } 
        else if c == '#'{ 1usize }
        else { unreachable!("Not in the grid"); }
    };
    let algorithm: Vec<_> = blocks[0].trim().chars().map(get_value).collect();
    let image_lines: Vec<_> = blocks[1].split('\n').collect();
    let mut image = HashMap::new();
    let mut min_i = -1i64;
    let mut min_j = -1i64;
    let mut max_i = image_lines.len() as i64 + 1;
    let mut max_j = image_lines[0].len() as i64 + 1;
    for (i, line) in image_lines.iter().enumerate() {
        let line = line.trim().as_bytes();
        for (j, c) in line.iter().enumerate() {
            image.insert([i as i64, j as i64], get_value(*c as char));
        }
    }

    let dirs = [
        [-1, -1], [-1, 0], [-1, 1],
        [ 0, -1], [ 0, 0] ,[ 0, 1],
        [ 1, -1], [ 1, 0], [ 1, 1]
    ];
    
    for a in 0..50 {
        let mut output = HashMap::new();
        for i in min_i..max_i {
            for j in min_j..max_j {
                let pixel = [i, j];
                // dbg!(pixel);
                let mut val = 0usize;
                for dir in dirs {
                    let cur_pixel = add_points(pixel, dir);
                    // dbg!(cur_pixel, image.get(&cur_pixel));
                    val = (val << 1) | image.get(&cur_pixel).unwrap_or(if a % 2 == 0 { &0 } else { &1 });
                }
                // dbg!(val);
                output.insert(pixel, algorithm[val]);
                // dbg!(pixel);
            }
        }
        image = output;
        min_i -= 1;
        min_j -= 1;
        max_i += 1;
        max_j += 1;
        
        
    }

    let res: usize = image.values().sum();
    println!("part2 {}", res);
}

fn main() {
    part1();
    part2();
}
