use cached::proc_macro::cached;
use utils::parse_number;

fn part1() {
    let input = std::fs::read_to_string("input").unwrap().trim().to_string();
    let mut players: Vec<usize> = input.split("\n").map(|a| parse_number(a.split(": ").last().unwrap())).collect();
    let mut players_score: Vec<usize> = vec![0; players.len()];
    let roll_dice = |dice: &mut usize| -> usize {
        *dice += 1;
        *dice - 1
    };
    let mut dice = 1usize;
    let mut player_turn = 0;
    let mut dice_rolls = 0usize;
    loop {
        let mut moves = 0;
        for _ in 0..3 {
            moves += roll_dice(&mut dice);
            dice_rolls += 1;
        }
        players[player_turn] = (players[player_turn] + moves - 1) % 10 + 1;
        players_score[player_turn] += players[player_turn];
        if players_score[player_turn] >= 1000 {
            break;
        }
        player_turn = (player_turn + 1) % players.len();
    }
    player_turn = (player_turn + 1) % players.len();
    let res = dice_rolls * players_score[player_turn];
    println!("part1 {}", res);
}

fn add_tuples(p1: (usize, usize), p2: (usize, usize)) -> (usize, usize) {
    let (x1, y1) = p1;
    let (x2, y2) = p2;
    (x1 + x2, y1 + y2)
}

#[cached(
    key = "String",
    convert = r##"{ format!("{moves},{cur_dice_roll},{player_turn},{p1_pos},{p2_pos},{p1_score},{p2_score}") }"##
)]
fn play(moves: usize, cur_dice_roll: usize, player_turn: usize, p1_pos: usize, p2_pos: usize, p1_score: usize, p2_score: usize) -> (usize, usize) {
    let mut wins = (0, 0);
    if cur_dice_roll < 3 {
        wins = add_tuples(wins, play(moves + 1, cur_dice_roll + 1, player_turn, p1_pos, p2_pos, p1_score, p2_score));
        wins = add_tuples(wins, play(moves + 2, cur_dice_roll + 1, player_turn, p1_pos, p2_pos, p1_score, p2_score));
        wins = add_tuples(wins, play(moves + 3, cur_dice_roll + 1, player_turn, p1_pos, p2_pos, p1_score, p2_score));
    } else {
        let (player_pos, player_score) = if player_turn == 0 {
            (p1_pos, p1_score)
        } else {
            (p2_pos, p2_score)
        };
        let next_pos = (player_pos + moves - 1) % 10 + 1;
        let next_score = player_score + next_pos;
        if next_score >= 21 {
            if player_turn == 0 {
                return (wins.0 + 1, wins.1);
            }else {
                return (wins.0, wins.1 + 1);
            }    
        } else {
            let next_player = (player_turn + 1) % 2;
            if player_turn == 0 {
                wins = add_tuples(wins, play(0, 0, next_player, next_pos, p2_pos, next_score, p2_score));
            } else {
                wins = add_tuples(wins, play(0, 0, next_player, p1_pos, next_pos, p1_score, next_score));
            };
           
        }
    }
    wins
}

fn part2() {
    let input = std::fs::read_to_string("input").unwrap().trim().to_string();
    let players: Vec<usize> = input.split("\n").map(|a| parse_number(a.split(": ").last().unwrap())).collect();
    let wins= play(0, 0, 0, players[0], players[1], 0, 0);
    let most_wins: usize = std::cmp::max(wins.0, wins.1);
    println!("part2 {}", most_wins);
}

fn main() {
    part1();
    part2();
}
