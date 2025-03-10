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

(* let equal_point (ax, ay) (bx, by) =
  ax == bx && ay == by *)

let compare_point (ax, ay) (bx, by) =
  if ax == bx then ay - by
  else ax - bx

module PointSet = Set.Make(struct
  type t = int * int
  let compare = compare_point
end)

let part1 input = 
  let grid = String.split_on_char '\n' input |> List.map (fun s -> String.to_seq s |> List.of_seq) in
  let height = List.length grid in
  let width = List.length (List.hd grid) in
  let get (i, j) = 
    if i < 0 || i >= height || j < 0 || j >= width then '#'
    else List.nth (List.nth grid i) j
  in
  let start = List.fold_left (
    fun (acc, i) row -> 
      if Option.is_some acc then (acc, succ i) 
      else
        List.fold_left(
          fun (acc, j) cell ->
            if Option.is_some acc then (acc, succ j)
            else if cell == 'S' then (Some (i, j), succ j)
            else (acc, succ j)
        ) (acc, 0) row |> fst, succ i
    ) (None, 0) grid |> fst |> Option.get
  in
  let count_garden_plots start steps =
    let visited = Hashtbl.create steps in
    let rec count_garden_plots' (i, j) steps =
      let cell = get (i, j) in
      if cell <> '#' && not (Hashtbl.mem visited ((i, j), steps)) then begin
        Hashtbl.add visited ((i, j), steps) true;
        if steps > 0 then begin
          count_garden_plots' (i + 1, j) (steps - 1);
          count_garden_plots' (i - 1, j) (steps - 1);
          count_garden_plots' (i, j + 1) (steps - 1);
          count_garden_plots' (i, j - 1) (steps - 1);
      end
    end
    in
    count_garden_plots' start steps;
    Hashtbl.fold (fun (p, s) _ acc -> if s == 0 then PointSet.add p acc else acc) visited PointSet.empty |> PointSet.cardinal
  in
  count_garden_plots start 64 |> Int.to_string
let part2 input = 
  let grid = String.split_on_char '\n' input |> List.map (fun s -> String.to_seq s |> List.of_seq) in
  let height = List.length grid in
  let width = List.length (List.hd grid) in
  let get (i, j) = 
    let i = (i mod height + height) mod height in
    let j = (j mod width + width) mod width in
    List.nth (List.nth grid i) j
  in
  let start = List.fold_left (
    fun (acc, i) row -> 
      if Option.is_some acc then (acc, succ i) 
      else
        List.fold_left(
          fun (acc, j) cell ->
            if Option.is_some acc then (acc, succ j)
            else if cell == 'S' then (Some (i, j), succ j)
            else (acc, succ j)
        ) (acc, 0) row |> fst, succ i
    ) (None, 0) grid |> fst |> Option.get
  in
  let count_garden_plots start steps =
    let directions = [ (-1, 0); (1, 0); (0, -1); (0, 1) ] in
    let rec loop current step =
      if step = steps then
        PointSet.cardinal current
      else
        let next = PointSet.fold (fun (i, j) acc ->
          List.fold_left (fun acc' (di, dj) ->
            let ni = i + di in
            let nj = j + dj in
            if get (ni, nj) != '#' then
              PointSet.add (ni, nj) acc'
            else
              acc'
          ) acc directions
        ) current PointSet.empty in
        loop next (step + 1)
    in
    loop (PointSet.singleton start) 0
  in
  let y0 = count_garden_plots start 65 in
  let y1 = count_garden_plots start (65 + 131) in
  let y2 = count_garden_plots start (65 + 2 * 131) in
  let c = y0 in
  let a = (y2 + c - 2 * y1) / 2 in
  let b = y1 - c - a in
  let n = (26501365 - 65) / 131 in
  let result = a * n * n + b * n + c in
  Int.to_string result

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  