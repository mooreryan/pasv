open! Core
open Little_logger

let key_reference_id = "______pasv_key_reference______"

let is_key_reference record =
  String.(Bio_io.Fasta_record.id record = key_reference_id)

let reference_id_prefix = "______pasv_reference______seq_"

let make_reference_id i = reference_id_prefix ^ Int.to_string i

let reference_id_prefix_re =
  Re2.create_exn "^______pasv_reference______seq_[0-9]+$"

let is_reference record =
  Re2.matches reference_id_prefix_re @@ Bio_io.Fasta_record.id record

let is_file name =
  match Sys.is_file name with `Yes -> true | `No | `Unknown -> false

let is_directory name =
  match Sys.is_directory name with `Yes -> true | `No | `Unknown -> false

(* See
   https://github.com/ocaml/dune/commit/154272b779fe8943a9ce1b4afabb30150ab94ba6 *)

(* let ( ^/ ) = Filename.concat *)

(* Return list of entries in [path] as [path/entry] *)
let readdir path =
  Array.fold ~init:[]
    ~f:(fun acc entry -> Filename.concat path entry :: acc)
    (Sys.readdir path)

(* May raise some unix errors? *)
let rec rm_rf name =
  match Unix.lstat name with
  | {st_kind= S_DIR; _} ->
      List.iter (readdir name) ~f:rm_rf ;
      Unix.rmdir name
  | _ ->
      Unix.unlink name
  | exception Unix.Unix_error (ENOENT, _, _) ->
      ()

let clean_up keep_intermediate_files filenames =
  if not keep_intermediate_files then
    List.iter filenames ~f:(fun filename ->
        if is_file filename then rm_rf filename )

(* The infile will either be queries or an alignment. It is where the basename
   comes from. *)
let make_signatures_filename ~infile ~outdir =
  let queries = Fname.of_string infile in
  let dir = outdir in
  Filename.concat dir [%string "%{queries.Fname.basename}.pasv_signatures.tsv"]

let make_outdir outdir force =
  let open Or_error in
  match (is_directory outdir, force) with
  | true, true ->
      (* The outdir exists, but --force is given so just keep going. *)
      return ()
  | true, false ->
      (* The outdir exists, but --force is NOT given so just keep going so
         that's an error. *)
      errorf "--outdir '%s' already exists but --force was not given" outdir
  | false, _ ->
      (* If the dir doesn't exist, make it regardless of the force option. *)
      return @@ Unix.mkdir_p outdir ~perm:0o755

let make_outdir_or_exit outdir force =
  match make_outdir outdir force with
  | Ok () ->
      ()
  | Error err ->
      Logger.fatal (fun () -> Error.to_string_hum err) ;
      exit 1

let looks_like_fasta_file name =
  let buf = Buffer.create 1 in
  match
    In_channel.with_file name ~f:(fun chan ->
        In_channel.input_buffer chan buf ~len:1 )
  with
  | Some () ->
      let s = Buffer.contents buf in
      String.(s = ">")
  | None ->
      false

let assert_looks_like_fasta_file_or_exit name =
  if not (looks_like_fasta_file name) then (
    Logger.fatal (fun () ->
        [%string
          "file '%{name}' doesn't look like an fasta file.  Check the file \
           format!"] ) ;
    exit 1 )

(* HMMER3/f *)
let looks_like_hmm_file name =
  let buf = Buffer.create 8 in
  match
    In_channel.with_file name ~f:(fun chan ->
        In_channel.input_buffer chan buf ~len:8 )
  with
  | Some () ->
      let header = Buffer.contents buf in
      String.(header = "HMMER3/f")
  | None ->
      false

let assert_looks_like_hmm_file_or_exit name =
  if not (looks_like_hmm_file name) then (
    Logger.fatal (fun () ->
        [%string
          "file '%{name}' doesn't look like an hmm file.  Check the file \
           format!"] ) ;
    exit 1 )

let default_clustalo_other_aln_params = "--threads=1"

let default_mafft_other_aln_params = "--thread 1 --auto"

let try1 f a =
  match f a with
  | exception exn ->
      Or_error.error "Caught exception" exn Exn.sexp_of_t
  | result ->
      Or_error.return result

(* Zero-based indexing from the end. *)
let get_from_end ary i =
  let index = Array.length ary - (i + 1) in
  if index < 0 || index >= Array.length ary then
    Or_error.errorf "Bad index (%d); ary length is (%d)." index
      (Array.length ary)
  else Or_error.return @@ Array.get ary index

let all_true l = List.fold l ~init:true ~f:( && )

let any_true l = List.fold l ~init:false ~f:( || )
