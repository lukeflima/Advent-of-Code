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

module IntSet = Set.Make(Int)

let part1 input = 
  let bricks = String.split_on_char '\n' input |> List.map (
    fun s -> 
      let l = String.split_on_char '~' s |> 
      List.map (fun s -> 
        let l = String.split_on_char ',' s |> List.map int_of_string in 
        (List.hd l, List.nth l 1, List.nth l 2)
      ) 
    in (List.hd l, List.nth l 1)) 
    |> List.sort (fun ((_, _, z1), _) ((_, _, z2), _) -> compare z1 z2)
  in
  let overlaps ((x11, y11, _), (x12, y12, _)) ((x21, y21, _), (x22, y22, _)) = 
    max x11 x21 <= min x12 x22 && max y11 y21 <= min y12 y22
  in
  let take_n list n = List.to_seq list |> Seq.take n |> List.of_seq in
  let bricks, _ = List.fold_left (
    fun (bricks, i) brick ->
      let ((x1, y1, z1), (x2, y2, z2)) = brick in
      let max_z = List.fold_left (
        fun acc check -> 
          let (_, (_, _, zc)) = check in
          if overlaps brick check then max (zc + 1) acc 
          else acc 
      ) 1 (take_n bricks i) in
      (((x1, y1, max_z), (x2, y2, z2 - (z1 - max_z))) :: bricks, succ i)
  ) ([], 0) bricks in
  let bricks = List.sort (fun ((_, _, z1), _) ((_, _, z2), _) -> compare z1 z2) bricks in
  let k_supports_v = List.fold_left (fun (acc, i) _ -> Hashtbl.add acc i IntSet.empty; (acc, succ i)) (Hashtbl.create 0, 0) bricks |> fst in
  let v_supports_k = List.fold_left (fun (acc, i) _ -> Hashtbl.add acc i IntSet.empty; (acc, succ i)) (Hashtbl.create 0, 0) bricks |> fst in
  for j = 0 to List.length bricks - 1 do
    let upper = List.nth bricks j in
    for i = 0 to j - 1 do
      let lower = List.nth bricks i in
      let ((_, _, z1), _), (_, (_, _, z2)) = upper, lower in
      if overlaps lower upper && z1 == (z2 + 1) then begin
        Hashtbl.replace k_supports_v i (Hashtbl.find k_supports_v i |> IntSet.add j);
        Hashtbl.replace v_supports_k j (Hashtbl.find v_supports_k j |> IntSet.add i);
      end
    done
  done;
  List.fold_left (
    fun (acc, i) _ -> 
      let iset = Hashtbl.find k_supports_v i in
      if List.for_all (fun j -> IntSet.cardinal (Hashtbl.find v_supports_k j) >= 2) (IntSet.to_list iset) then (succ acc, succ i) 
      else (acc, succ i)
  ) (0, 0) bricks |> fst |> Int.to_string

let part2 input = 
  let bricks = String.split_on_char '\n' input |> List.map (
    fun s -> 
      let l = String.split_on_char '~' s |> 
      List.map (fun s -> 
        let l = String.split_on_char ',' s |> List.map int_of_string in 
        (List.hd l, List.nth l 1, List.nth l 2)
      ) 
    in (List.hd l, List.nth l 1)) 
    |> List.sort (fun ((_, _, z1), _) ((_, _, z2), _) -> compare z1 z2)
  in
  let overlaps ((x11, y11, _), (x12, y12, _)) ((x21, y21, _), (x22, y22, _)) = 
    max x11 x21 <= min x12 x22 && max y11 y21 <= min y12 y22
  in
  let take_n list n = List.to_seq list |> Seq.take n |> List.of_seq in
  let bricks, _ = List.fold_left (
    fun (bricks, i) brick ->
      let ((x1, y1, z1), (x2, y2, z2)) = brick in
      let max_z = List.fold_left (
        fun acc check -> 
          let (_, (_, _, zc)) = check in
          if overlaps brick check then max (zc + 1) acc 
          else acc 
      ) 1 (take_n bricks i) in
      (((x1, y1, max_z), (x2, y2, z2 - (z1 - max_z))) :: bricks, succ i)
  ) ([], 0) bricks in
  let bricks = List.sort (fun ((_, _, z1), _) ((_, _, z2), _) -> compare z1 z2) bricks in
  let k_supports_v = List.fold_left (fun (acc, i) _ -> Hashtbl.add acc i IntSet.empty; (acc, succ i)) (Hashtbl.create 0, 0) bricks |> fst in
  let v_supports_k = List.fold_left (fun (acc, i) _ -> Hashtbl.add acc i IntSet.empty; (acc, succ i)) (Hashtbl.create 0, 0) bricks |> fst in
  for j = 0 to List.length bricks - 1 do
    let upper = List.nth bricks j in
    for i = 0 to j - 1 do
      let lower = List.nth bricks i in
      let ((_, _, z1), _), (_, (_, _, z2)) = upper, lower in
      if overlaps lower upper && z1 == (z2 + 1) then begin
        Hashtbl.replace k_supports_v i (Hashtbl.find k_supports_v i |> IntSet.add j);
        Hashtbl.replace v_supports_k j (Hashtbl.find v_supports_k j |> IntSet.add i);
      end
    done
  done;
  List.fold_left (
    fun (acc, i) _ -> 
      let iset = Hashtbl.find k_supports_v i in
      let falling = List.filter (fun j -> IntSet.cardinal (Hashtbl.find v_supports_k j) == 1) (IntSet.to_list iset) |> IntSet.of_list in
      let queue = ref (IntSet.to_list falling) in
      let falling = ref (IntSet.add i falling) in
      while List.length !queue > 0 do
        let j = List.hd !queue; in queue := List.tl !queue;
        let jset = Hashtbl.find k_supports_v j in
        IntSet.iter (fun k -> if IntSet.subset (Hashtbl.find v_supports_k k) !falling then begin
          queue := !queue @ [k];
          falling := IntSet.add k !falling;
        end) (IntSet.diff jset !falling)
      done;
      (IntSet.cardinal !falling + acc - 1, succ i)
  ) (0, 0) bricks |> fst |> Int.to_string

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  