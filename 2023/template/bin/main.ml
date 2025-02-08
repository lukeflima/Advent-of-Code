open Lwt
open Cohttp
open Cohttp_lwt_unix

let copy_file src dst =
  let ic = open_in_bin src in
  let oc = open_out_bin dst in
  let buffer = Bytes.create 4096 in
  let rec copy () =
    let len = input ic buffer 0 (Bytes.length buffer) in
    if len > 0 then (
      output oc buffer 0 len;
      copy ()
    )
  in
  copy ();
  close_in ic;
  close_out oc

(* Function to recursively walk a directory and copy files *)
let rec walk_and_copy src_dir dst_dir =
  let files = Sys.readdir src_dir in
  Array.iter (fun file ->
    let src_path = Filename.concat src_dir file in
    let dst_path = Filename.concat dst_dir file in
    if Sys.is_directory src_path then (
      (* If it's a directory, create the corresponding directory in the destination *)
      Sys.mkdir dst_path 0o755; (* 0o755 sets read/write/execute permissions *)
      walk_and_copy src_path dst_path (* Recursively copy its contents *)
    ) else (
      (* If it's a file, copy it *)
      copy_file src_path dst_path
    )
  ) files

let download day =
  let session = match (Sys.getenv_opt "SESSION_ID") with Some s -> s | None -> "" in
  let session = Bytes.sub_string (String.to_bytes session) 1 (String.length session - 2) in
  let url_day = Printf.sprintf "https://adventofcode.com/2023/day/%d/input" day in 
  let headers = Header.init_with "cookie" (Printf.sprintf "session=%s" session) in
  Client.get ~headers (Uri.of_string url_day) >>= fun (resp, body) ->
    let code = Response.status resp in
    if code == `OK then
      body |> Cohttp_lwt.Body.to_string
    else
      exit(1)
  


let () =
  let day = int_of_string Sys.argv.(1) in
  let day_str = Printf.sprintf "day%02d" day in
  let src_dir = "template/template/" in
  let dst_dir = day_str in
  Dotenv.export () |> ignore;
  (* Create the destination directory if it doesn't exist *)
  if not (Sys.file_exists dst_dir) then
    Sys.mkdir dst_dir 0o755;
  (* Start the copy process *)
  walk_and_copy src_dir dst_dir;
  let oc =  dst_dir ^ "/input.txt" |> Stdlib.open_out in
  let body = day |> download |> Lwt_main.run in
  Printf.printf "%d bytes\n" (String.length body);
  output oc (String.to_bytes body) 0 (String.length body);
  close_out oc


  