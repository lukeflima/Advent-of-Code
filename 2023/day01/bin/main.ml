let read_file filename =
  let ic = open_in filename in
  let rec read_lines acc =
    try
      let line = input_line ic in
      if acc == "" then
        read_lines (line)
      else
        read_lines (acc ^ "\n" ^ line)
    with End_of_file ->
      close_in ic;
      acc
  in
  read_lines ""

let part1 input = 
  let lines = String.split_on_char '\n' input in
  let lines = List.map (fun line -> line |> String.to_seq |> List.of_seq) lines in
  let rec first_digit list = 
    match list with
      [] -> 0 
      | head :: tail -> 
        if head >= '0' && head <= '9' then
          int_of_char head - int_of_char '0'
        else
          first_digit tail
  in
  let get_num input = 
    let first = first_digit input in
    let second = first_digit (List.rev input) in
    first * 10 + second 
  in
  let nums = List.map get_num lines in
  List.fold_left (+) 0 nums |> Int.to_string
let part2 input = 
  let lines = String.split_on_char '\n' input in
  let rec digits str acc = 
      match str with
      "" -> acc
      | str ->
      let head = String.get str 0  in
      let rest = String.sub str 1 (String.length str - 1) in
      if head >= '0' && head <= '9' then
        digits rest (acc @ [int_of_char head - int_of_char '0'])
      else if String.starts_with ~prefix:"zero" str then
        digits rest (acc @ [0])
      else if String.starts_with ~prefix:"one" str then
        digits rest (acc @ [1])
      else if String.starts_with ~prefix:"two" str then
        digits rest (acc @ [2])
      else if String.starts_with ~prefix:"three" str then
        digits rest (acc @ [3])
      else if String.starts_with ~prefix:"four" str then
        digits rest (acc @ [4])
      else if String.starts_with ~prefix:"five" str then
        digits rest (acc @ [5])
      else if String.starts_with ~prefix:"six" str then
        digits rest (acc @ [6])
      else if String.starts_with ~prefix:"seven" str then
        digits rest (acc @ [7])
      else if String.starts_with ~prefix:"eight" str then
        digits rest (acc @ [8])
      else if String.starts_with ~prefix:"nine" str then
        digits rest (acc @ [9])
      else
        digits rest acc
  in
  let get_num digits = 
    let rec first_last list = match list with
      | [] -> failwith "too bad"
      | [e] -> (e, e)
      | [e1;e2] -> (e1,e2) 
      | e1 :: _ :: r -> first_last (e1::r)
    in
    let (first, second) = first_last digits in
      first * 10 + second
  in
  let nums = List.map (fun d ->  digits d [] |>get_num) lines in
  List.fold_left (+) 0 nums |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  