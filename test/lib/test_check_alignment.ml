open! Core
open Pasv_lib
open Pasv_lib.Mod

let%expect_test "boundary missing in position map" =
  let map = Position.Map_wrt.empty_zero_raw_aln () in
  let boundary = Position.zero_raw_of_int 47 in
  let x = Check_alignment.map_roi_boundary map (Some boundary) in
  match x with
  | Ok _ ->
      assert false
  | Error err ->
      print_endline @@ Error.to_string_hum err ;
      [%expect {| ("key not found" 47) |}]
