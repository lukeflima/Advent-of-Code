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
  let lines = String.split_on_char '\n' input in
  let conditions = List.map (fun x -> 
    let parts = String.split_on_char ' ' x in
    let nums = String.split_on_char ',' (List.nth parts 1) |> List.map int_of_string in
    (List.hd parts, nums)
  ) lines in
  let arrangements (condition, group) = 
    let memo = Hashtbl.create 100 in
    let rec arrangements' cond group cur_group =
      let key = (cond, group, cur_group) in
      let v = Hashtbl.find_opt memo key in
      if Option.is_some v then
        Option.get v 
      else
        let cur_group_value = Option.value cur_group ~default:0 in
        let c = if String.length cond > 0 then String.get cond 0 else ' ' in
        let rest = if String.length cond > 0 then String.sub cond 1 (String.length cond - 1) else "" in
        let res = if String.length cond == 0 && List.length group == 0 && cur_group_value == 0 then 1
        else if String.length cond == 0 then 0
        else if c == '.' then begin
            if cur_group_value > 0 then 0
            else arrangements' rest group None
        end
        else if c == '#' then begin
          if Option.is_some cur_group then
            if cur_group_value == 0 then 0
            else arrangements' rest group (Some (cur_group_value - 1))
          else
            if List.length group > 0 then
              let new_group = List.tl group in
              arrangements' rest new_group (Some (List.hd group - 1))
            else 0
        end
        else if c == '?' then begin
          if cur_group_value > 0 then
            arrangements' rest group (Some (cur_group_value - 1))
          else if Option.is_some cur_group then
            arrangements' rest group None
          else
            let if_u = arrangements' rest group None in
            let if_d = if List.length group > 0 then arrangements' rest (List.tl group) (Some (List.hd group - 1)) else 0 in
            if_u + if_d
        end
        else failwith "Invalid character"
        in
        Hashtbl.add memo key res; 
        res
    in
    arrangements' condition group None
  in
  List.map arrangements conditions |> List.fold_left ( + ) 0 |> string_of_int
let part2 input = 
  let lines = String.split_on_char '\n' input in
  let unfold lst = lst @ lst @ lst @ lst @ lst in
  let conditions = List.map (fun x -> 
    let parts = String.split_on_char ' ' x in
    let cond = List.hd parts |> String.to_seq |> List.of_seq |> List.append ['?'] |> unfold |> List.tl |> List.to_seq |> String.of_seq in
    let nums = String.split_on_char ',' (List.nth parts 1) |> List.map int_of_string |> unfold in
    (cond, nums)
  ) lines in
  let memo = Hashtbl.create 5000 in
  let arrangements (condition, group) = 
    Hashtbl.clear memo;
    let rec arrangements' cond group cur_group =
      let key = (cond, group, cur_group) in
      let v = Hashtbl.find_opt memo key in
      if Option.is_some v then
        Option.get v 
      else
        let cur_group_value = Option.value cur_group ~default:0 in
        let c = if String.length cond > 0 then String.get cond 0 else ' ' in
        let rest = if String.length cond > 0 then String.sub cond 1 (String.length cond - 1) else "" in
        let res = if String.length cond == 0 && List.length group == 0 && cur_group_value == 0 then 1
        else if String.length cond == 0 then 0
        else if c == '.' then begin
            if cur_group_value > 0 then 0
            else arrangements' rest group None
        end
        else if c == '#' then begin
          if Option.is_some cur_group then
            if cur_group_value == 0 then 0
            else arrangements' rest group (Some (cur_group_value - 1))
          else
            if List.length group > 0 then
              let new_group = List.tl group in
              arrangements' rest new_group (Some (List.hd group - 1))
            else 0
        end
        else if c == '?' then begin
          if cur_group_value > 0 then
            arrangements' rest group (Some (cur_group_value - 1))
          else if Option.is_some cur_group then
            arrangements' rest group None
          else
            let if_u = arrangements' rest group None in
            let if_d = if List.length group > 0 then arrangements' rest (List.tl group) (Some (List.hd group - 1)) else 0 in
            if_u + if_d
        end
        else failwith "Invalid character"
        in
        Hashtbl.add memo key res; 
        res
    in
    arrangements' condition group None
  in
  List.map arrangements conditions |> List.fold_left ( + ) 0 |> string_of_int

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  