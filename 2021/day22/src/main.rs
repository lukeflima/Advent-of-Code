use std::collections::HashSet;

use utils::parse_number;

fn part1() {
    let input = std::fs::read_to_string("sample").unwrap().trim().to_string();
    let mut cuboids = HashSet::new();
    cuboids.insert([0;3]);
    for (state, ranges) in input.lines().map(|l| l.split_once(" ").unwrap()) {
        let ranges: Vec<_> = ranges.trim().split(",").collect();
        let xs = ranges[0].chars().skip(2).collect::<String>();
        let xs = xs.split_once("..").unwrap();
        let (x_min, x_max): (i64, i64) = (std::cmp::max(-50, parse_number(xs.0)), std::cmp::min(50, parse_number(xs.1)));
        
        let ys = ranges[1].chars().skip(2).collect::<String>();
        let ys = ys.split_once("..").unwrap();
        let (y_min, y_max): (i64, i64) = (std::cmp::max(-50, parse_number(ys.0)), std::cmp::min(50, parse_number(ys.1)));

        let zs = ranges[2].chars().skip(2).collect::<String>();
        let zs = zs.split_once("..").unwrap();
        let (z_min, z_max): (i64, i64) = (std::cmp::max(-50, parse_number(zs.0)), std::cmp::min(50, parse_number(zs.1)));
        
        for x in x_min..=x_max {
            for y in y_min..=y_max {
                for z in z_min..=z_max {
                    let cuboid = [x, y, z];
                    if state == "on" {
                        cuboids.insert(cuboid);
                    } else {
                        cuboids.remove(&cuboid);
                    }
                }
            }

        }
    }
    println!("part1 {}", cuboids.len());
}

#[derive(Clone, Debug)]
struct Range {
    x_min: i64,
    x_max: i64,
    y_min: i64,
    y_max: i64,
    z_min: i64,
    z_max: i64,
}

impl Range {
    fn overlaps(&self, other: &Range) -> bool {
        let x_overlap = self.x_min <= other.x_max && self.x_max >= other.x_min;
        let y_overlap = self.y_min <= other.y_max && self.y_max >= other.y_min;
        let z_overlap = self.z_min <= other.z_max && self.z_max >= other.z_min;
        x_overlap && y_overlap && z_overlap
    }
       
    fn remove_overlap(&self, other: &Range) -> Vec<Range> {
        let mut remaining = Vec::new();

        if !self.overlaps(other) {
            remaining.push(self.clone());
            return remaining;
        }

        // Add ranges for each non-overlapping region
        if self.x_min < other.x_min {
            remaining.push(Range {
                x_min: self.x_min,
                x_max: other.x_min - 1,
                y_min: self.y_min,
                y_max: self.y_max,
                z_min: self.z_min,
                z_max: self.z_max,
            });
        }

        if self.x_max > other.x_max {
            remaining.push(Range {
                x_min: other.x_max + 1,
                x_max: self.x_max,
                y_min: self.y_min,
                y_max: self.y_max,
                z_min: self.z_min,
                z_max: self.z_max,
            });
        }

        if self.y_min < other.y_min {
            remaining.push(Range {
                x_min: self.x_min.max(other.x_min),
                x_max: self.x_max.min(other.x_max),
                y_min: self.y_min,
                y_max: other.y_min - 1,
                z_min: self.z_min,
                z_max: self.z_max,
            });
        }

        if self.y_max > other.y_max {
            remaining.push(Range {
                x_min: self.x_min.max(other.x_min),
                x_max: self.x_max.min(other.x_max),
                y_min: other.y_max + 1,
                y_max: self.y_max,
                z_min: self.z_min,
                z_max: self.z_max,
            });
        }

        if self.z_min < other.z_min {
            remaining.push(Range {
                x_min: self.x_min.max(other.x_min),
                x_max: self.x_max.min(other.x_max),
                y_min: self.y_min.max(other.y_min),
                y_max: self.y_max.min(other.y_max),
                z_min: self.z_min,
                z_max: other.z_min - 1,
            });
        }

        if self.z_max > other.z_max {
            remaining.push(Range {
                x_min: self.x_min.max(other.x_min),
                x_max: self.x_max.min(other.x_max),
                y_min: self.y_min.max(other.y_min),
                y_max: self.y_max.min(other.y_max),
                z_min: other.z_max + 1,
                z_max: self.z_max,
            });
        }

        remaining
    }

    fn num_points(&self) -> usize {
        let x_size = (self.x_max - self.x_min).abs() + 1;
        let y_size = (self.y_max - self.y_min).abs() + 1;
        let z_size = (self.z_max - self.z_min).abs() + 1;
        (x_size * y_size * z_size) as usize
    }
}

fn part2() {
    let input = std::fs::read_to_string("input").unwrap().trim().to_string();
    let mut cuboids: Vec<Range> = Vec::new();
    for (state, ranges) in input.lines().map(|l| l.split_once(" ").unwrap()) {
        let ranges: Vec<_> = ranges.trim().split(",").collect();
        let xs = ranges[0].chars().skip(2).collect::<String>();
        let xs = xs.split_once("..").unwrap();
        let (x_min, x_max): (i64, i64) = (parse_number(xs.0), parse_number(xs.1));
        
        let ys = ranges[1].chars().skip(2).collect::<String>();
        let ys = ys.split_once("..").unwrap();
        let (y_min, y_max): (i64, i64) = (parse_number(ys.0), parse_number(ys.1));

        let zs = ranges[2].chars().skip(2).collect::<String>();
        let zs = zs.split_once("..").unwrap();
        let (z_min, z_max): (i64, i64) = (parse_number(zs.0), parse_number(zs.1));
        
        let range = Range { x_min, x_max, y_min, y_max, z_min, z_max };
        if state == "on" {
            let mut ranges = vec![range];
            for cuboid in &cuboids {
                let mut new_range = Vec::new();
                for range in ranges {
                    if cuboid.overlaps(&range) {
                        new_range.extend(range.remove_overlap(cuboid));
                    } else {
                        new_range.push(range);
                    }
                }
                ranges = new_range;
            }
            cuboids.extend(ranges);
        } else {
            let mut remove = Vec::new();
            for i in 0..cuboids.len(){
                let cuboid = cuboids[i].clone();
                if cuboid.overlaps(&range) {
                    remove.push(i);
                    cuboids.extend(cuboid.remove_overlap(&range));
                }
            }
            for i in remove.into_iter().rev() {
                cuboids.remove(i);
            }
        }
    }

    let res: usize = cuboids.iter().map(Range::num_points).sum();
    println!("part2 {}", res);
}

fn main() {
    part1();
    part2();
}
