open! Core
open Pasv_lib

let%test_unit "rm_rf" =
  let dir = "apple" in
  Unix.mkdir dir ;
  assert (Utils.is_directory dir) ;
  let name = "pie" in
  let filename = Filename.concat dir name in
  Out_channel.write_all filename ~data:"thing" ;
  assert (Utils.is_file filename) ;
  Utils.rm_rf dir ;
  assert (not (Utils.is_file filename)) ;
  assert (not (Utils.is_directory dir)) ;
  assert (Unit.(Utils.rm_rf dir = ()))

let%test_unit "try1" =
  let f x = 1 / x in
  assert (Or_error.is_ok @@ Utils.try1 f 1) ;
  assert (Or_error.is_error @@ Utils.try1 f 0)
