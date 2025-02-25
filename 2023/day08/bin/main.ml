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

let part1 input = 
  let lines = String.split_on_char '\n' input |> List.filter (fun x -> x <> "") in
  let instructions = List.hd lines |> String.to_seq |> List.of_seq in
  let lines = List.tl lines in
  let network = List.fold_left (
    fun ht line ->
      let parts = String.split_on_char '=' line in
      let node = List.nth parts 0 |> String.trim in
      let parts = List.nth parts 1 |> String.split_on_char ',' in
      let left = String.sub (List.nth parts 0) 2 3 in
      let right = String.sub (List.nth parts 1) 1 3 in
      Hashtbl.add ht node (left, right);
      ht) 
    (Hashtbl.create (List.length lines)) lines 
  in
  let get_step node =
    let rec get_step' lst node steps = 
      if String.equal node "ZZZ" then steps
      else
        let (left, right) = Hashtbl.find network node in
        match lst with
        | [] -> get_step' instructions node steps
        | instruction :: rest -> get_step' rest (if instruction == 'R' then right else left) (steps + 1)
    in
    get_step' instructions node 0
  in
  let steps = get_step "AAA" in
  steps |> string_of_int

let part2 input = 
  let lines = String.split_on_char '\n' input |> List.filter (fun x -> x <> "") in
  let instructions = List.hd lines |> String.to_seq |> List.of_seq in
  let lines = List.tl lines in
  let network = List.fold_left (
    fun ht line ->
      let parts = String.split_on_char '=' line in
      let node = List.nth parts 0 |> String.trim in
      let parts = List.nth parts 1 |> String.split_on_char ',' in
      let left = String.sub (List.nth parts 0) 2 3 in
      let right = String.sub (List.nth parts 1) 1 3 in
      Hashtbl.add ht node (left, right);
      ht) 
    (Hashtbl.create (List.length lines)) lines 
  in
  let get_step node =
    let rec get_step' lst node steps = 
      if String.to_seq node |> List.of_seq |> List.rev |> List.hd == 'Z' then steps
      else
        let (left, right) = Hashtbl.find network node in
        match lst with
        | [] -> get_step' instructions node steps
        | instruction :: rest -> get_step' rest (if instruction == 'R' then right else left) (steps + 1)
    in
    get_step' instructions node 0
  in
  let starts = Hashtbl.to_seq_keys network |> List.of_seq |> List.filter (fun x -> String.to_seq x |> List.of_seq |> List.rev |> List.hd == 'A') in 
  let steps_z = List.map  get_step starts in
  let lcm a b = 
    let gcd a b =
      let rec gcd' a b =
        if b = 0 then a else gcd' b (a mod b)
      in
      gcd' a b
    in
    a * b / (gcd a b) in
  let steps = List.fold_left (fun acc x -> lcm acc x) 1 steps_z in
  steps |> string_of_int

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  