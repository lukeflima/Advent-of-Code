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
  | Top
  | Right
  | Bottom
  | Left

let _string_of_dir dir = 
  match dir with
  | Top -> "Top"
  | Right -> "Right"
  | Bottom -> "Bottom"
  | Left -> "Left"

let get_dir dir =
  match dir with
  | Top -> (-1, 0)
  | Right -> (0, 1)
  | Bottom -> (1, 0)
  | Left -> (0, -1)

let get_pipe dirs =
  match dirs with
  | [Top; Bottom] | [Bottom; Top] -> '|'
  | [Left; Right] | [Right;Left] -> '-'
  | [Top; Right] | [Right; Top] -> 'L'
  | [Top; Left] | [Left; Top] -> 'J'
  | [Bottom; Left] | [Left; Bottom] -> '7'
  | [Bottom; Right] | [Right; Bottom] -> 'F'
  | _ -> failwith "Invalid pipe"

let get_adjs pipe = 
  match pipe with
  | '|' -> [get_dir Top; get_dir Bottom]
  | '-' -> [get_dir Left; get_dir Right]
  | 'L' -> [get_dir Top; get_dir Right]
  | 'J' -> [get_dir Top; get_dir Left]
  | '7' -> [get_dir Bottom; get_dir Left]
  | 'F' -> [get_dir Bottom; get_dir Right]
  | _ -> []

let _print_point p = 
  print_string "(";
  print_int (fst p);
  print_string ", ";
  print_int (snd p);
  print_string ")";
  print_newline ()

let equal_point (ax, ay) (bx, by) =
  ax == bx && ay == by

let compare_point (ax, ay) (bx, by) =
  if ax == bx then ay - by
  else ax - bx

module PointSet = Set.Make(struct
  type t = int * int
  let compare = compare_point
end)

let get grid width height i j = 
  if i < 0 || i >= height || j < 0 || j >= width then '.'
  else List.nth (List.nth grid i) j 

let get_p grid width height (px, py) = 
  get grid width height px py

let add_point (ax, ay) (bx, by) = (ax + bx, ay + by)

let is_connected a b grid width height =
  let pipe = get_p grid width height b in
  let adjs = get_adjs pipe in
  let adjs_points = List.map (fun d -> add_point b d) adjs in
  List.fold_left (fun acc p -> acc || equal_point p a) false adjs_points

let part1 input = 
  let lines = String.split_on_char '\n' input in
  let grid = List.map (fun line -> String.to_seq line |> List.of_seq) lines in
  let height = List.length grid in
  let width = List.length (List.hd grid) in
  let start = List.fold_left (fun (acc, i) row ->
    let acc = if Option.is_some acc then acc
    else
      List.fold_left (fun (acc,j) cell -> 
        let acc = if Option.is_some acc then acc
        else
          if cell == 'S' then Some (i, j)
          else None
        in
        (acc, j + 1)
      ) (acc, 0) row |> fst
    in
    (acc, i +1)
  ) (None, 0) grid |> fst |> Option.get
  in
  let start_pipe = List.fold_left (fun acc dir -> 
    let point = add_point start (get_dir dir) in
    if is_connected start point grid width height then acc @ [dir]
    else acc
  ) [] [Top; Right; Bottom; Left] |> get_pipe in
  let grid = List.mapi (fun i row -> List.mapi (fun j cell -> 
        if equal_point (i, j) start then start_pipe
        else cell
      ) row
    ) grid 
  in
  let get_loop_size start = 
    let rec get_loop_size' cur prev loop_size = 
      if (not (equal_point prev (-1, -1))) && equal_point cur start then
        loop_size
      else
        let pipe = get_p grid width height cur in
        let adjs = get_adjs pipe in
        let adjs_points = List.map (fun d -> add_point cur d) adjs in
        let next = List.find (fun p -> not (equal_point p prev)) adjs_points in
        get_loop_size' next cur (loop_size + 1)
    in
    get_loop_size' start (-1, -1) 0
  in
  let loop_size = get_loop_size start in
  loop_size / 2 |> Int.to_string

let part2 input = 
  let lines = String.split_on_char '\n' input in
  let grid = List.map (fun line -> String.to_seq line |> List.of_seq) lines in
  let height = List.length grid in
  let width = List.length (List.hd grid) in
  let start = List.fold_left (fun (acc, i) row ->
    let acc = if Option.is_some acc then acc
    else
      List.fold_left (fun (acc,j) cell -> 
        let acc = if Option.is_some acc then acc
        else
          if cell == 'S' then Some (i, j)
          else None
        in
        (acc, j + 1)
      ) (acc, 0) row |> fst
    in
    (acc, i +1)
  ) (None, 0) grid |> fst |> Option.get
  in
  let start_pipe = List.fold_left (fun acc dir -> 
    let point = add_point start (get_dir dir) in
    if is_connected start point grid width height then acc @ [dir]
    else acc
  ) [] [Top; Right; Bottom; Left] |> get_pipe in
  let grid = List.mapi (fun i row -> List.mapi (fun j cell -> 
        if equal_point (i, j) start then start_pipe
        else cell
      ) row
    ) grid 
  in
  let get_loop start = 
    let rec get_loop' cur prev loop = 
      if Option.is_some prev && equal_point cur start then
        loop
      else
        let prev = Option.value prev ~default:(-1, -1) in
        let pipe = get_p grid width height cur in
        let adjs = get_adjs pipe in
        let adjs_points = List.map (fun d -> add_point cur d) adjs in
        let next = List.find (fun p -> not (equal_point p prev)) adjs_points in
        get_loop' next (Some cur) (PointSet.add cur loop)
    in
    get_loop' start None PointSet.empty
  in
  let loop = get_loop start in
  let extend_point p = (fst p * 3, snd p * 3) in
  let loop = PointSet.fold (fun p s -> 
    let pipe = get_p grid width height p in
    let adjs = get_adjs pipe in
    let p = extend_point p in
    let adjs_points = List.map (fun d -> add_point p d) adjs in
    List.fold_left (fun s p -> PointSet.add p s) s adjs_points |> PointSet.add p
  ) loop PointSet.empty in
  let get_enclosed_tiles loop =
    let rec flood_fill current visited = 
      let adjs = List.map (fun d -> add_point current (get_dir d)) [ Top; Right; Bottom; Left] in
      let adjs = List.filter (fun (i, j) -> i >= -1 && i <= height*3 && j >= -1 && j <= width*3 && not (PointSet.mem (i, j) loop || PointSet.mem (i, j) visited)) adjs in
      if List.length adjs == 0 then PointSet.add current visited
      else List.fold_left (fun acc p -> flood_fill p acc) (PointSet.add current visited) adjs
    in
    let outside = flood_fill (-1, -1) PointSet.empty in
    List.fold_left (fun (i, inside) row ->
      let inside = List.fold_left (fun (j, ins) _ ->
        let p = extend_point (i, j) in
        if not (PointSet.mem p loop || PointSet.mem p outside) then (j + 1, ins + 1)
        else (j + 1, ins)
      ) (0, inside) row |> snd in
      (i + 1, inside)
    ) (0, 0) grid |> snd
  in
  get_enclosed_tiles loop |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  