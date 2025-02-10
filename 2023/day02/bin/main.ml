let read_file filename =
  let ic = open_in filename in
  let rec read_lines acc =
    try
      let line = input_line ic in
      match acc with
      | "" -> read_lines line
      | _ -> read_lines (acc ^ "\n" ^ line)
    with End_of_file ->
      close_in ic;
      acc
  in
  read_lines ""

let get_games input =
  let lines = String.split_on_char '\n' input in
  let process line = 
    let blocks = String.split_on_char ':' line in
    let game_id = int_of_string (List.nth(List.nth blocks 0 |> String.split_on_char ' ') 1) in 
    let tokens = String.split_on_char ' ' (List.nth blocks 1 |> String.trim) in
    let add_to_game game name count = 
      let name = if String.starts_with ~prefix:"blue" name then 
        "blue"
      else if String.starts_with ~prefix:"red" name then 
        "red"
      else 
        "green" 
      in
      let prev = Option.value ~default:0 (Hashtbl.find_opt game name) in
      Hashtbl.replace game name (Int.max prev count)
    in
    let rec get_game game tokens = 
      match tokens with
      | [] -> game
      | _::[] -> failwith "tf"
      | count :: name :: c ->
        begin
          add_to_game game name (int_of_string count);
          get_game game c
        end
    in
    let game = get_game (Hashtbl.create 0) tokens in
    (game_id, game)
  in
  List.map process lines

let part1 input = 
  
  let possible sum game = 
    let game_id, game = game in
    let blue = Option.value ~default:0 (Hashtbl.find_opt game "blue") in
    let red = Option.value ~default:0 (Hashtbl.find_opt game "red") in
    let green = Option.value ~default:0 (Hashtbl.find_opt game "green") in
    if red <= 12 && green <= 13 && blue <= 14 then
      sum + game_id
    else
      sum
  in
  let games = get_games input in
  List.fold_left possible 0 games |> Int.to_string  

let part2 input = 
  let power sum game = 
    let _, game = game in
    let blue = Option.value ~default:0 (Hashtbl.find_opt game "blue") in
    let red = Option.value ~default:0 (Hashtbl.find_opt game "red") in
    let green = Option.value ~default:0 (Hashtbl.find_opt game "green") in
    sum + (blue * red * green)
  in
  let games = get_games input in
  List.fold_left power 0 games |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  