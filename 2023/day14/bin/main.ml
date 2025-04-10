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

let roll grid (di, dj) = 
  let height = List.length grid in
  let width = List.length (List.hd grid) in
  let get grid (i, j) = 
    let index = i * height + j in
    if i<0 || i >= height || j<0 || j >= width then '#'
    else Array.get grid index
  in
  let rec roll' grid (i, j) reset =
    if j == width then roll' grid (i + 1, 0) reset
    else if i == height then grid
    else
    let cell = get grid (i, j) in
    match cell with
    | 'O' -> 
      let (ni, nj) = (i + di, j + dj) in
      let next = get grid (ni, nj) in
      if next != '.' then 
        if Option.is_some reset then roll' grid (Option.get reset) None
        else roll' grid (i, j + 1) reset
      else
        begin
        let index = i * height + j in
        let index_nj = ni * height + nj in
        Array.set grid index '.';
        Array.set grid index_nj 'O';
        roll' grid (ni, nj) (if Option.is_some reset then reset else if di == 0 then Some (i, 0) else Some (0, j))
        end
    | _ -> roll' grid (i, j + 1) reset
  in
  let list = roll' (grid |> List.flatten |> List.to_seq |> Array.of_seq) (0, 0) None |> Array.to_list in
  let _, _, grid = List.fold_left (fun (i, cur ,acc) c -> 
    if i + 1 == height then (0, [], acc @ [cur @ [c]])
    else (succ i, cur @ [c], acc)
  ) (0, [], []) list in
  grid

let part1 input =
  let grid = String.split_on_char '\n' input |> List.map (fun s -> String.to_seq s |> List.of_seq) in
  let roll_north grid = roll grid (-1, 0) in
  let calculate_load grid = 
    let height = List.length grid in
    List.fold_left (fun (acc, i) row -> 
      let num_round_rocks = List.fold_left (fun acc c -> if c == 'O' then succ acc else acc) 0 row in
      let load = num_round_rocks * (height - i) in
      (acc + load, succ i)
    ) (0, 0) grid |> fst
  in
  let grid = roll_north grid in
  calculate_load grid |> Int.to_string
let part2 input = 
  let grid = String.split_on_char '\n' input |> List.map (fun s -> String.to_seq s |> List.of_seq) in
  let calculate_load grid = 
    let height = List.length grid in
    List.fold_left (fun (acc, i) row -> 
      let num_round_rocks = List.fold_left (fun acc c -> if c == 'O' then succ acc else acc) 0 row in
      let load = num_round_rocks * (height - i) in
      (acc + load, succ i)
    ) (0, 0) grid |> fst
  in
  let keep_rolling grid =
    let get_string grid = List.flatten grid |> List.to_seq |> String.of_seq in
    let ht = Hashtbl.create 100 in
    let list = ref [] in
    let rec keep_rolling' grid =
      let str = get_string grid in
      if Hashtbl.mem ht str then (List.map calculate_load !list, Hashtbl.find ht str)
      else 
        begin
        Hashtbl.add ht str (List.length !list);
        list := !list @ [grid];
        let grid = roll grid (-1,  0) in
        let grid = roll grid ( 0, -1) in
        let grid = roll grid ( 1,  0) in
        let grid = roll grid ( 0,  1) in
        keep_rolling' grid
        end
    in
    keep_rolling' grid
  in
  let list, loop_start = keep_rolling grid in
  let loop_size = List.length list - loop_start in
  let index = loop_start + Int.rem (1000000000 - loop_start) loop_size in
  List.nth list index |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  