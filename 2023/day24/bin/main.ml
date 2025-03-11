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

let posvel_to_line ((x, y), (vx, vy)) = (x, y), (x + vx, y + vy)

let intersection ((x1, y1), (x2, y2)) ((x3, y3), (x4, y4)) = 
  let x1, y1, x2, y2, x3, y3, x4, y4 = Bigdecimal.of_int x1, Bigdecimal.of_int y1, Bigdecimal.of_int x2, Bigdecimal.of_int y2, Bigdecimal.of_int x3, Bigdecimal.of_int y3, Bigdecimal.of_int x4, Bigdecimal.of_int y4 in
  let x_num = Bigdecimal.(one * (((x1 * y2) - (y1 * x2))*(x3 - x4)) - ((x1 - x2)*((x3 * y4) - (y3 * x4)))) in
  let y_num = Bigdecimal.(one * (((x1 * y2) - (y1 * x2))*(y3 - y4)) - ((y1 - y2)*((x3 * y4) - (y3 * x4)))) in
  let den = Bigdecimal.(one * ((x1 - x2) * (y3 - y4)) - ((y1 - y2) * (x3 - x4))) in
  if Bigdecimal.is_zero den then (Bigdecimal.zero, Bigdecimal.zero)
  else (Bigdecimal.div x_num den, Bigdecimal.div y_num den)

let cross (x1, y1, z1) (x2, y2, z2) = 
  Bigdecimal.((y1 * z2) - (z1 * y2)), Bigdecimal.((z1 * x2) - (x1 * z2)), Bigdecimal.((x1 * y2) - (y1 * x2))

let dot (x1, y1, z1) (x2, y2, z2) = 
  Bigdecimal.(x1 * x2 + y1 * y2 + z1 * z2)

let sub_point (x1, y1, z1) (x2, y2, z2) =
  Bigdecimal.(x1 - x2), Bigdecimal.(y1 - y2), Bigdecimal.(z1 - z2)
let add_point (x1, y1, z1) (x2, y2, z2) =
  Bigdecimal.(x1 + x2), Bigdecimal.(y1 + y2), Bigdecimal.(z1 + z2)
let scale_point (x, y, z) t =
  Bigdecimal.(x * t), Bigdecimal.(y * t), Bigdecimal.(z * t)
let scale_down_point (x, y, z) t =
  Bigdecimal.div x t, Bigdecimal.div y t, Bigdecimal.div z t
  
let parse_point s =
  let l = String.split_on_char ',' s |> List.map String.trim |> List.map int_of_string in
  List.hd l |> Bigdecimal.of_int, List.nth l 1 |> Bigdecimal.of_int, List.nth l 2 |> Bigdecimal.of_int

let parse_point_xy s =
  let l = String.split_on_char ',' s |> List.map String.trim |> List.map int_of_string in
  List.hd l, List.nth l 1

let part1 input = 
  let hailstones = String.split_on_char '\n' input |> List.map (fun s -> let l = String.split_on_char '@' s |> List.map parse_point_xy in List.hd l, List.nth l 1) in
  let minv, maxv = Bigdecimal.of_int 200000000000000, Bigdecimal.of_int 400000000000000 in
  let x_min, y_min, x_max, y_max = minv, minv, maxv, maxv in
  let is_inside (x, y) = Bigdecimal.(x >= x_min && x <= x_max && y >= y_min && y <= y_max) in
  let last_n list n = List.to_seq list |> Seq.drop n |> List.of_seq in
  let intersections = List.fold_left (fun (i, acc) cur -> succ i, acc @ List.map (fun c -> cur, c, intersection (posvel_to_line c) (posvel_to_line cur)) (last_n hailstones i)) (1, []) hailstones |> snd in
  let is_valid a b inter =
    let ix, iy = inter in
    let can_happen ((px, py), (vx, vy)) =
      let px, py, vx, vy = Bigdecimal.(of_int px, of_int py, of_int vx, of_int vy) in
      Bigdecimal.(one * (vx * (ix - px)) >= zero) && Bigdecimal.(one * (vy * (iy - py)) >= zero)
    in
    can_happen a && can_happen b
  in
  List.filter (
    fun (a, b, inter) -> is_inside inter && is_valid a b inter
  ) intersections |> List.length |> Int.to_string


let part2 input = 
  let hailstones = String.split_on_char '\n' input |> List.map (fun s -> let l = String.split_on_char '@' s |> List.map parse_point in List.hd l, List.nth l 1) in
  let pos0, vel0 = List.nth hailstones 0 in
  let pos1, vel1 = List.nth hailstones 1 in
  let pos2, vel2 = List.nth hailstones 2 in
  let p1, v1 = sub_point pos1 pos0, sub_point vel1 vel0 in
  let p2, v2 = sub_point pos2 pos0, sub_point vel2 vel0 in
  let t1 = Bigdecimal.(zero - (div ((dot (cross p1 p2) v2))) (dot (cross v1 p2) v2)) in
  let t2 = Bigdecimal.(zero - (div ((dot (cross p1 p2) v1))) (dot (cross p1 v2) v1)) in
  let c1 = add_point pos1 (scale_point vel1 t1) in
  let c2 = add_point pos2 (scale_point vel2 t2) in
  let v = scale_down_point (sub_point c2 c1) (Bigdecimal.(-) t2 t1) in
  let px, py, pz = sub_point c1 (scale_point v t1) in
  Bigdecimal.(px + py + pz |> to_string_no_sn)

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  