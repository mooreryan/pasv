open! Core
open Pasv_lib
open Pasv_lib.Mod

let write_tmp_file data =
  let fname =
    Filename.concat (Caml.Filename.get_temp_dir_name ()) "check_aln_test.txt"
  in
  let () =
    match Caml.Sys.file_exists fname with
    | true -> Caml.Sys.remove fname
    | false -> ()
  in
  let chan = Out_channel.create fname in
  let () = Out_channel.output_string chan data in
  let () = Out_channel.flush chan in
  let () = Out_channel.close chan in
  (fname, chan)

let%expect_test "boundary missing in position map" =
  let map = Position.Map_wrt.empty_zero_raw_aln () in
  let boundary = Position.zero_raw_of_int 47 in
  let x = Check_alignment.map_roi_boundary map (Some boundary) in
  match x with
  | Ok _ -> assert false
  | Error err ->
      print_endline @@ Error.to_string_hum err;
      [%expect {| ("key not found" 47) |}]

let positions = Position.List.one_raw_of_list [ 2; 3; 4 ]
let roi_start_zero_raw = None
let roi_end_zero_raw = None
let out_channel = Stdio.stdout

let%expect_test "streaming version key seq first" =
  let key_ref = [%string ">%{Utils.key_reference_id}\nYABC----Y\n"] in
  let ref2 = [%string ">%{Utils.reference_id_prefix}2\nY---EFGGY\n"] in
  let query = ">query_ABC\nYABC----Y\n" in
  let infile, _chan =
    write_tmp_file @@ String.concat ~sep:"" [ key_ref; ref2; query ]
  in
  print_s @@ [%sexp_of: unit Or_error.t]
  @@ Check_alignment.parse_alignment_file_with_pasv_refs_streaming ~infile
       ~positions ~roi_start_zero_raw ~roi_end_zero_raw ~out_channel;
  [%expect {|
    query_ABC	A	B	C	ABC	NA	NA	NA
    (Ok ()) |}]

let%expect_test "streaming version query first, key seq last" =
  let key_ref = [%string ">%{Utils.key_reference_id}\nYABC----Y\n"] in
  let ref2 = [%string ">%{Utils.reference_id_prefix}2\nY---EFGGY\n"] in
  let query = ">query_ABC\nYABC----Y\n" in
  let infile, _chan =
    write_tmp_file @@ String.concat ~sep:"" [ query; ref2; key_ref ]
  in
  print_s @@ [%sexp_of: unit Or_error.t]
  @@ Check_alignment.parse_alignment_file_with_pasv_refs_streaming ~infile
       ~positions ~roi_start_zero_raw ~roi_end_zero_raw ~out_channel;
  [%expect {|
    query_ABC	A	B	C	ABC	NA	NA	NA
    (Ok ()) |}]

let%expect_test "streaming version key seq first" =
  let key_ref = [%string ">%{Utils.key_reference_id}\nY---EFGGY\n"] in
  let ref2 = [%string ">%{Utils.reference_id_prefix}2\nYABC----Y\n"] in
  let query = ">query_---\nYABC----Y\n" in
  let infile, _chan =
    write_tmp_file @@ String.concat ~sep:"" [ key_ref; ref2; query ]
  in
  print_s @@ [%sexp_of: unit Or_error.t]
  @@ Check_alignment.parse_alignment_file_with_pasv_refs_streaming ~infile
       ~positions ~roi_start_zero_raw ~roi_end_zero_raw ~out_channel;
  [%expect {|
    query_---	-	-	-	---	NA	NA	NA
    (Ok ()) |}]

let%expect_test "streaming version query first, key seq last" =
  let key_ref = [%string ">%{Utils.key_reference_id}\nY---EFGGY\n"] in
  let ref2 = [%string ">%{Utils.reference_id_prefix}2\nYABC----Y\n"] in
  let query = ">query_---\nYABC----Y\n" in
  let infile, _chan =
    write_tmp_file @@ String.concat ~sep:"" [ query; ref2; key_ref ]
  in
  print_s @@ [%sexp_of: unit Or_error.t]
  @@ Check_alignment.parse_alignment_file_with_pasv_refs_streaming ~infile
       ~positions ~roi_start_zero_raw ~roi_end_zero_raw ~out_channel;
  [%expect {|
    query_---	-	-	-	---	NA	NA	NA
    (Ok ()) |}]

let%test_unit "streaming version no key ref" =
  let ref2 = [%string ">%{Utils.reference_id_prefix}2\nYABC----Y\n"] in
  let query = ">query_---\nYABC----Y\n" in
  let infile, _chan = write_tmp_file @@ String.concat ~sep:"" [ query; ref2 ] in
  let result =
    Check_alignment.parse_alignment_file_with_pasv_refs_streaming ~infile
      ~positions ~roi_start_zero_raw ~roi_end_zero_raw ~out_channel
  in
  assert (Or_error.is_error result)

let%test_unit "streaming version no queries" =
  let key_ref = [%string ">%{Utils.key_reference_id}\nYABC----Y\n"] in
  let ref2 = [%string ">%{Utils.reference_id_prefix}2\nY---EFGGY\n"] in
  let infile, _chan =
    write_tmp_file @@ String.concat ~sep:"" [ key_ref; ref2 ]
  in
  let result =
    Check_alignment.parse_alignment_file_with_pasv_refs_streaming ~infile
      ~positions ~roi_start_zero_raw ~roi_end_zero_raw ~out_channel
  in
  assert (Or_error.is_error result)
