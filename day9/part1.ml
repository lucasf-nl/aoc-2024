let file = "input.txt"
let message = "Hello!"

open Str
open Buffer
open BatDynArray

let split_and_print input_string delimiter buf =
  (* Split the string using the provided delimiter *)
  let splitted_array = Str.split (Str.regexp delimiter) input_string |> Array.of_list in
  (* Print each element of the array *)
  Array.iter (fun element ->
    let charseq = String.to_seq element in
    match Seq.uncons charseq with
      | Some(c, _) -> Buffer.add_char buf c
      | None -> Printf.printf "):";
    
  ) splitted_array

let process_buffer buffer newbuf =
  let len = Buffer.length buffer in
  for i = 0 to len - 1 do
    let c = Buffer.nth buffer i in
    let n = Char.code c - 48 in

    for j = 1 to n do
      let is_filled = (i mod 2) == 0 in
      if is_filled then
        let d: int = i / 2 in
        BatDynArray.add newbuf d
      else
        let v = -1 in
        BatDynArray.add newbuf v
    done
  done

let log_newbuf newbuf =
  let nlen = BatDynArray.length newbuf in
  for i = 0 to nlen - 1 do
    let d: int = BatDynArray.get newbuf i in
    print_int d
  done

(* check if there's a . between numbers, not just if there is a . *)
(* found_empty states:
- 0: No empties found
- 1: Intial empty found
If 1 gets found while in the number branch it returns true *)
let space_left newbuf: bool =
  let nlen = BatDynArray.length newbuf in
  let found_empty = ref 0 in
  let rec loop i =
    if i >= nlen then
      false  (* If the loop finishes without returning true, return false *)
    else
      let nc = BatDynArray.get newbuf i in
      let c = -1 in
      if nc == c then
        found_empty := 1;

      let nc = BatDynArray.get newbuf i in
      let c = -1 in
      if nc != c then
        loop (i + 1)
      else
        let t = ref 0 in
        if found_empty != t then
          (* an empty space has been found in between 2 numbers *)
          true
        else
          loop (i + 1)  (* Otherwise, continue the loop *)
  in
  loop 0

let defrag newbuf =
  let icond = space_left newbuf in
  if icond == true then

    let cond = ref true in
    while !cond == true do
      let nlen = BatDynArray.length newbuf in
      let lchari = nlen -1 in
      let lchar = BatDynArray.get newbuf lchari in

      (* find the first empty spot *)
      let predicament v = v == -1 in
      let fesi = BatDynArray.findi predicament newbuf in
      let lcharf x = lchar in
      BatDynArray.upd newbuf fesi lcharf;
      BatDynArray.delete_last newbuf;

      let condnew = space_left newbuf in
      cond := condnew;
    done

let checksum dynarr: int =
  let nlen = BatDynArray.length dynarr in
  let sum = ref 0 in
  for i = 0 to nlen - 1 do
    let d: int = BatDynArray.get dynarr i in
    sum := !sum + (i * d);
  done;
  print_int !sum;
  !sum

let () =
  let ic = open_in file in
  let ibuf = Buffer.create 16 in
  let newbuf = BatDynArray.create () in

  let line = input_line ic in

  let delimiter = "" in
  split_and_print line delimiter ibuf;

  process_buffer ibuf newbuf;

  defrag newbuf;
  checksum newbuf;

  close_in ic

(* this implementation worked first try! (: *)