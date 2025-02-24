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

let split_whitespace string =           String.split_on_char ' ' string  
  |> List.fold_left (fun acc s -> acc @ String.split_on_char '\n' s) []
  |> List.fold_left (fun acc s -> acc @ String.split_on_char '\r' s) []
  |> List.fold_left (fun acc s -> acc @ String.split_on_char '\t' s) []
  |> List.filter    (fun     s -> s <> "")

let part1 input = 
  let lines = String.split_on_char '\n' input in
  let times = List.nth lines 0 |> split_whitespace |> List.tl |> List.map int_of_string in
  let dists = List.nth lines 1 |> split_whitespace |> List.tl |> List.map int_of_string in
  let calc_ways acc t d = 
    let rec calc_ways' t' ways = 
      if t' == 0 then ways
      else if (t - t') * t' > d then
        calc_ways' (t' - 1) (ways + 1)
      else
        calc_ways' (t' - 1) ways
    in
    let ways = calc_ways' (t - 1) 0 in
    acc * ways
  in
  List.fold_left2 calc_ways 1 times dists |> Int.to_string
let part2 input = 
  let lines = String.split_on_char '\n' input in
  let time = List.nth lines 0 |> split_whitespace |> List.tl |> List.fold_left String.cat "" |> int_of_string in
  let dist = List.nth lines 1 |> split_whitespace |> List.tl |> List.fold_left String.cat "" |> int_of_string in
  let calc_ways t d = 
    let rec calc_ways' t' dir = 
      if (t - t') * t' > d then
        t'
      else
        calc_ways' (dir t' 1) dir
    in
    let start = calc_ways' 0 ( + ) in
    let finish = calc_ways' (t - 1) ( - ) in
    finish - start + 1
  in
  calc_ways time dist |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  