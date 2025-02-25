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

type handType =
    FiveOfAKind
  | FourOfAKind
  | FullHouse
  | ThreeOfAKind
  | TwoPairs
  | OnePair
  | HighCard
  
type hand = {
  hand: string;
  typ: handType;
  bid: int;
}


let list_of_string s = String.to_seq s |> List.of_seq

let get_hand_type hand =
  let cards = list_of_string hand in
  let card_counts = List.fold_left (fun ht card -> 
    let count = Hashtbl.find_opt ht card |> Option.value ~default:0 in
    Hashtbl.replace ht card (count + 1);
    ht
  ) (Hashtbl.create 0) cards in
  let max_count = Hashtbl.fold (fun _ v acc -> max acc v) card_counts 0 in
  if max_count == 5 then FiveOfAKind
  else if max_count == 4 then FourOfAKind
  else if max_count == 3 then
    if Hashtbl.length card_counts == 2 then FullHouse
    else ThreeOfAKind
  else if max_count == 2 then
    if Hashtbl.length card_counts == 3 then TwoPairs
    else OnePair
  else HighCard

let get_hand_type_value typ =
  match typ with
  | FiveOfAKind -> 6
  | FourOfAKind -> 5
  | FullHouse -> 4
  | ThreeOfAKind -> 3
  | TwoPairs -> 2
  | OnePair -> 1
  | HighCard -> 0

let get_card_value c =
  match c with
  | 'A' -> 12
  | 'K' -> 11
  | 'Q' -> 10
  | 'J' -> 9
  | 'T' -> 8
  | '9' -> 7
  | '8' -> 6
  | '7' -> 5
  | '6' -> 4
  | '5' -> 3
  | '4' -> 2
  | '3' -> 1
  | '2' -> 0
  | _ -> failwith "Invalid card"

let compare_hands get_card_value a b =
  let a_val = get_hand_type_value a.typ in
  let b_val = get_hand_type_value b.typ in
  if a_val > b_val then 1
  else if a_val < b_val then -1
  else 
    List.fold_left2 (fun acc a b ->
      if acc == 0 then
        let a = get_card_value a in
        let b = get_card_value b in
        if a > b then 1
        else if a < b then -1
        else 0
      else acc
    ) 0 (list_of_string a.hand) (list_of_string b.hand)

let part1 input = 
  let lines = String.split_on_char '\n' input in
  let parse_line line =
    let parts = String.split_on_char ' ' line in
    let hand = List.nth parts 0 in
    let bid = List.nth parts 1 |> int_of_string in
    let typ = get_hand_type hand in
    { hand = hand; typ = typ; bid = bid }
  in
  let hands = List.map parse_line lines in
  let hands = List.sort (compare_hands get_card_value) hands in
  let res, _ = List.fold_left (fun (acc, i) h -> (acc + i * h.bid), i + 1) (0, 1) hands in
  string_of_int res

let get_card_value c =
    match c with
    | 'A' -> 12
    | 'K' -> 11
    | 'Q' -> 10
    | 'T' -> 8
    | '9' -> 7
    | '8' -> 6
    | '7' -> 5
    | '6' -> 4
    | '5' -> 3
    | '4' -> 2
    | '3' -> 1
    | '2' -> 0
    | 'J' -> -1
    | _ -> failwith "Invalid card"

let get_hand_type hand =
  let cards = list_of_string hand in
  let card_counts = List.fold_left (fun ht card -> 
    let count = Hashtbl.find_opt ht card |> Option.value ~default:0 in
    Hashtbl.replace ht card (count + 1);
    ht
  ) (Hashtbl.create 0) cards in
  let jokers = Hashtbl.find_opt card_counts 'J' |> Option.value ~default:0 in
  Hashtbl.remove card_counts 'J';
  let max_count = Hashtbl.fold (fun _ v acc -> max acc v) card_counts 0 + jokers in
  if max_count == 5 then FiveOfAKind
  else if max_count == 4 then FourOfAKind
  else if max_count == 3 then
    if Hashtbl.length card_counts == 2 then FullHouse
    else ThreeOfAKind
  else if max_count == 2 then
    if Hashtbl.length card_counts == 3 then TwoPairs
    else OnePair
  else HighCard

let part2 input = 
  let lines = String.split_on_char '\n' input in
  let parse_line line =
    let parts = String.split_on_char ' ' line in
    let hand = List.nth parts 0 in
    let bid = List.nth parts 1 |> int_of_string in
    let typ = get_hand_type hand in
    { hand = hand; typ = typ; bid = bid }
  in
  let hands = List.map parse_line lines in
  let hands = List.sort (compare_hands get_card_value)  hands in
  let res, _ = List.fold_left (fun (acc, i) h -> (acc + i * h.bid), i + 1) (0, 1) hands in
  string_of_int res

(* let input = "sample.txt" *)
let input = "input.txt"

let () =
  let input = read_file input |> String.trim in
  print_string "Part 1: "; 
  print_endline (part1 input);
  print_string "Part 2: "; 
  print_endline (part2 input);
  