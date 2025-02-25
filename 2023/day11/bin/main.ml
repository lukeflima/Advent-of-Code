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

let rec transpose list = match list with
  | []             -> []
  | []   :: xss    -> transpose xss
  | (x::xs) :: xss ->
      (x :: List.map List.hd xss) :: transpose (xs :: List.map List.tl xss)

let compare_point a b =
  if (fst a) = (fst b) then (snd a) - (snd b)
  else (fst a) - (fst b)

module PointSet = Set.Make(struct
  type t = int * int
  let compare = compare_point
end)

let part1 input = 
  let lines = String.split_on_char '\n' input in
  let grid = List.map (fun line -> String.to_seq line |> List.of_seq) lines in
  let empty_rows = List.fold_left (fun (rows, i) row -> if List.for_all (fun c -> c == '.') row then (rows @ [i], i + 1) else (rows, i + 1) ) ([], 0) grid |> fst in
  let empty_cols = List.fold_left (fun (cols, i) col -> if List.for_all (fun c -> c == '.') col then (cols @ [i], i + 1) else (cols, i + 1) ) ([], 0) (transpose grid) |> fst in
  let grid, _, _ = List.fold_left ( fun (s, i, r) row ->
    let s, _, _ = List.fold_left ( fun (s', j, c) cell ->
      let j' = if List.mem c empty_cols then j + 2 else j + 1 in
      if cell == '#' then (PointSet.add (i, j) s', j', c + 1) else (s', j', c + 1)
    ) (s, 0, 0) row  in
    let i = if List.mem r empty_rows then i + 2 else i + 1 in
    (s, i, r + 1)
  ) (PointSet.empty, 0, 0) grid in
  let grid = PointSet.to_list grid in
  let get_pair_dist grid =
    let rec get_pait_dist' grid dists =
      match grid with
      | [] -> dists
      | (i, j) :: rest ->
        let dists = List.fold_left ( fun dists' (i', j') ->
          let dist = abs (i - i') + abs (j - j') in
          dist + dists'
        ) dists rest in
        get_pait_dist' rest dists
    in
    get_pait_dist' grid 0
  in
  get_pair_dist grid |> Int.to_string
  
let part2 input = 
  let lines = String.split_on_char '\n' input in
  let grid = List.map (fun line -> String.to_seq line |> List.of_seq) lines in
  let empty_rows = List.fold_left (fun (rows, i) row -> if List.for_all (fun c -> c == '.') row then (rows @ [i], i + 1) else (rows, i + 1) ) ([], 0) grid |> fst in
  let empty_cols = List.fold_left (fun (cols, i) col -> if List.for_all (fun c -> c == '.') col then (cols @ [i], i + 1) else (cols, i + 1) ) ([], 0) (transpose grid) |> fst in
  let empty_growth = 1000000 in
  let grid, _, _ = List.fold_left ( fun (s, i, r) row ->
    let s, _, _ = List.fold_left ( fun (s', j, c) cell ->
      let j' = if List.mem c empty_cols then j + empty_growth else j + 1 in
      if cell == '#' then (PointSet.add (i, j) s', j', c + 1) else (s', j', c + 1)
    ) (s, 0, 0) row  in
    let i = if List.mem r empty_rows then i + empty_growth else i + 1 in
    (s, i, r + 1)
  ) (PointSet.empty, 0, 0) grid in
  let grid = PointSet.to_list grid in
  let get_pair_dist grid =
    let rec get_pait_dist' grid dists =
      match grid with
      | [] -> dists
      | (i, j) :: rest ->
        let dists = List.fold_left ( fun dists' (i', j') ->
          let dist = abs (i - i') + abs (j - j') in
          dist + dists'
        ) dists rest in
        get_pait_dist' rest dists
    in
    get_pait_dist' grid 0
  in
  get_pair_dist grid |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  