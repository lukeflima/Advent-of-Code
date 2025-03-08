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

type dir = 
  | Up
  | Down
  | Right
  | Left

let next_pos_dir (i, j) dir =
  match dir with
  | Up    -> (i - 1, j), dir
  | Down  -> (i + 1, j), dir
  | Right -> (i, j + 1), dir
  | Left  -> (i, j - 1), dir

let reflect dir pipe =
  match pipe, dir with
  |  '/', Up    -> Right
  |  '/', Down  -> Left
  |  '/', Right -> Up
  |  '/', Left  -> Down
  | '\\', Up    -> Left
  | '\\', Down  -> Right
  | '\\', Right -> Down
  | '\\', Left  -> Up
  | _           -> dir

let compare_point (ax, ay) (bx, by) =
  if ax == bx then ay - by
  else ax - bx

module PointSet = Set.Make(struct
  type t = int * int
  let compare = compare_point
end)

let compare_point_dir ((ax, ay), ad) ((bx, by), bd) =
  if ax == bx && ay == by then
    compare ad bd
  else compare_point (ax, ay) (bx, by)

module PointDirSet = Set.Make(struct
  type t = (int * int) * dir
  let compare = compare_point_dir
end)

let part1 input = 
  let grid = String.split_on_char '\n' input |> List.map (fun l -> l |> String.to_seq |> List.of_seq) in
  let height = List.length grid in
  let width = List.length (List.hd grid) in
  let get (i, j) = 
    if i < 0 || i >= height || j < 0 || j >= width then '#'
    else List.nth (List.nth grid i) j
  in
  let start_pos = ((0, 0), Right) in
  let rec energized_tiles (pos, dir) visited =
    let pipe = get pos in
    if PointDirSet.mem (pos, dir) visited || pipe == '#' then 
      visited
    else
      let visited = (PointDirSet.add (pos, dir) visited) in
      match pipe, dir with
      | '-', Up | '-', Down -> List.fold_left (fun acc d -> energized_tiles (next_pos_dir pos d) acc) visited [Right; Left]
      | '|', Right | '|', Left -> List.fold_left (fun acc d -> energized_tiles (next_pos_dir pos d) acc) visited [Up; Down]
      | _ -> energized_tiles (next_pos_dir pos (reflect dir pipe)) visited 
  in
  let energizied = energized_tiles start_pos (PointDirSet.empty) in
  PointDirSet.fold (fun (pos, _) acc -> PointSet.add pos acc) energizied PointSet.empty |> PointSet.cardinal |> Int.to_string
let part2 input = 
  let grid = String.split_on_char '\n' input |> List.map (fun l -> l |> String.to_seq |> List.of_seq) in
  let height = List.length grid in
  let width = List.length (List.hd grid) in
  let get (i, j) = 
    if i < 0 || i >= height || j < 0 || j >= width then '#'
    else List.nth (List.nth grid i) j
  in
  let energized_tiles start_pos =
    let rec energized_tiles' (pos, dir) visited =
      let pipe = get pos in
      if PointDirSet.mem (pos, dir) visited || pipe == '#' then 
        visited
      else
        let visited = (PointDirSet.add (pos, dir) visited) in
        match pipe, dir with
        | '-', Up | '-', Down -> List.fold_left (fun acc d -> energized_tiles' (next_pos_dir pos d) acc) visited [Right; Left]
        | '|', Right | '|', Left -> List.fold_left (fun acc d -> energized_tiles' (next_pos_dir pos d) acc) visited [Up; Down]
        | _ -> energized_tiles' (next_pos_dir pos (reflect dir pipe)) visited 
    in
    let energizied = energized_tiles' start_pos (PointDirSet.empty) in
    PointDirSet.fold (fun (pos, _) acc -> PointSet.add pos acc) energizied PointSet.empty |> PointSet.cardinal
  in
  let candidates = 
    List.init width (fun i -> (0, i), Down) @
    List.init width (fun i -> (height - 1, i), Up) @
    List.init height (fun i -> (i, 0), Right) @
    List.init height (fun i -> (i, width - 1), Left)
  in
  List.fold_left (fun acc p -> energized_tiles p |> max acc) 0 candidates |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  