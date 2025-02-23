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
  let seeds = List.nth (split ~on:": " (List.nth blocks 0)) 1 in
  let str_list_to_int_list strlst = List.map int_of_string (split ~on:" " strlst) in
  let seeds = str_list_to_int_list seeds in
  let blocks = List.filteri (fun i _ -> i != 0) blocks in
  let get_ranges block =
    let lines = split ~on:"\n" block in
    let lines = List.filteri (fun i _ -> i != 0) lines in
    let maps = List.map str_list_to_int_list lines in
    List.map (fun range -> List.nth range 0, List.nth range 1, List.nth range 2) maps
  in
  let maps = List.map get_ranges blocks in
  let get_covertion n =
    let inner_get_covertion n map = 
      let convertion acc (dst, src, len) =
        if Option.is_some acc then
          acc 
        else if n >= src && n < src + len then
          Some (dst + (n - src))
        else
          None
      in
      let ret = List.fold_left convertion None map in
      Option.value ~default:n ret
    in
    List.fold_left inner_get_covertion n maps 
  in
  let locations = List.map get_covertion seeds in
  List.fold_left Int.min Int.max_int locations |> Int.to_string


let part2 input = let blocks = split ~on:"\n\n" input in
let seeds = List.nth (split ~on:": " (List.nth blocks 0)) 1 in
let str_list_to_int_list strlst = List.map int_of_string (split ~on:" " strlst) in
let seeds = str_list_to_int_list seeds in
let get_seeds seeds =
  let rec inner_get_seeds seeds ret =
    match seeds with
    | [] -> ret
    | a :: b :: rest -> inner_get_seeds rest (ret @ [(a, b)])
    | _ -> failwith "tf"
  in
  inner_get_seeds seeds []
in
let seeds = get_seeds seeds in
let blocks = List.filteri (fun i _ -> i != 0) blocks in
let get_ranges block =
  let lines = split ~on:"\n" block in
  let lines = List.filteri (fun i _ -> i != 0) lines in
  let maps = List.map str_list_to_int_list lines in
  List.map (fun range -> List.nth range 0, List.nth range 1, List.nth range 2) maps
in
let maps = List.map get_ranges blocks in
let get_covertion seeds =
  let seed_intervals = List.map (fun (s, l) -> (s, s + l)) seeds in
  let process_mapping intervals mapping =
    let rec apply_conversions intervals conversions processed =
      match conversions with
      | [] -> List.rev_append processed intervals
      | (dst, src, len) :: rest_convs ->
          let src_end = src + len in
          let new_intervals = ref [] in
          let new_processed = ref processed in
          List.iter (fun (s, e) ->
            let overlap_start = max s src in
            let overlap_end = min e src_end in
            if overlap_start < overlap_end then
              begin
                if s < overlap_start then
                  new_intervals := (s, overlap_start) :: !new_intervals;
                let transformed_start = dst + (overlap_start - src) in
                let transformed_end = transformed_start + (overlap_end - overlap_start) in
                new_processed := (transformed_start, transformed_end) :: !new_processed;
                if e > overlap_end then
                  new_intervals := (overlap_end, e) :: !new_intervals
              end
            else
              new_intervals := (s, e) :: !new_intervals
          ) intervals;
          apply_conversions !new_intervals rest_convs !new_processed
    in
    apply_conversions intervals mapping []
  in
  let final_intervals = List.fold_left process_mapping seed_intervals maps in
  List.fold_left (fun acc (s, _) -> min acc s) max_int final_intervals
in
let location = get_covertion seeds in
location |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  