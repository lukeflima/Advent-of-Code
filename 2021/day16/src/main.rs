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

fn parse_part1(bits: &[char]) -> usize {
    let mut sum = 0_usize;
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
        sum += version;
    }
    sum
}

fn part1() {
    let bits: Vec<char> = std::fs::read_to_string("input")
        .unwrap()
        .chars()
        .map(to_binary)
        .map(str::chars)
        .flatten()
        .collect();
    let sum_versions = parse_part1(&bits);
    println!("part1 {}", sum_versions);
}

#[derive(Debug)]
enum PacketType {
    Sum,
    Product,
    Minimun,
    Maximun,
    Literal,
    GreaterThen,
    LesserThen,
    EqualThan,
    Unknown,
}

impl Default for PacketType {
    fn default() -> Self {
        Self::Unknown
    }
}
impl TryFrom<usize> for PacketType {
    type Error = ();

    fn try_from(v: usize) -> Result<Self, Self::Error> {
        match v {
            0 => Ok(PacketType::Sum),
            1 => Ok(PacketType::Product),
            2 => Ok(PacketType::Minimun),
            3 => Ok(PacketType::Maximun),
            4 => Ok(PacketType::Literal),
            5 => Ok(PacketType::GreaterThen),
            6 => Ok(PacketType::LesserThen),
            7 => Ok(PacketType::EqualThan),
            _ => Ok(PacketType::Unknown),
        }
    }
}

#[derive(Debug, Default)]
struct Packet {
    #[allow(dead_code)]
    version: usize,
    type_id: PacketType,
    value: usize,
    bit_size: usize,
    subpacket: Vec<Packet>,
}

fn parse_packet(bits: &[char]) -> Packet {
    let mut count = 0_usize;

    let mut packet = Packet {
        version: usize::from_str_radix(&bits[count..count + 3].iter().collect::<String>(), 2)
            .unwrap(),
        ..Default::default()
    };
    count += 3;
    packet.type_id = usize::from_str_radix(&bits[count..count + 3].iter().collect::<String>(), 2)
        .unwrap()
        .try_into()
        .unwrap();
    count += 3;
    match packet.type_id {
        PacketType::Literal => {
            let mut value = String::default();
            while bits[count] == '1' {
                value += &bits[count + 1..count + 5].iter().collect::<String>();
                count += 5;
            }
            value += &bits[count + 1..count + 5].iter().collect::<String>();
            count += 5;
            let value = usize::from_str_radix(&value, 2).unwrap();
            packet.value = value;
        }
        _ => {
            if bits[count] == '1' {
                let size = bits[count + 1..count + 12].iter().collect::<String>();
                let size = usize::from_str_radix(&size, 2).unwrap();
                count += 12;
                for _ in 0..size {
                    let subpacket = parse_packet(&bits[count..]);
                    count += subpacket.bit_size;
                    packet.subpacket.push(subpacket);
                }
            } else {
                let size = bits[count + 1..count + 16].iter().collect::<String>();
                let mut size = i64::from_str_radix(&size, 2).unwrap();
                count += 16;
                while size > 0 {
                    let subpacket = parse_packet(&bits[count..]);
                    count += subpacket.bit_size;
                    size -= subpacket.bit_size as i64;
                    packet.subpacket.push(subpacket);
                }
            }
        }
    };
    packet.bit_size = count;
    packet
}

fn solve_packet(packet: &Packet) -> Packet {
    Packet {
        value: match &packet.type_id {
            PacketType::Sum => packet
                .subpacket
                .iter()
                .map(solve_packet)
                .map(|p| p.value)
                .sum(),
            PacketType::Product => packet
                .subpacket
                .iter()
                .map(solve_packet)
                .map(|p| p.value)
                .product(),
            PacketType::Minimun => packet
                .subpacket
                .iter()
                .map(solve_packet)
                .map(|p| p.value)
                .min()
                .unwrap(),
            PacketType::Maximun => packet
                .subpacket
                .iter()
                .map(solve_packet)
                .map(|p| p.value)
                .max()
                .unwrap(),
            PacketType::Literal => packet.value,
            PacketType::GreaterThen => {
                let [x, y]: [usize; 2] = packet
                    .subpacket
                    .iter()
                    .map(solve_packet)
                    .map(|p| p.value)
                    .collect::<Vec<usize>>()
                    .try_into()
                    .unwrap();
                if x > y {
                    1
                } else {
                    0
                }
            }
            PacketType::LesserThen => {
                let [x, y]: [usize; 2] = packet
                    .subpacket
                    .iter()
                    .map(solve_packet)
                    .map(|p| p.value)
                    .collect::<Vec<usize>>()
                    .try_into()
                    .unwrap();
                if x < y {
                    1
                } else {
                    0
                }
            }
            PacketType::EqualThan => {
                let [x, y]: [usize; 2] = packet
                    .subpacket
                    .iter()
                    .map(solve_packet)
                    .map(|p| p.value)
                    .collect::<Vec<usize>>()
                    .try_into()
                    .unwrap();
                if x == y {
                    1
                } else {
                    0
                }
            }
            PacketType::Unknown => unreachable!(),
        },
        type_id: PacketType::Literal,
        ..Default::default()
    }
}

fn part2() {
    let bits: Vec<char> = std::fs::read_to_string("input")
        .unwrap()
        .chars()
        .map(to_binary)
        .map(str::chars)
        .flatten()
        .collect();
    let packet = parse_packet(&bits);
    let res = solve_packet(&packet);
    println!("part2 {}", res.value);
}

fn main() {
    part1();
    part2();
}
