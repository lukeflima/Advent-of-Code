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

let print_dir dir =
  match dir with
  | Up -> print_string "Up"
  | Down -> print_string "Down"
  | Right -> print_string "Right"
  | Left -> print_string "Left"
let turn_left dir =
  match dir with
  | Up    -> Left
  | Down  -> Right
  | Right -> Up
  | Left  -> Down

let turn_right dir =
  match dir with
  | Up    -> Right
  | Down  -> Left
  | Right -> Down
  | Left  -> Up

let next_pos (i, j) dir =
  match dir with
  | Up    -> (i - 1, j)
  | Down  -> (i + 1, j)
  | Right -> (i, j + 1)
  | Left  -> (i, j - 1)

let compare_point (ax, ay) (bx, by) =
  if ax == bx then compare ay by
  else compare ax bx

module PointSet = Set.Make(struct
  type t = int * int
  let compare = compare_point
end)

let print_point (i, j) = print_string "("; print_int i; print_string ", "; print_int j; print_string ")"
let _print_grid grid visited = 
  List.iteri (fun i row ->
    List.iteri (fun j c ->
      if PointSet.mem (i, j) visited then print_char '#'
      else print_int c
    ) row;
    print_newline ();
  ) grid

let compare_state  (ac, ad, aw, ap) (bc, bd, bw, bp) =
  if ac == bc && ad == bd && aw == bw then compare_point ap bp
  else if ac == bc && ad == bd then compare aw bw
  else if ac == bc then compare ad bd
  else compare ac bc


let _print_state_newline (cost, dir, walk, pos, v) =
  print_int cost; print_string ", ";
  print_dir dir; print_string ", ";
  print_int walk; print_string ", ";
  print_point pos; print_string ", ";
  PointSet.cardinal v |> print_int;
  print_newline ();

module StateSet = Set.Make(struct
  type t = int * dir * int * (int * int) 
  let compare = compare_state 
end)

let equal_point (ax, ay) (bx, by) =
  ax == bx && ay == by

let part1 input = 
  let grid = String.split_on_char '\n' input |> List.map (fun l -> l |> String.to_seq |> List.of_seq |> List.map (fun c -> int_of_char c - int_of_char '0')) in
  let height = List.length grid in
  let width = List.length (List.hd grid) in
  let get (i, j) = 
    if i < 0 || i >= height || j < 0 || j >= width then -1
    else List.nth (List.nth grid i) j
  in
  let min_heat_lost start_pos end_pos =
    let q = ref (StateSet.(empty |> add (0, Right, 0, start_pos))) in
    let res = ref 0 in
    let visited = Hashtbl.create 100 in
    let add s = 
      let (cost, dir, walk, pos) = s in
      let c = get pos in
      if c >= 0 && not (Hashtbl.mem visited (dir, walk, pos)) then begin
        Hashtbl.replace visited (dir, walk, pos) cost;
        q := StateSet.add (cost + c, dir, walk, pos) !q
      end
    in
    let exception Early_exit in
    try while not (StateSet.is_empty !q) do
      let state = StateSet.min_elt !q in
      q := StateSet.remove state !q;
      let (cost, dir, walk, pos) = state in
      let cell_cost = get pos in
      if equal_point pos end_pos then begin
        res := cost;
        raise Early_exit;
      end else begin
        if cell_cost <> -1 then begin
          if walk + 1 < 3 then begin
            add (cost, dir, walk + 1, next_pos pos dir);
          end;
          add (cost, turn_left dir, 0, next_pos pos (turn_left dir));
          add (cost, turn_right dir, 0, next_pos pos (turn_right dir));
        end
      end
    done;
    !res
    with Early_exit -> !res;   
  in
  min_heat_lost (0, 0) (height - 1, width - 1) |> Int.to_string
let part2 input = 
  let grid = String.split_on_char '\n' input |> List.map (fun l -> l |> String.to_seq |> List.of_seq |> List.map (fun c -> int_of_char c - int_of_char '0')) in
  let height = List.length grid in
  let width = List.length (List.hd grid) in
  let get (i, j) = 
    if i < 0 || i >= height || j < 0 || j >= width then -1
    else List.nth (List.nth grid i) j
  in
  let min_heat_lost start_pos end_pos =
    let q = ref (StateSet.(empty |> add (0, Right, 0, start_pos) |> add (0, Down, 0, start_pos) )) in
    let res = ref 0 in
    let visited = Hashtbl.create 100 in
    let add s = 
      let (cost, dir, walk, pos) = s in
      let c = get pos in
      if c <> -1 && not (Hashtbl.mem visited (dir, walk, pos)) then begin
        Hashtbl.replace visited (dir, walk, pos) cost;
        q := StateSet.add (cost + c, dir, walk, pos) !q
      end
    in
    let exception Early_exit in
    try while not (StateSet.is_empty !q) do
      let state = StateSet.min_elt !q in
      q := StateSet.remove state !q;
      let (cost, dir, walk, pos) = state in
      if equal_point pos end_pos then begin
        res := cost;
        raise Early_exit;
      end else begin
        if get pos <> -1 then begin
          if walk < 10 || equal_point pos start_pos then begin
            add (cost, dir, walk + 1, next_pos pos dir);
          end;
          if walk >= 4 then begin
            add (cost, turn_left dir, 1, next_pos pos (turn_left dir));
            add (cost, turn_right dir, 1, next_pos pos (turn_right dir));
          end;
        end
      end
    done;
    !res
    with Early_exit -> !res;   
  in
  min_heat_lost (0, 0) (height - 1, width - 1) |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  