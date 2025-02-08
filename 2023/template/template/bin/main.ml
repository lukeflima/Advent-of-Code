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

let part1 input = input |> String.length |> Int.to_string
let part2 input = input |> String.length |> Int.to_string

let input = "sample.txt"
(* let input = "input.txt" *)

let () =
  let input = read_file input in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  