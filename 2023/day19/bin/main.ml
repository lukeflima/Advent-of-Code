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

let split string ~on =
  let on_length = String.length on in 
  if on_length == 0 then [string]
  else if on_length == 1 then 
    String.split_on_char (String.get on 0) string
  else
  let rec spt string e lst= 
    let string_len = String.length string in
    if string_len - e < on_length then 
      if lst <> [] then
        if string_len <> 0 then 
          lst @ [string]
        else lst
      else [string]
    else
    let s = String.sub string e on_length in
    if String.equal s on then
      let back = String.sub string 0 e in
      let rest = String.sub string (e + on_length) (string_len - e - on_length) in
      spt rest 0 (lst @ [back])
    else
      spt string (e + 1) lst
  in
  spt string 0 []

let part1 input = 
  let blocks = split ~on:"\n\n" input in
  let workflows = List.hd blocks |> String.split_on_char '\n' |> List.fold_left (
    fun ht s -> let name_body = String.split_on_char '{' s in
    let name = List.hd name_body in
    let body = List.nth name_body 1 in
    let body = String.sub body 0 (String.length body - 1) |> String.split_on_char ',' |> List.map(
        fun s -> 
          if not (String.contains s ':') then
            'z', 'z', 0, s
          else
            let expr_response = String.split_on_char ':' s in
            let expr = List.hd expr_response in
            let res = List.nth expr_response 1 in
            let var = expr.[0] in
            let op = expr.[1] in
            let value = String.sub expr 2 (String.length expr - 2) |> int_of_string in
            var, op, value, res
    ) in
    Hashtbl.add ht name body;
    ht
  ) (Hashtbl.create 100) 
  in
  let ratings = List.nth blocks 1 |> String.split_on_char '\n' |> List.map (
    fun s -> String.sub s 1 (String.length s - 2) |> String.split_on_char ',' |> List.fold_left (
      fun acc s -> let key_value = String.split_on_char '=' s in 
      Hashtbl.add acc (List.hd key_value).[0] (List.nth key_value 1 |> int_of_string); acc 
    ) (Hashtbl.create 10)) 
  in 
  let is_approved rating =
    let start = Hashtbl.find workflows "in" in
    let rec process workflow =
      let res = List.fold_left (
        fun acc (var, op, value, res) -> 
          if String.length acc <> 0 then acc
          else if var == 'z' then res
          else
            let v = Hashtbl.find rating var in
            match op with
            | '>' -> if v > value then res else acc
            | '<' -> if v < value then res else acc
            | _ -> failwith "Invalid"
      ) "" workflow in
      match res with
      | "A" -> true
      | "R" -> false
      | _ -> process (Hashtbl.find workflows res)
    in
    process start
  in
  List.filter is_approved ratings |> List.fold_left (fun acc ht -> acc + Hashtbl.fold (fun _ v acc -> acc + v) ht 0) 0 |> Int.to_string


type part_range = {
  x: int * int;
  m: int * int;
  a: int * int;
  s: int * int;
}
  
let get_var range var =
  match var with
  | 'x' -> range.x
  | 'm' -> range.m
  | 'a' -> range.a
  | 's' -> range.s
  | _ -> failwith "Invalid variable"

let set_var range var new_val =
  match var with
  | 'x' -> { range with x = new_val }
  | 'm' -> { range with m = new_val }
  | 'a' -> { range with a = new_val }
  | 's' -> { range with s = new_val }
  | _ -> failwith "Invalid variable"

let split_range (low, high) op value =
  match op with
  | '<' ->
      let passing_high = min (value - 1) high in
      if low > passing_high then
        (None, Some (low, high))
      else 
        let remaining_low = max low value in
        if remaining_low > high then
          Some (low, passing_high), None
        else
          Some (low, passing_high), Some (remaining_low, high)
  | '>' ->
      let passing_low = max (value + 1) low in
      if passing_low > high then
        (None, Some (low, high))
      else 
        let remaining_high = min high value in
        if remaining_high < low then
          Some (passing_low, high), None
        else
          Some (passing_low, high), Some (low, remaining_high)
  | _ -> failwith "Invalid operator"

let compute_product range =
  let invalid (l, h) = l > h in
  let length (l, h) = h - l + 1 in
  if invalid range.x || invalid range.m || invalid range.a || invalid range.s then 0
  else (length range.x) * (length range.m) * (length range.a) * (length range.s)

let part2 input = 
  let blocks = split ~on:"\n\n" input in
  let workflows = List.hd blocks |> String.split_on_char '\n' |> List.fold_left (
    fun ht s -> let name_body = String.split_on_char '{' s in
    let name = List.hd name_body in
    let body = List.nth name_body 1 in
    let body = String.sub body 0 (String.length body - 1) |> String.split_on_char ',' |> List.map(
        fun s -> 
          if not (String.contains s ':') then
            'z', 'z', 0, s
          else
            let expr_response = String.split_on_char ':' s in
            let expr = List.hd expr_response in
            let res = List.nth expr_response 1 in
            let var = expr.[0] in
            let op = expr.[1] in
            let value = String.sub expr 2 (String.length expr - 2) |> int_of_string in
            var, op, value, res
    ) in
    Hashtbl.add ht name body;
    ht
  ) (Hashtbl.create 100) 
  in
  let queue = Queue.create () in
  let initial_range = { x = (1, 4000); m = (1, 4000); a = (1, 4000); s = (1, 4000) } in
  Queue.add ("in", initial_range) queue;
  let total = ref 0 in
  while not (Queue.is_empty queue) do
    let (workflow, range) = Queue.pop queue in
    match workflow with
    | "A" ->
        let product = compute_product range in
        total := !total + product
    | "R" -> ()
    | wf_name ->
        let rules = Hashtbl.find workflows wf_name in
        let rec apply_rules current_rules current_range =
          match current_rules with
          | [] -> ()
          | rule :: rest_rules ->
              match rule with
              | (var, op, value, target) when var <> 'z' ->
                  let var_r = get_var current_range var in
                  let passing, remaining = split_range var_r op value in
                  (match passing with
                  | Some (plow, phigh) ->
                      let new_range = set_var current_range var (plow, phigh) in
                      Queue.add (target, new_range) queue
                  | None -> ());
                  (match remaining with
                  | Some (rlow, rhigh) ->
                      let new_current = set_var current_range var (rlow, rhigh) in
                      apply_rules rest_rules new_current
                  | None -> ())
              | (_, _, _, target) ->
                  Queue.add (target, current_range) queue
        in
        apply_rules rules range
  done;
  Int.to_string !total

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  