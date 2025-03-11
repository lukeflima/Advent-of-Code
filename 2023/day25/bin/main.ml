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

(* Not working use the python script *)
module IntE = struct
  type t = string
  let compare = String.compare
  let default = ""
end

module G = Graph.Persistent.Digraph.ConcreteLabeled(String)(IntE)

let parse_node s =
  let parts = String.split_on_char ':' s |> List.map String.trim in
  let name = List.hd parts in
  let connections = List.nth parts 1 |> String.split_on_char ' ' in
  name, connections



module MinCut = Graph.Mincut.Make(G)

module Components = Graph.Components.Make(G)

let part1 input = 
  let nodes = String.split_on_char '\n' input |> List.map parse_node in
  let g = List.fold_left (
    fun g (name, cons) -> List.fold_left (
      fun g n -> G.add_edge (G.add_edge g name n) n name
    ) g cons
  ) G.empty nodes
  in
  let vertexes = G.fold_vertex (fun s a -> s :: a) g [] in
  let rec min_cutset vs = 
    match vs with
    | [] -> None
    | v :: vss -> 
      try (Some (MinCut.min_cutset g v))
      with _  -> min_cutset vss
    in
  let cutset = min_cutset vertexes |> Option.get in
  cutset |> List.length |> Int.to_string
  
let part2 input = (input |> String.length) * 0 |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  