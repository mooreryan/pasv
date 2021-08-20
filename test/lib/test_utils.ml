open! Core
open Pasv_lib

let%test_unit _ =
  let dir = "apple" in
  Unix.mkdir dir;
  assert (Utils.is_directory dir);
  let name = "pie" in
  let filename = Filename.concat dir name in
  Out_channel.write_all filename ~data:"thing";
  assert (Utils.is_file filename);
  Utils.rm_rf dir;
  assert (not (Utils.is_file filename));
  assert (not (Utils.is_directory dir))
