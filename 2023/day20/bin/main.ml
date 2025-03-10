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

type signal =
  | High
  | Low

let _toggle_signal s =
  match s with
  | High -> Low
  | Low -> High

type moduleType = 
  | Flipflop of bool
  | Conjuction of (string, signal) Hashtbl.t

type modul = {
  typ: moduleType;
  outs: string list;
}

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
  let modules = String.split_on_char '\n' input |> List.fold_left (
      fun acc s -> 
        let name_outs = split ~on:" -> " s in
        let name = List.hd name_outs in
        let type_mod = name.[0] in
        let name = if String.equal "broadcaster" name then name else String.sub name 1 (String.length name - 1) in
        let outs = List.nth name_outs 1 |> split ~on:", " in
        let modul = match type_mod with
        | '%' -> {outs = outs; typ = Flipflop false}      
        | '&' -> {outs = outs; typ = Conjuction (Hashtbl.create 10)}  
        | _ -> {outs = outs; typ = Flipflop false} in
        Hashtbl.add acc name modul;
        acc
    ) (Hashtbl.create 0) in
    Hashtbl.iter (fun src_name modul ->
      List.iter (fun dest_name ->
        if Hashtbl.mem modules dest_name then
          match (Hashtbl.find modules dest_name).typ with
          | Conjuction mem -> Hashtbl.replace mem src_name Low
          | _ -> ()
      ) modul.outs
    ) modules;
  let broadcaster = (Hashtbl.find modules "broadcaster").outs in Hashtbl.remove modules "broadcaster";
  let low = ref 0 in
  let high = ref 0 in
  for _ = 1 to 1000 do
    low := succ !low;
    let queue = ref (List.map (fun name -> "broadcaster", name, Low) broadcaster) in
    while not (List.is_empty !queue) do
      let origin, target, pulse = List.hd !queue in queue := List.tl !queue; 
      let () = match pulse with
        | Low -> low := succ !low
        | High -> high := succ !high
      in
      if Hashtbl.mem modules target then begin
        let modul = Hashtbl.find modules target in
        match modul.typ with
        | Flipflop memory -> 
          if pulse == Low then begin
            let memory = not memory in
            let outgoing = if memory then High else Low in
            Hashtbl.replace modules target {modul with typ = Flipflop memory};
            queue := !queue @ List.map (
              fun name -> target, name, outgoing
            ) modul.outs
          end
        | Conjuction memory -> 
          Hashtbl.replace memory origin pulse;
          let outgoing = if List.for_all (fun s -> s == High) (Hashtbl.to_seq_values memory |> List.of_seq) then Low else High in
          queue := !queue @ List.map (
            fun name -> target, name, outgoing
          ) modul.outs
      end
    done;
  done;
  !high * !low |> Int.to_string

  let rec gcd a b =
    if b = 0 then a else gcd b (a mod b)
  let lcm a b = a * b / gcd a b
  let part2 input = 
    let modules = String.split_on_char '\n' input |> List.fold_left (
      fun acc s -> 
        let name_outs = split ~on:" -> " s in
        let name = List.hd name_outs in
        let type_mod = name.[0] in
        let name = if String.equal "broadcaster" name then name else String.sub name 1 (String.length name - 1) in
        let outs = List.nth name_outs 1 |> split ~on:", " in
        let modul = match type_mod with
        | '%' -> {outs = outs; typ = Flipflop false}      
        | '&' -> {outs = outs; typ = Conjuction (Hashtbl.create 10)}  
        | _ -> {outs = outs; typ = Flipflop false} in
        Hashtbl.add acc name modul;
        acc
    ) (Hashtbl.create 0) in
    Hashtbl.iter (fun src_name modul ->
      List.iter (fun dest_name ->
        if Hashtbl.mem modules dest_name then
          match (Hashtbl.find modules dest_name).typ with
          | Conjuction mem -> Hashtbl.replace mem src_name Low
          | _ -> ()
      ) modul.outs
    ) modules;
    let broadcaster = (Hashtbl.find modules "broadcaster").outs in
    Hashtbl.remove modules "broadcaster";
    let feed = 
      Hashtbl.fold (fun name m acc ->
        if List.exists (fun n -> String.equal n "rx") m.outs then name else acc
      ) modules "" in
    let seen = Hashtbl.fold (fun name m acc ->
      if List.exists (fun n -> String.equal n feed) m.outs then
        Hashtbl.add acc name 0;
      acc
    ) modules (Hashtbl.create 0) in
    let cycle_lengths = Hashtbl.create 0 in
    let presses = ref 0 in
    let res = ref 1 in
    let exception Early_exit in
    try while true do
      incr presses;
      let queue = ref (List.map (fun name -> "broadcaster", name, Low) broadcaster) in
      while not (List.is_empty !queue) do
        let origin, target, pulse = List.hd !queue in 
        queue := List.tl !queue;
        if Hashtbl.mem modules target then begin
          let modul = Hashtbl.find modules target in
          if String.equal target feed && pulse == High then begin
            Hashtbl.replace seen origin (Hashtbl.find seen origin + 1);
            if not (Hashtbl.mem cycle_lengths origin) then begin
              Hashtbl.add cycle_lengths origin !presses;
            end;
            if Hashtbl.length cycle_lengths = Hashtbl.length seen then begin
              res := Hashtbl.fold (fun _ cycle acc -> lcm acc cycle) cycle_lengths 1;
              raise Early_exit;
            end;
          end;
          match modul.typ with
          | Flipflop memory -> 
            if pulse == Low then begin
              let memory = not memory in
              let outgoing = if memory then High else Low in
              Hashtbl.replace modules target {modul with typ = Flipflop memory};
              queue := !queue @ List.map (fun name -> target, name, outgoing) modul.outs
            end
          | Conjuction memory -> 
            Hashtbl.replace memory origin pulse;
            let outgoing = if List.for_all (fun s -> s == High) (Hashtbl.to_seq_values memory |> List.of_seq) then Low else High in
            queue := !queue @ List.map (fun name -> target, name, outgoing) modul.outs;
        end;
      done;
    done;
    Int.to_string !res
    with Early_exit -> Int.to_string !res


(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  