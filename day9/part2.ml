let file = "input.txt"
let message = "Hello!"

open Str
open Buffer
open BatDynArray

open Batteries

let expand_buffer input newbuf =
  let characters = Str.split (Str.regexp "") input |> Array.of_list in
  let id = ref 0 in
  Array.iteri (fun i character ->
      let charseq = String.to_seq character in
      match Seq.uncons charseq with
        | Some(c, _) -> 
          print_string "\n";
          print_char c;
          let ci = Char.code c in
          let v = ci - 48 in
          print_int v;
          id := !id + 1;
          let is_gap = i mod 2 == 1 in
          for iv = 0 to v - 1 do
            if is_gap then
              let v1 = -1 in
              BatDynArray.add newbuf v1;
            else
              let v = (!id - 1) / 2 in
              BatDynArray.add newbuf v;
          done
        | None -> Printf.printf "):";
    ) characters

let log_arr dynarr =
  BatDynArray.iter (fun i -> if i != -1 then print_int i else print_string ".") dynarr;
  print_string "\n"

(*
iterate over dynarr
if a -1 is found, reloop with count of +1
if at the same time, count is equal to size - 1, return i - count
if v is ever forid, exit to prevent a defrag refragging *)
let find_empty_spot dynarr size forid: int = 
  let dynarrlen = BatDynArray.length dynarr in
  let rec loop i spotcount =
    if i >= dynarrlen then
      -1
    else
      let v = BatDynArray.get dynarr i in
      if v = forid then
        -1
      else if v = -1 && spotcount = (size - 1) then
        i - spotcount
      else if v = -1 then
        loop (i + 1) (spotcount + 1)
      else
        let v = 0 in
        loop (i + 1) v
  in
  loop 0 0

let get_size_of_id (dynarr : int BatDynArray.t) (id : int) : int =
  let v = BatDynArray.reduce (fun c v -> if v == id then c + 1 else c) dynarr in
  if id = 0 then
    v + 1
  else
    v

let defragment rawdynarr =
  let nlen = BatDynArray.length rawdynarr in
  for i = 0 to nlen - 1 do
    let revdynarr = BatDynArray.rev rawdynarr in
    let v = BatDynArray.get revdynarr i in
    let size = get_size_of_id rawdynarr v in
    let first_spot = find_empty_spot rawdynarr size v in
    (* Printf.printf "ID: %i, size: %i, first_spot: %i\n" v size first_spot; *)
    (* log_arr rawdynarr; *)
    (* print_string "\n"; *)

    if v != -1 && first_spot != -1 then
      for s = 0 to size - 1 do
        (* replace original spot in rawdynarr with . *)
        BatDynArray.upd rawdynarr (nlen - i - s - 1) (fun i -> -1);
        (* print_int 1; *)
        (* place id in new spot *)
        BatDynArray.upd rawdynarr (first_spot + s) (fun i -> v);
      done

  done
  

let checksum dynarr: int =
  let nlen = BatDynArray.length dynarr in
  let sum = ref 0 in
  for i = 0 to nlen - 1 do
    let d: int = BatDynArray.get dynarr i in
    if d > 0 then
      sum := !sum + (i * d);
  done;
  print_int !sum;
  !sum

let () =
  let ic = open_in file in
  let ibuf = BatDynArray.create () in

  let line = input_line ic in
  print_string line;

  expand_buffer line ibuf;
  print_string "\n\n";
  log_arr ibuf;
  print_string "\n\n";
  let v = find_empty_spot ibuf 2 1 in print_int v;
  (* print_string "\n\n"; *)
  defragment ibuf;
  (* print_string "\n\n"; *)
  (* log_arr ibuf; *)
  print_string "\n\n";

  checksum ibuf;

  close_in ic

(* this implementation worked first try! (: *)