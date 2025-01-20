use utils::{get_string_from_file, parse_number};

#[derive(Debug, Default)]
struct Board {
    board: [[usize; 5]; 5],
    marks: [[bool; 5]; 5],
    won: bool,
}

impl Board {
    fn did_won(&mut self) -> bool {
        if self.won {
            return self.won;
        }

        for row in self.marks {
            if row.iter().all(|f| *f) {
                self.won = true;
                return self.won;
            }
        }
        let mut count = 0;
        for i in 0..5 {
            for row in self.marks {
                count += row[i] as usize;
            }
            if count == 5 {
                self.won = true;
                return self.won;
            }
            count = 0;
        }
        self.won
    }

    fn points(&self, winner_draw: usize) -> usize {
        let mut sum = 0;
        for (i, row) in self.board.iter().enumerate() {
            for (j, col) in row.iter().enumerate() {
                if !self.marks[i][j] {
                    sum += col;
                }
            }
        }

        sum * winner_draw
    }
}

fn part1() {
    let data = get_string_from_file("input");
    let mut split = data.split("\n\n");
    let draws: Vec<usize> = split
        .next()
        .unwrap()
        .trim_end()
        .split(",")
        .map(parse_number)
        .collect();

    let mut boards: Vec<Board> = Default::default();
    for blobs in split {
        let mut board: Board = Default::default();
        for (i, row) in blobs.split("\n").enumerate() {
            for (j, num) in row.split_whitespace().enumerate() {
                board.board[i][j] = parse_number(num);
                board.marks[i][j] = false;
            }
        }
        boards.push(board);
    }

    let mut winner = None;
    let mut curr_draw = 0;
    loop {
        for (board_index, cur_board) in boards.iter_mut().enumerate() {
            let board = cur_board.board;
            for (i, row) in board.iter().enumerate() {
                for (j, col) in row.iter().enumerate() {
                    if *col == draws[curr_draw] {
                        cur_board.marks[i][j] = true;
                    }
                }
            }

            if cur_board.did_won() {
                winner = Some(board_index);
                break;
            }
        }
        if winner.is_some() {
            break;
        }
        curr_draw += 1;
    }

    println!("Part1 {}", boards[winner.unwrap()].points(draws[curr_draw]));
}

fn part2() {
    let data = get_string_from_file("input");
    let mut split = data.split("\n\n");
    let draws: Vec<usize> = split
        .next()
        .unwrap()
        .trim_end()
        .split(",")
        .map(parse_number)
        .collect();

    let mut boards: Vec<Board> = Default::default();
    for blobs in split {
        let mut board: Board = Default::default();
        for (i, row) in blobs.split("\n").enumerate() {
            for (j, num) in row.split_whitespace().enumerate() {
                board.board[i][j] = parse_number(num);
                board.marks[i][j] = false;
            }
        }
        boards.push(board);
    }

    let mut last_winner = None;
    let mut last_winner_draw = None;
    let mut curr_draw = 0;

    while curr_draw != draws.len() {
        for (board_index, cur_board) in boards.iter_mut().enumerate(){
            if cur_board.won {
                continue;
            }

            let board = cur_board.board;
            for (i, row) in board.iter().enumerate() {
                for (j, col) in row.iter().enumerate() {
                    if *col == draws[curr_draw] {
                        cur_board.marks[i][j] = true;
                    }
                }
            }

            if cur_board.did_won() {
                last_winner = Some(board_index);
                last_winner_draw = Some(curr_draw);
            }
        }
        curr_draw += 1;
    }
    println!(
        "Part2 {}",
        boards[last_winner.unwrap()].points(draws[last_winner_draw.unwrap()])
    );
}

fn main() {
    part1();
    part2();
}
