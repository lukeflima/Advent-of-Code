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
  

(* let print_list l = 
  print_string "[";
  List.iter (fun x -> print_int x; print_string "; ") l;
  print_endline "]" *)

let part1 input = 
  let lines = String.split_on_char '\n' input in
  let seqs = List.map (fun line -> line |> String.split_on_char ' ' |> List.map int_of_string) lines  in
  let find_steps seq = 
    let rec get_difs seq = 
      match seq with
      | [x; y] -> [y - x]
      | x::y::xs -> (y - x) :: get_difs (y::xs)
      | _ -> seq
    in
    let rec find_step_and_depth' seq steps = 
      
      let difs = get_difs seq in
      if List.for_all (fun x -> x == 0) difs then steps
      else find_step_and_depth' difs (steps @ [difs|> List.rev |> List.hd])
    in
    find_step_and_depth' seq [seq |> List.rev |> List.hd]
  in
  let steps = List.map find_steps seqs in
  let incr = List.map (fun s -> List.fold_left ( + ) 0 s) steps in
  List.fold_left ( + ) 0 incr |> Int.to_string

let part2 input = 
  let lines = String.split_on_char '\n' input in
  let seqs = List.map (fun line -> line |> String.split_on_char ' ' |> List.map int_of_string) lines  in
  let find_steps seq = 
    let rec get_difs seq = 
      match seq with
      | [x; y] -> [y - x]
      | x::y::xs -> (y - x) :: get_difs (y::xs)
      | _ -> seq
    in
    let rec find_step_and_depth' seq steps = 
      
      let difs = get_difs seq in
      if List.for_all (fun x -> x == 0) difs then steps
      else find_step_and_depth' difs (steps @ [List.hd difs])
    in
    find_step_and_depth' seq [List.hd seq] |> List.rev
  in
  let steps = List.map find_steps seqs in
  let incr = List.map (fun s -> List.fold_left ( fun acc x -> x - acc ) (List.hd s) (List.tl s)) steps in
  List.fold_left ( + ) 0 incr |> Int.to_string


(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  