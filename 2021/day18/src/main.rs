use itertools::Itertools;

#[derive(Debug, Clone, PartialEq)]
enum Snail {
   Num(i64),
   Pair(Box<Snail>, Box<Snail>)
}

fn _snail_to_string(snail: &mut Snail) -> String {
    let mut str = String::new();
    match snail {
        Snail::Pair(left, right ) => {
            str += "[";
            str += &_snail_to_string(left);
            str += ",";
            str += &_snail_to_string(right);
            str += "]";
        },
        Snail::Num(n) => {
            str += &n.to_string();
        }
    }
    return str;
}   

fn parse(s: Vec<char>) -> (Snail, usize) {
    let mut read = 0;
    let mut res = Snail::Num(0);
    for c in &s {
        match *c {
            '[' => {
                read += 1;
                let (snail_left, n) = parse(s[read..].to_vec());
                read += n;
                let (snail_right, n) = parse(s[read..].to_vec());
                read += n;
                res = Snail::Pair(Box::new(snail_left), Box::new(snail_right));
                break
            },
            '0'..='9' => {
                return (Snail::Num(c.to_digit(10).unwrap() as i64), read + 1);
            },
            _ => {
                read += 1;
            }
        }
    }
    return (res, read);
}

fn propagate(snail: &mut Snail, value: i64, is_left: bool) {
    if is_left {
        if let Snail::Pair(left, _) = snail {
            if let Snail::Num(l) = **left {
                **left = Snail::Num(l + value);
            } else {
                propagate(left, value, is_left);
            }
        } 
    } else {
        if let Snail::Pair(_, right) = snail {
            if let Snail::Num(r) = **right {
                **right = Snail::Num(r + value);
            } else {
                propagate(right, value, is_left);
            }
        } 
    }
}

fn both_negatives(snail: &Snail) -> bool {
    if let Snail::Pair(l, r ) = snail {
        if let (Snail::Num(-1), Snail::Num(-1)) = (*l.clone(), *r.clone()) {
            return true;
        }
    }
    return false;
}
fn one_negative(snail: &Snail) -> bool {
    if let Snail::Pair(l, r ) = snail {
        if let (Snail::Num(-1), Snail::Num(_)) = (*l.clone(), *r.clone()) {
            return true;
        }
        if let (Snail::Num(_), Snail::Num(-1)) = (*l.clone(), *r.clone()) {
            return true;
        }
    }
    return false;
}

fn explode(snail: &mut Snail, depth: usize) -> Option<Snail> {
    let mut is_pair_number = true;
    if let Snail::Pair(left, right ) = snail {
        if let Snail::Num(_) = **left {}
        else {
            is_pair_number = false;
            let res = explode(&mut *left, depth + 1);
            if res.is_some() && both_negatives(&res.clone().unwrap()) {
                return res;
            }
            if let Some(Snail::Pair(l, r)) = &res {
                if let Snail::Num(r) = **r {
                    if r >= 0 {
                        if !one_negative(&res.clone().unwrap()) {
                            **left = Snail::Num(0);
                        }
                        if let Snail::Num(rv) = **right {
                            **right = Snail::Num(rv + r);
                        } else {
                            propagate(right, r, true);
                        }
                    }
                    return Some(Snail::Pair(l.clone(), Box::new(Snail::Num(-1))));
                }
            }
        }
        if let Snail::Num(_) = **right {}
        else {
            is_pair_number = false;
            let res = explode(right, depth + 1);
            if res.is_some() && both_negatives(&res.clone().unwrap()) {
                return res
            }
            if let Some(Snail::Pair(l, r)) = &res {
                if let Snail::Num(l) = **l {
                    if l >= 0 {
                        if !one_negative(&res.clone().unwrap()) {
                            **right = Snail::Num(0);
                        }
                        if let Snail::Num(lv) = **left {
                            **left = Snail::Num(lv + l);
                        } else {
                            propagate(left, l, false);
                        }
                    }
                    return Some(Snail::Pair(Box::new(Snail::Num(-1)), r.clone()));
                }
            }
        }
        
        if is_pair_number && depth >= 4 {
            return Some(snail.clone());
        }
    }
    return None;
}

fn split(snail: &mut Snail) -> bool{
    if let Snail::Pair(left, right) = snail {
        if let Snail::Num(l) = **left {
            if l >= 10 {
                let half = (l as f64)/2.0;
                **left = Snail::Pair(
                    Box::new(Snail::Num(half.floor() as i64)), 
                    Box::new(Snail::Num(half.ceil() as i64))
                );
                return true;
            }
        }
        else {
            if split(left) {
                return true
            };
        }
        if let Snail::Num(r) = **right {
            if r >= 10 {
                let half = (r as f64)/2.0;
                **right = Snail::Pair(
                    Box::new(Snail::Num(half.floor() as i64)), 
                    Box::new(Snail::Num(half.ceil() as i64))
                );
                return true;
            }

        }
        else {
            if split(right) {
                return true
            };
        }
    }
    return false;
}

fn adjust(snail: &mut Snail) {
    loop {
        if explode(snail, 0usize).is_some() {
            // dbg!("Exploded!");
        }
        else if split(snail) {
            // dbg!("splited");
        }
        else { 
            // dbg!("end adjust");
            return 
        }
    }
}

fn magnitude(snail: &Snail) -> i64 {
    match snail {
        Snail::Num(n) => *n,
        Snail::Pair(left, right) => 3 * magnitude(&left) + 2 * magnitude(&right),
    }
}

fn part1() {
    let input = std::fs::read_to_string("input").unwrap();
    let mut homework: Vec<_> = input.split("\n").map(|c| c.chars().collect()).map(parse).map(|v| v.0).collect();
    let mut hw_iter = homework.iter_mut();
    let mut snail = hw_iter.next().unwrap().clone();
    for hw in hw_iter {
        snail = Snail::Pair(Box::new(snail), Box::new(hw.clone()));
        adjust(&mut snail);
    }
    println!("part1 {}", magnitude(&snail));
}

fn part2() {
    let input = std::fs::read_to_string("input").unwrap();
    let homework: Vec<_> = input.split("\n").map(|c| c.chars().collect()).map(parse).map(|v| v.0).collect();
    let mut best = 0;
    for hw in homework.iter().permutations(2) {
        let (l, r) = (hw[0], hw[1]);
        let mut snail = Snail::Pair(Box::new(l.clone()), Box::new(r.clone()));
        adjust(&mut snail);
        best = best.max(magnitude(&snail));
    }

    println!("part2 {}", best);
}

fn main() {
    part1();
    part2();
}
