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

let parse_numbers str_list =
  let rec next_number str_list num nums pos =
    match str_list with
    | [] -> nums
    | (i, j, a) :: rest -> 
      if a >= '0' && a <= '9' then
        next_number rest (num * 10 + int_of_char a - int_of_char '0') nums (pos @ [(i,j)])
      else
        if num != 0 then 
          next_number rest 0 (nums @ [(pos, num)]) []
        else
          next_number rest 0 nums []
  in
  next_number str_list 0 [] []

let line_to_row i line = 
  let list = line |> String.to_seqi |> List.of_seq in
  List.map (fun (j, c) -> i, j, c) list

let neighbours = [(-1, -1); (-1, 0); (-1, 1); (0, -1); (0, 1); (1, -1); (1, 0); (1, 1)]

let part1 input = 
  let lines = String.split_on_char '\n' input in
  let grid = List.mapi line_to_row lines |> List.flatten in
  let grid_len = List.length grid in
  let cols = List.length lines in
  let nums = parse_numbers grid in
  let is_part (pos, n) = 
    let part acc (i, j) = 
      if acc then acc
      else
      let check acc2 (di, dj) =
        if acc2 then acc2
        else
          let index = (i + di) * cols + j + dj in
          if index > 0 && index < grid_len then
            let _, _, c = List.nth grid index  in
            c != '.' && (c < '0' || c > '9')
          else acc2
        in
      List.fold_left check false neighbours
    in
    if List.fold_left part false pos then
      n
    else 0    
  in
  let res = List.map is_part nums in
  List.fold_left (+) 0 res |> Int.to_string

let get_gears grid =
  let rec gears grid p =
    match grid with
    | [] -> p
    | (i, j, '*') :: rest -> gears rest p @ [(i, j)]
    | _ :: rest -> gears rest p
  in
  gears grid []
  
module PosSet = Set.Make(Int)
let part2 input = 
  let lines = String.split_on_char '\n' input in
  let grid = List.mapi line_to_row lines |> List.flatten in
  let nums = parse_numbers grid in
  let pos_ht = Hashtbl.create 0 in
  let add_pos (pos, n) = List.iter (fun i -> Hashtbl.add pos_ht i n) pos in
  List.iter add_pos nums;
  let gears = get_gears grid in
  let gear_power (i, j) = 
    let rec contruct_set neighbours set =
      match neighbours with
      | [] -> set
      | (di, dj)::rest -> 
        let index = (i + di, j + dj) in
        match Hashtbl.find_opt pos_ht index with
        | Some n -> contruct_set rest (PosSet.add n set)
        | None -> contruct_set rest set
    in
    let ns = contruct_set neighbours PosSet.empty in
    if PosSet.cardinal ns == 2 then
      PosSet.fold ( * ) ns 1
    else 0 
  in
  let res = List.map gear_power gears in
  List.fold_left (+) 0 res |> Int.to_string


(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  