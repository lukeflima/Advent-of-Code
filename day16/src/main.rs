use utils::parse_number;

fn to_binary(c: char) -> &'static str {
    match c {
        '0' => "0000",
        '1' => "0001",
        '2' => "0010",
        '3' => "0011",
        '4' => "0100",
        '5' => "0101",
        '6' => "0110",
        '7' => "0111",
        '8' => "1000",
        '9' => "1001",
        'A' => "1010",
        'B' => "1011",
        'C' => "1100",
        'D' => "1101",
        'E' => "1110",
        'F' => "1111",
        _ => "",
    }
}

#[derive(Debug)]
struct Packet {
    version: usize,
    type_id: usize,
    // size: usize,
}

fn parse(bits: &Vec<char>) -> Vec<Packet> {
    let mut packets: Vec<Packet> = Default::default();
    let mut i = 0_usize;
    while i < bits.len() - 6 {
        let version = usize::from_str_radix(&bits[i..i + 3].iter().collect::<String>(), 2).unwrap();
        i += 3;
        let type_id = usize::from_str_radix(&bits[i..i + 3].iter().collect::<String>(), 2).unwrap();
        i += 3;
        match type_id {
            4 => {
                while bits[i] == '1' {
                    i += 5;
                }
                i += 5;
            }
            _ => {
                if bits[i] == '1' {
                    i += 12;
                } else {
                    i += 16;
                }
            }
        };
        packets.push(Packet { version, type_id })
    }
    packets
}

fn part1() {
    let bits: Vec<char> = std::fs::read_to_string("input")
        .unwrap()
        .chars()
        .map(to_binary)
        .map(str::chars)
        .flatten()
        .collect();
    let packets = parse(&bits);
    // println!("{:?}", packets);
    let sum_versions: usize = packets.iter().map(|x| x.version).sum();
    println!("part1 {}", sum_versions);
}

fn part2() {}

fn main() {
    part1();
    part2();
}
