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

type orentation = 
  | Vertical
  | Horizotal

let part1 input = 
  let blocks = split ~on:"\n\n" input in
  let get_grid block = String.split_on_char '\n' block |> List.map (fun s -> s |> String.to_seq |> List.of_seq) in
  let grids = List.map get_grid blocks in
  let find_reflection_line grid = 
    let transpose grid =
      let cols = List.length (List.hd grid) in
      List.init cols (fun j -> List.map (fun row -> List.nth row j) grid)
    in
    let check_horizontal grid =
      let rows = List.length grid in
      let rec loop i =
        if i >= rows - 1 then None
        else
          let valid = ref true in
          let j = ref 0 in
          while !valid && (i - !j >= 0) && (i + 1 + !j < rows) do
            if List.nth grid (i - !j) <> List.nth grid (i + 1 + !j) then
              valid := false;
            incr j
          done;
          if !valid then Some (i + 1)
          else loop (i + 1)
      in
      loop 0
    in
    match check_horizontal grid with
    | Some n -> (Horizotal, n)
    | None ->
        let transposed = transpose grid in
        match check_horizontal transposed with
        | Some n -> (Vertical, n)
        | None -> failwith "No reflection line found"
  in
  let summarizing lst = 
    List.fold_left (fun acc (ori, n) -> acc + match ori with
      | Vertical -> n 
      | Horizotal -> n * 100
    ) 0 lst
  in
  let reflection_lines = List.map find_reflection_line grids in
  summarizing  reflection_lines |> Int.to_string
let part2 input =  
  let blocks = split ~on:"\n\n" input in
  let get_grid block = String.split_on_char '\n' block |> List.map (fun s -> s |> String.to_seq |> List.of_seq) in
  let grids = List.map get_grid blocks in
  let find_reflection_line grid = 
    let transpose grid =
      let cols = List.length (List.hd grid) in
      List.init cols (fun j -> List.map (fun row -> List.nth row j) grid)
    in
    let check_horizontal grid =
      let rows = List.length grid in
      let rec loop i =
        if i >= rows - 1 then None
        else
          let total_diff = ref 0 in
          let j = ref 0 in
          while (i - !j >= 0) && (i + 1 + !j < rows) && !total_diff <= 1 do
            let row1 = List.nth grid (i - !j) in
            let row2 = List.nth grid (i + 1 + !j) in
            let diff = List.fold_left2 (fun acc c1 c2 -> if c1 <> c2 then acc + 1 else acc) 0 row1 row2 in
            total_diff := !total_diff + diff;
            incr j
          done;
          if !total_diff = 1 then Some (i + 1)
          else loop (i + 1)
      in
      loop 0
    in
    match check_horizontal grid with
    | Some n -> (Horizotal, n)
    | None ->
        let transposed = transpose grid in
        match check_horizontal transposed with
        | Some n -> (Vertical, n)
        | None -> failwith "No reflection line found"
  in
  let summarizing lst = 
    List.fold_left (fun acc (ori, n) -> acc + match ori with
      | Vertical -> n 
      | Horizotal -> n * 100
    ) 0 lst
  in
  let reflection_lines = List.map find_reflection_line grids in
  summarizing  reflection_lines |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  