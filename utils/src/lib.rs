use std::io::{prelude::*, BufReader};
use std::str::FromStr;

pub fn parse_number<T>(str: &str) -> T
where
    T: FromStr,
{
    str.trim()
        .parse::<T>()
        .unwrap_or_else(|_| panic!("wrong input `{}`", str))
}

pub fn get_lines_from_file(filename: &str) -> std::io::Lines<BufReader<std::fs::File>> {
    let file = std::fs::File::open(filename).unwrap();
    let reader = BufReader::new(file);
    reader.lines()
}

pub fn get_string_from_file(filename: &str) -> String {
    let mut file = std::fs::File::open(filename).unwrap();
    let mut buf: String = String::new();
    file.read_to_string(&mut buf).unwrap();
    buf
}

pub fn get_sign<T: Ord + Default + From<i64>>(number: T) -> T {
    if number.gt(&T::default()) {
        T::from(1)
    } else {
        T::from(-1)
    }
}

pub fn get_sign_or_zero<T: Ord + Default + From<i64>>(number: T) -> T {
    if number.gt(&T::default()) {
        T::from(1)
    } else if number.eq(&T::default()) {
        T::default()
    } else {
        T::from(-1)
    }
}
