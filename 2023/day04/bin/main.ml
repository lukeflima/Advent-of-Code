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


let get_numbers line = 
  let line = List.nth (String.split_on_char ':' line) 1 |> String.trim in
  
  let to_list lst = 
    let lst = String.split_on_char ' ' (String.trim lst) in
    let lst = List.filter (fun s -> not (String.equal s "")) lst in
    List.map int_of_string lst 
in
  let lsts = List.map to_list (String.split_on_char '|' line) in
  List.nth lsts 0,List.nth lsts 1

let part1 input = 
  let lines = String.split_on_char '\n' input in
  let boards = List.map get_numbers lines in
  let calc_poits (winning, board) =
    let is_winning n = Option.is_some (List.find_opt (fun a -> a == n) winning) in
    let winning = List.length (List.filter is_winning board) in
    if winning == 0 then 0
    else Int.of_float (2. ** Int.to_float (winning - 1))
  in
  let points = List.map calc_poits boards in 
  List.fold_left (+) 0 points |> Int.to_string
let part2 input = 
  let lines = String.split_on_char '\n' input in
  let boards = List.map get_numbers lines in
  let calc_poits (winning, board) =
    let is_winning n = Option.is_some (List.find_opt (fun a -> a == n) winning) in
    List.length (List.filter is_winning board) 
  in
  let points = List.map calc_poits boards in 
  let boards_length = List.length boards in
  let calc_boards boards_count = 
    let rec calc boards_count i sum = 
      match boards_count with
      | [] -> sum
      | board :: rest -> 
        let point = List.nth points i in
        let rest = List.mapi (fun j n -> if j < point then n + board else n) rest in
        calc rest (i+1) (sum + board)
    in
    calc boards_count 0 0
  in
  calc_boards (List.init boards_length (fun _ -> 1)) |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  