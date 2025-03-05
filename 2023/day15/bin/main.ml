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

let hash s = 
  String.fold_left (fun acc c -> ((acc + (int_of_char c)) * 17) land 255) 0 s

let part1 input = 
  let seq = String.split_on_char ',' input in
  let seq = List.map hash seq in
  List.fold_left ( + ) 0 seq |> Int.to_string

type op = 
  | Insert
  | Remove
let part2 input = 
  let seq = String.split_on_char ',' input in
  let instructions = List.map (fun s -> 
    let tl = s |> String.to_seq |> List.of_seq |> List.rev |> List.hd in
    if tl == '-' then
      let name = String.split_on_char '-' s |> List.hd in
      (Remove, name, None)
    else
      let parts = String.split_on_char '=' s in
      let name = List.hd parts in
      let fp = List.nth parts 1 |> int_of_string in
      (Insert, name, Some fp)
  ) seq in
  let ht = Hashtbl.create 256 in
  List.iter (fun (op, name, value_opt) ->
    let name_hash = hash name in
    let list = Hashtbl.find_opt ht name_hash |> Option.value ~default:[] in
    match op with
    | Insert -> 
      let value = Option.get value_opt in
      let index = List.find_index (fun (s, _) -> String.equal s name) list in
      let list = match index with
      | Some n -> List.mapi (fun i v -> if i == n then (name, value) else v) list
      | None -> list @ [(name, value)]
      in
      Hashtbl.replace ht name_hash list;
    | Remove ->
      let list = List.filter (fun (s, _) -> String.equal s name |> not) list in
      Hashtbl.replace ht name_hash list;
  ) instructions;
  Hashtbl.fold (fun k v acc -> 
    acc + (
      List.fold_left (
        fun (acc, slot) (_, fl) -> (acc + ((k + 1) * slot * fl), succ slot)
        )
      (0, 1) v |> fst)
    ) ht 0 |> Int.to_string

  

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  