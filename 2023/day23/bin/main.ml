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

let equal_point (ax, ay) (bx, by) =
  ax == bx && ay == by

let compare_point (ax, ay) (bx, by) =
  if ax == bx then compare ay by
  else compare ax bx

module PointSet = Set.Make(struct
  type t = int * int
  let compare = compare_point
end)

let part1 input = 
  let grid = String.split_on_char '\n' input |> List.map (fun l -> l |> String.to_seq |> List.of_seq) in
  let height = List.length grid in
  let width = List.length (List.hd grid) in
  let get (i, j) = 
    if i < 0 || i >= height || j < 0 || j >= width then '#'
    else List.nth (List.nth grid i) j
  in
  let start_pos = (0, 1) in
  let end_pos = (height - 1, width - 2) in
  let walk =
    let longest_path = ref 0 in
    let q = ref [(start_pos, 0, PointSet.empty)] in
    while List.length !q > 0 do
      let (i,j), dist, visited = List.hd !q in q := List.tl !q;
      if not (PointSet.mem (i, j) visited) then begin
        if equal_point end_pos (i, j) then longest_path := max dist !longest_path
        else begin
          let visited = PointSet.add (i, j) visited in
          let cell = get (i, j) in
          match cell with
          | '#' -> ()
          | '>' -> q := !q @ [((i, j + 1), dist + 1, visited)] 
          | '<' -> q := !q @ [((i, j - 1), dist + 1, visited)] 
          | 'v' -> q := !q @ [((i + 1, j), dist + 1, visited)] 
          | '^' -> q := !q @ [((i - 1, j), dist + 1, visited)] 
          | _   -> q := !q @ [((i, j + 1), dist + 1, visited); ((i, j - 1), dist + 1, visited); ((i + 1, j), dist + 1, visited); ((i - 1, j), dist + 1, visited)];
        end
      end;
    done;
    !longest_path
  in
  walk |> Int.to_string

let part2 input = 
  let grid = String.split_on_char '\n' input |> List.map (fun l -> l |> String.to_seq |> List.of_seq) in
  let height = List.length grid in
  let width = List.length (List.hd grid) in
  let get (i, j) = 
    if i < 0 || i >= height || j < 0 || j >= width then '#'
    else List.nth (List.nth grid i) j
  in
  let start_pos = (0, 1) in
  let end_pos = (height - 1, width - 2) in
  let vertexes = List.fold_left (
    fun (i, set) row -> succ i, List.fold_left (
      fun (j, set) cell ->
        succ j, if cell <> '#' && List.filter (fun p -> get p <> '#') [(i + 1, j); (i - 1, j); (i, j + 1); (i, j - 1);] |> List.length > 2 then
          PointSet.add (i, j) set
        else set
    ) (0, set) row |> snd
  ) (0, PointSet.empty) grid |> snd in
  let vertexes = (PointSet.(add start_pos vertexes |> add end_pos)) in
  let graph = Hashtbl.create 0 in
  PointSet.iter (
    fun (x, y) ->
      let q = ref [(x, y);] in
      let dist = ref 0 in
      let seen = List.to_seq [((x, y), true);] |> Hashtbl.of_seq in
      while List.length !q > 0 do
        let nq = ref [] in
        let () = incr dist in
        let () = List.iter (
          fun (i, j) -> 
            List.iter (
              fun a ->
                if get a <> '#' && not (Hashtbl.mem seen a) then begin
                  Hashtbl.add seen a true;
                  if PointSet.mem a vertexes then begin
                    let g = Hashtbl.find_opt graph (x, y) |> Option.value ~default:[] in
                    Hashtbl.replace graph (x, y) (g @ [!dist, a]);
                  end else begin
                    nq := !nq @ [a];
                  end
                end
            ) [(i + 1, j); (i - 1, j); (i, j + 1); (i, j - 1);]
        ) !q in
        q := !nq;
      done;
  ) vertexes;
  let walk =
    let visited = ref PointSet.empty in
    let rec walk' pos =
        if equal_point end_pos pos then 0
        else begin
          visited := PointSet.add pos !visited;
          let m = List.fold_left (fun acc (d, n) -> if not (PointSet.mem n !visited) then max acc (d + walk' n) else acc) Int.min_int (Hashtbl.find graph pos) in
          visited := PointSet.remove pos !visited;
          m
        end
      in
    walk' start_pos
  in
  walk |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  