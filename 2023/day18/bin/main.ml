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

let get_dir d = 
  match d with
  | "U" -> Up
  | "D" -> Down
  | "R" -> Right
  | "L" -> Left
  | _ -> failwith "Invalid"

let get_dir_of_digit d = 
  match d with
  | "0" -> Right
  | "1" -> Down
  | "2" -> Left
  | "3" -> Up
  | _ -> failwith "Invalid"

let _print_dir d = 
  match d with
  | Up -> print_string "Up"
  | Down -> print_string "Down"
  | Right -> print_string "Right"
  | Left -> print_string "Left"  

let next_pos (i, j) dir =
  match dir with
  | Up    -> (i - 1, j)
  | Down  -> (i + 1, j)
  | Right -> (i, j + 1)
  | Left  -> (i, j - 1)

let get_dir_point dir =
  match dir with
  | Up    -> (-1, 0)
  | Down  -> (1, 0)
  | Right -> (0, 1)
  | Left  -> (0, -1)
  

let add_points (ax, ay) (bx, by) =
  (ax + bx), (ay + by)

let scale_point (ax, ay) n =
  (ax * n), (ay * n)

let compare_point (ax, ay) (bx, by) =
  if ax == bx then compare ay by
  else compare ax bx

module PointSet = Set.Make(struct
  type t = int * int
  let compare = compare_point
end)
  
let part1 input = 
  let dig_plan = String.split_on_char '\n' input |> 
    List.map (fun s -> String.split_on_char ' ' s) |>
    List.map (fun l -> match l with 
    | [dir; num; _color] -> get_dir dir, int_of_string num 
    | _ -> failwith "invalid")
  in
  let trench = List.fold_left (fun (cur, set) (dir, n) -> 
    List.init n succ |> List.fold_left (fun (c, s) _ ->
      (next_pos c dir, PointSet.add c s)
      ) (cur, set) 
    ) ((0, 0), PointSet.empty) dig_plan  |> snd
  in
  let rec flood_fill p s =
    let s = PointSet.add p s in
    List.fold_left (fun acc d -> if not (PointSet.mem (next_pos p d) acc) then
      flood_fill (next_pos p d) acc else acc) s [Up; Down; Left; Right]
  in
  flood_fill (1, 1) trench |> PointSet.cardinal |> Int.to_string

(* Shoelace Formula + Pick's theorem *)
let calc_cubic_meters vertices = 
  let area = List.fold_left (fun acc ((vx1, vy1), (vx2, vy2)) -> acc + (vx1 * vy2 - vy1 * vx2)) 0 vertices / 2 in
  let perimiter = List.fold_left (fun acc ((vx1, vy1), (vx2, vy2)) -> acc + Int.abs (vx1 - vx2) + Int.abs (vy1 - vy2)) 0 vertices in
  (area - (perimiter / 2) + 1) + perimiter

let part2 input = 
  let dig_plan = String.split_on_char '\n' input |> 
    List.map (fun s -> String.split_on_char ' ' s) |>
    List.map (fun l -> match l with 
    | [_; _; hex] -> 
      let hex = String.sub hex 2 6 in
      (get_dir_of_digit (String.sub hex 5 1), int_of_string ("0x" ^ String.sub hex 0 5))
    | _ -> failwith "invalid")
  in
  let trench = List.fold_left (fun (cur, res) (dir, n) -> 
      let next_cur = add_points cur (scale_point (get_dir_point dir) (n)) in
      (next_cur, (next_cur, cur) :: res)) 
    ((0, 0), []) dig_plan |> snd
  in
  calc_cubic_meters trench |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  