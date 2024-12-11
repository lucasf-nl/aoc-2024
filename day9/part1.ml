let file = "input.txt"
let message = "Hello!"

open Str
open Buffer
open BatDynArray

let split_and_print input_string delimiter buf =
  (* Split the string using the provided delimiter *)
  let splitted_array = Str.split (Str.regexp delimiter) input_string |> Array.of_list in
  (* Print each element of the array *)
  (*Array.iter print_endline splitted_array*)
  Array.iter (fun element ->
    let charseq = String.to_seq element in
    match Seq.uncons charseq with
      | Some(c, _) -> Buffer.add_char buf c
      | None -> Printf.printf "):";
    
    (*let char = Seq.take 1 charseq in
    Buffer.add_char buf char*)
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
      (* print_endline "another try"; *)
      (* log_newbuf newbuf; *)

      let nlen = BatDynArray.length newbuf in
      let lchari = nlen -1 in
      let lchar = BatDynArray.get newbuf lchari in

      (* print_endline "";
      print_int lchar; *)

      (* find the first empty spot *)
      let predicament v = v == -1 in
      let fesi = BatDynArray.findi predicament newbuf in
      let lcharf x = lchar in
      BatDynArray.upd newbuf fesi lcharf;
      BatDynArray.delete_last newbuf;

      (* print_endline "";
      log_newbuf newbuf; *)

      let condnew = space_left newbuf in
      cond := condnew;

      (* if condnew == true then
        print_endline "another loop"
      else
        print_endline "should end" *)

      (* print_string "UwU" *)
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
  (*let input = "hello,world,how,are,you" in
  let delimiter = "" in
  split_and_print input delimiter;*)

  (* Read file and display the first line *)
  let ic = open_in file in
  let ibuf = Buffer.create 16 in
  let newbuf = BatDynArray.create () in
  (* try *)
    let line = input_line ic in
    (* read line, discard \n *)
    (* print_endline line; *)

    let delimiter = "" in
    split_and_print line delimiter ibuf;

    process_buffer ibuf newbuf;

    (* let r = space_left newbuf in
    if r == true then
      print_string "wee\n"
    else
      print_string "woo\n"; *)

    (* log_newbuf newbuf; *)
    defrag newbuf;
    checksum newbuf;

    (* write the result to stdout *)
    (* flush stdout; *)
    (* write on the underlying device now *)
    close_in ic
    (* close the input channel *)
  (* with e ->
    (* some unexpected exception occurs *)
    close_in_noerr ic;
    (* emergency closing *)
    raise e *)

(* exit with error: files are closed but channels are not flushed *)

(* normal exit: all channels are flushed and closed *)

(* this implementation worked first try! (: *)