open! Core
open Little_logger
open Mod

type common_opts = { outdir : string; force : bool; verbosity : Logger.Level.t }

exception Exn of string [@@deriving sexp]

(* Exits on error. *)
let assert_roi_good_or_exit ~(roi_start : ('indexing, 'wrt) Position.t option)
    ~(roi_end : ('indexing, 'wrt) Position.t option) =
  let open Option.Let_syntax in
  let%bind start = roi_start in
  let%map end_ = roi_end in
  if Position.(start >= end_) then (
    Logger.fatal (fun () ->
        let start = Int.to_string @@ Position.to_int start in
        let end_ = Int.to_string @@ Position.to_int end_ in
        [%string
          "ROI start (%{start}) is should be strictly less than ROI end \
           (%{end_})"]);
    exit 1)
  else ()

(* The pasv-select program opts and runner. *)
module Select = struct
  type opts = {
    query_file : string;
    signature_file : string;
    signature_list : string list;
    reject : bool;
    fixed_strings : bool;
  }

  (* Zero-based indexing from the end. *)
  let get_from_end ary i = Array.get ary (Array.length ary - (i + 1))

  let all_true l = List.fold l ~init:true ~f:( && )
  let any_true l = List.fold l ~init:false ~f:( || )

  (* Checks a bunch of stuff. Logs errors if things fail. Returns true if there
     were no failures, false if there was at least one failure. *)
  let check_sig_file_header line =
    (* This is kind of weird code, but I want to warn the user about every error
       that we can see rather than the first failing error. *)
    let check_length ary =
      let len = Array.length ary in
      let is_good = len > 5 in
      if not is_good then
        Logger.error (fun () ->
            [%string
              "Signature file should have 6 or more columns.  Got %{len#Int}."]);
      is_good
    in
    let check_name_col ary =
      let s = ary.(0) in
      let is_good = String.(s = "name") in
      if not is_good then
        Logger.error (fun () ->
            [%string
              "The first column of the signature file should be 'name'.  Got \
               '%{s}'."]);
      is_good
    in
    let check_spans_col ary =
      let s = get_from_end ary 0 in
      let is_good = String.(s = "spans") in
      if not is_good then
        Logger.error (fun () ->
            [%string
              "The last column the signature file should be 'spans'.  Got \
               '%{s}'."]);
      is_good
    in
    let check_spans_end_col ary =
      let s = get_from_end ary 1 in
      let is_good = String.(s = "spans_end") in
      if not is_good then
        Logger.error (fun () ->
            [%string
              "The second to last column the signature file should be \
               'spans_end'.  Got '%{s}'."]);
      is_good
    in
    let check_spans_start_col ary =
      let s = get_from_end ary 2 in
      let is_good = String.(s = "spans_start") in
      if not is_good then
        Logger.error (fun () ->
            [%string
              "The third to last column the signature file should be \
               'spans_start'.  Got '%{s}'."]);
      is_good
    in
    let check_signature_col ary =
      let s = get_from_end ary 3 in
      let is_good = String.(s = "signature") in
      if not is_good then
        Logger.error (fun () ->
            [%string
              "The fourth to last column the signature file should be \
               'signature'.  Got '%{s}'."]);
      is_good
    in
    let header = String.split line ~on:'\t' |> Array.of_list in
    let length_good = check_length header in
    let name_col_good = check_name_col header in
    let spans_col_good = check_spans_col header in
    let spans_end_col_good = check_spans_end_col header in
    let spans_start_col_good = check_spans_start_col header in
    let signature_col_good = check_signature_col header in
    let checks =
      [
        length_good;
        name_col_good;
        spans_col_good;
        spans_end_col_good;
        spans_start_col_good;
        signature_col_good;
      ]
    in
    all_true checks

  let run (common_opts : common_opts) (opts : opts) =
    Logger.set_printer prerr_endline;
    Utils.make_outdir_or_exit common_opts.outdir common_opts.force;
    Utils.assert_looks_like_fasta_file_or_exit opts.query_file;
    let match_fun =
      match (opts.fixed_strings, opts.reject) with
      | true, true -> fun ~test ~actual -> String.(test <> actual)
      | true, false -> fun ~test ~actual -> String.(test = actual)
      | false, true ->
          (* TODO create rather than create_exn; make once rather than everytime
             this function is called. *)
          fun ~test ~actual -> not @@ Re2.matches (Re2.create_exn test) actual
      | false, false ->
          fun ~test ~actual -> Re2.matches (Re2.create_exn test) actual
    in
    let keep_these =
      (* Get the header and check it. *)
      let read_and_check_header chan =
        match In_channel.input_line chan with
        | None ->
            Logger.fatal (fun () ->
                [%string
                  "Signature file '%{opts.signature_file}' has no lines!"]);
            exit 1
        | Some header ->
            if check_sig_file_header header then
              Array.of_list @@ String.split header ~on:'\t'
            else (
              Logger.fatal (fun () ->
                  [%string
                    "Signature file '%{opts.signature_file}' has a bad header!"]);
              exit 1)
      in
      let get_signature ary = get_from_end ary 3 in
      In_channel.with_file opts.signature_file ~f:(fun chan ->
          let header = read_and_check_header chan in
          let expected_num_cols = Array.length header in
          In_channel.fold_lines chan
            ~init:(Map.empty (module String))
            ~f:(fun acc line ->
              let ary = Array.of_list @@ String.split line ~on:'\t' in
              let num_cols = Array.length ary in
              if num_cols <> expected_num_cols then (
                Logger.fatal (fun () ->
                    [%string
                      "Line '%{line}' had %{num_cols#Int} but should have had \
                       %{expected_num_cols#Int}"]);
                exit 1);
              let signature = get_signature ary in
              let keep =
                let any_fun = if opts.reject then all_true else any_true in
                any_fun
                @@ List.map opts.signature_list ~f:(fun test_sig ->
                       match_fun ~test:test_sig ~actual:signature)
              in
              if keep then (
                let name = ary.(0) in
                match Map.add acc ~key:name ~data:signature with
                | `Ok map -> map
                | `Duplicate ->
                    Logger.fatal (fun () ->
                        [%string
                          "Name %{name} was duplicated in the signatures file"]);
                    exit 1)
              else acc))
    in
    if Map.length keep_these < 1 then
      Logger.warning (fun () ->
          [%string
            "There were no IDs to keep!  Outdir '%{common_opts.outdir}' will \
             be empty.  Check your signatures and make sure they're correct!"]);
    let make_partition_filename ~outdir ~signature =
      Filename.concat outdir [%string "signature_%{signature}.fa"]
    in
    match
      Bio_io.Fasta_in_channel.with_file_fold_records opts.query_file
        ~init:(Map.empty (module String))
        ~f:(fun outfiles record ->
          let open Bio_io.Fasta_record in
          let id = id record in
          match Map.find keep_these id with
          | None -> outfiles
          | Some signature ->
              (* Make sure the signature has an outfile. *)
              let outfiles =
                let name =
                  make_partition_filename ~outdir:common_opts.outdir ~signature
                in
                let out_chan = Out_channel.create name in
                match Map.add outfiles ~key:signature ~data:out_chan with
                | `Ok new_ -> new_
                | `Duplicate -> outfiles
              in
              let out_chan =
                (* _exn okay since we just added it. *)
                Map.find_exn outfiles signature
              in
              Out_channel.output_lines out_chan [ to_string record ];
              outfiles)
    with
    | Ok out_channels ->
        Map.iteri out_channels ~f:(fun ~key:signature ~data:out_chan ->
            match Utils.try1 Out_channel.close out_chan with
            | Ok _ -> ()
            | Error err ->
                Logger.warning (fun () ->
                    let msg = Error.to_string_hum err in
                    [%string
                      "Error closing out channel for signature %{signature}.  \
                       Error: %{msg}."]))
    | Error err ->
        Logger.fatal (fun () ->
            let msg = Error.to_string_hum err in
            [%string "There was an error parsing query file: %{msg}"])
end

module Check = struct
  type opts = {
    alignment : string;
    key_residues : (Position.one_indexed, Position.raw) Position.List.t;
    roi_start : Position.one_indexed_raw option;
    roi_end : Position.one_indexed_raw option;
  }

  let run (common_opts : common_opts) (opts : opts) =
    Logger.set_printer prerr_endline;
    Utils.assert_looks_like_fasta_file_or_exit opts.alignment;
    Utils.make_outdir_or_exit common_opts.outdir common_opts.force;
    let signatures_filename =
      Utils.make_signatures_filename ~infile:opts.alignment
        ~outdir:common_opts.outdir
    in
    let open Check_alignment in
    let roi_start = Option.map opts.roi_start ~f:Position.one_to_zero in
    let roi_end = Option.map opts.roi_end ~f:Position.one_to_zero in
    let (_ : unit option) = assert_roi_good_or_exit ~roi_start ~roi_end in
    let sig_file_header = make_signature_file_header opts.key_residues in
    match
      check_alignment ~positions:opts.key_residues
        ~infile:(Check_alignment.Basic opts.alignment) ~roi_start ~roi_end
    with
    | Ok signatures ->
        write_signatures ~filename:signatures_filename ~header:sig_file_header
          signatures
    | Error err ->
        Logger.fatal (fun () ->
            "\n" ^ Error.to_string_hum
            @@ Error.tag err ~tag:"Error running pasv check");
        exit 1
end

module Hmm = struct
  type opts = {
    queries : string;
    references : string;
    key_reference : string;
    key_residues : (Position.one_indexed, Position.raw) Position.List.t;
    keep_intermediate_files : bool;
    hmmalign : string;
    roi_start : Position.one_indexed_raw option;
    roi_end : Position.one_indexed_raw option;
  }

  let handle_hmmalign_error (out : Runners.Hmmalign.out) err =
    Logger.fatal (fun () ->
        let header = "There was an error running hmmalign" in
        let err = Error.to_string_hum err in
        let stdout_header = "== hmmalign stdout ==" in
        let stderr_header = "== hmmalign stderr ==" in
        [%string
          "%{header}\n\
           %{err}\n\
           %{stdout_header}\n\
           %{out.stdout}\n\
           %{stderr_header}\n\
           %{out.stderr}"])

  let make_queries_temp_file in_dir =
    let prefix = "pasv" in
    let suffix = ".queries.fasta" in
    Filename.temp_file ~perm:0o755 ~in_dir prefix suffix

  (* Doesn't bother checking if more than one sequence was passed in. *)
  let get_key_ref_seq_exn filename =
    let open Bio_io.Fasta_in_channel in
    let open Bio_io.Fasta_record in
    with_file_exn filename ~f:(fun chan ->
        match input_record_exn chan with
        | Some record -> with_desc None record |> with_id Utils.key_reference_id
        | None -> raise (Exn "No fasta records in key_reference file"))

  let output_record chan record =
    Out_channel.output_string chan (Bio_io.Fasta_record.to_string record ^ "\n")

  let cat_records_exn in_filename out_chan =
    let open Bio_io in
    Fasta_in_channel.with_file_iter_records_exn in_filename ~f:(fun record ->
        output_record out_chan record)

  (* We need to add the key reference sequence to the top of the the queries
     file, then run that. Also, need to give the thing a special name so we can
     check for it.

     pasv v1 put simple headers on the sequences to be able to get the exact
     header back since some alignment programs mangle headers. *)
  let make_queries_file_exn (common_opts : common_opts) (opts : opts) =
    let key_sequence = get_key_ref_seq_exn opts.key_reference in
    let tempfile_name = make_queries_temp_file common_opts.outdir in
    Out_channel.with_file tempfile_name ~f:(fun out_chan ->
        output_record out_chan key_sequence;
        cat_records_exn opts.queries out_chan);
    tempfile_name

  let make_aln_filename ~infile ~outdir =
    let queries = Fname.of_string infile in
    let basename = queries.Fname.basename in
    let filename = Filename.concat outdir [%string "%{basename}.aln.fa"] in
    filename

  let run (common_opts : common_opts) (opts : opts) =
    Logger.set_printer prerr_endline;
    Utils.make_outdir_or_exit common_opts.outdir common_opts.force;
    Utils.assert_looks_like_hmm_file_or_exit opts.references;
    Utils.assert_looks_like_fasta_file_or_exit opts.queries;
    Utils.assert_looks_like_fasta_file_or_exit opts.key_reference;
    let hmmalign_filename =
      make_aln_filename ~infile:opts.queries ~outdir:common_opts.outdir
    in
    let signatures_filename =
      Utils.make_signatures_filename ~infile:opts.queries
        ~outdir:common_opts.outdir
    in
    let queries_filename = make_queries_file_exn common_opts opts in
    let hmmalign_out =
      Runners.Hmmalign.run
        {
          exe = opts.hmmalign;
          queries = queries_filename;
          targets = opts.references;
          outfile = hmmalign_filename;
        }
    in
    let () =
      match hmmalign_out.result with
      | Ok () -> (
          let open Check_alignment in
          let roi_start = Option.map opts.roi_start ~f:Position.one_to_zero in
          let roi_end = Option.map opts.roi_end ~f:Position.one_to_zero in
          let (_ : unit option) = assert_roi_good_or_exit ~roi_start ~roi_end in
          let sig_file_header = make_signature_file_header opts.key_residues in
          match
            check_alignment ~positions:opts.key_residues
              ~infile:(Check_alignment.With_pasv_refs hmmalign_out.opts.outfile)
              ~roi_start ~roi_end
          with
          | Ok signatures ->
              write_signatures ~filename:signatures_filename
                ~header:sig_file_header signatures
          | Error err ->
              Logger.fatal (fun () ->
                  "\n" ^ Error.to_string_hum
                  @@ Error.tag err ~tag:"Error running pasv hmm");
              exit 1)
      | Error err ->
          handle_hmmalign_error hmmalign_out err;
          exit 1
    in
    Utils.clean_up opts.keep_intermediate_files
      [ hmmalign_filename; queries_filename ]
end

module Msa = struct
  type opts = {
    queries : string;
    references : string;
    key_residues : (Position.one_indexed, Position.raw) Position.List.t;
    keep_intermediate_files : bool;
    aligner : Runners.Msa.aligner;
    other_parameters : string;
    jobs : int;
    max_retries : int;
    roi_start : Position.one_indexed_raw option;
    roi_end : Position.one_indexed_raw option;
  }

  let get_signature msa_out outfile (opts : opts) =
    match msa_out with
    | Ok _stdout -> (
        let open Check_alignment in
        let roi_start = Option.map opts.roi_start ~f:Position.one_to_zero in
        let roi_end = Option.map opts.roi_end ~f:Position.one_to_zero in
        let (_ : unit option) = assert_roi_good_or_exit ~roi_start ~roi_end in
        let open Or_error.Let_syntax in
        let%bind signatures =
          check_alignment ~positions:opts.key_residues
            ~infile:(Check_alignment.With_pasv_refs outfile) ~roi_start ~roi_end
        in
        match Array.length signatures with
        | 1 -> Or_error.return @@ signatures.(0)
        | n -> Or_error.errorf "Expected to find 1 signature, but got %d." n)
    | Error err ->
        Or_error.errorf "Error running msa: %s" (Error.to_string_hum err)

  let write_msa_infile filename references query =
    let refs =
      List.mapi references ~f:(fun i reference ->
          let open Bio_io.Fasta_record in
          let id =
            if Int.(i = 0) then Utils.key_reference_id
            else Utils.make_reference_id i
          in
          reference |> with_desc None |> with_id id |> to_string)
    in
    Out_channel.with_file filename ~f:(fun chan ->
        Out_channel.output_lines chan refs;
        Out_channel.output_string chan
          (Bio_io.Fasta_record.to_string query ^ "\n"))

  let make_msa_filenames outdir i =
    let infile =
      Filename.concat outdir [%string "refs_and_query_%{i#Int}.fa"]
    in
    let outfile =
      Filename.concat outdir [%string "refs_and_query_%{i#Int}.aln.fa"]
    in
    (infile, outfile)

  let get_msa_query_signature common_opts (opts : opts) references query_i query
      =
    let open Async in
    let msa_infile_name, msa_outfile_name =
      make_msa_filenames common_opts.outdir query_i
    in
    let () = write_msa_infile msa_infile_name references query in
    let%bind msa_out =
      let msa_opts : Runners.Msa.opts =
        {
          infile = msa_infile_name;
          outfile = msa_outfile_name;
          other_parameters = opts.other_parameters;
          max_retries = opts.max_retries;
        }
      in
      Runners.Msa.run msa_opts opts.aligner
    in

    let signature = get_signature msa_out msa_outfile_name opts in
    let () =
      Utils.clean_up opts.keep_intermediate_files
        [ msa_infile_name; msa_outfile_name ]
    in
    Async.Deferred.return signature

  (* If there is an error, it is logged and then ignored. *)
  let write_query_signature query_signature writer =
    match query_signature with
    | Ok signature ->
        Async.Writer.write_line writer signature;
        Async.Deferred.return 1
    | Error err ->
        Logger.error (fun () -> Error.to_string_hum err);
        Async.Deferred.return 0

  (* Get the signature then write the output as it is available. This way if the
     program crashes, the user still has some output to work with and
     examine. *)
  let get_and_write_sig signature_filename common_opts (opts : opts) references
      query_i query =
    Logger.info (fun () -> sprintf "Working on query %d" (query_i + 1));
    let signature =
      get_msa_query_signature common_opts opts references query_i query
    in
    Async.Deferred.bind signature ~f:(fun signature ->
        Async.Writer.with_file signature_filename ~append:true
          ~f:(write_query_signature signature))

  let sig_file_write_results_good results =
    let sum = List.fold results ~init:0 ~f:( + ) in
    sum > 0

  (* Check for common problem when setting alignment parameters. *)
  let fix_aln_params opts =
    match opts.aligner with
    | Clustalo _path -> Or_error.return opts
    | Mafft _path ->
        if
          String.(
            opts.other_parameters = Utils.default_clustalo_other_aln_params)
        then
          (* The user kept the default clustal options even though we're using
             mafft. Fix the option to work with mafft default. *)
          Or_error.return
            {
              opts with
              other_parameters = Utils.default_mafft_other_aln_params;
            }
        else if String.is_substring opts.other_parameters ~substring:"--threads"
        then
          (* The args contain --threads but that only works with clustalo. So
             exit with the warning. *)
          Or_error.error_string
            "--other-parameters contains --threads.  This is valid for \
             clustalo but not for mafft.  Did you use the correct aligner?  If \
             you meant to use mafft, and you want a single thread, use \
             --thread.  E.g., for mafft, try pasv msa --aligner=mafft \
             --alignment-parameters='--thread 1 --auto' ..."
        else Or_error.return opts

  let run common_opts opts : unit Async.Deferred.Or_error.t =
    Logger.set_printer prerr_endline;
    Utils.assert_looks_like_fasta_file_or_exit opts.references;
    Utils.assert_looks_like_fasta_file_or_exit opts.queries;
    let opts =
      match fix_aln_params opts with
      | Ok opts -> opts
      | Error err ->
          Logger.fatal (fun () -> Error.to_string_hum err);
          exit 1
    in
    let f () =
      Utils.make_outdir_or_exit common_opts.outdir common_opts.force;
      let signatures_filename =
        Utils.make_signatures_filename ~infile:opts.queries
          ~outdir:common_opts.outdir
      in
      let references =
        Bio_io.Fasta_in_channel.with_file_records_exn opts.references
      in
      let queries =
        Bio_io.Fasta_in_channel.with_file_records_exn opts.queries
      in
      let open Async in
      (* Now that we're in async world, make sure the logger is async. *)
      Logger.set_printer Async.prerr_endline;
      let%bind (_ignore : unit) =
        Writer.with_file signatures_filename ~f:(fun writer ->
            Deferred.return @@ Writer.write_line writer
            @@ Check_alignment.make_signature_file_header opts.key_residues)
      in
      let%bind (query_sig_write_results : int list) =
        Deferred.List.mapi queries ~how:(`Max_concurrent_jobs opts.jobs)
          ~f:(get_and_write_sig signatures_filename common_opts opts references)
      in
      (* Give the user one final error message if none of the queries were
         written. *)
      if sig_file_write_results_good query_sig_write_results then
        Deferred.Or_error.return ()
      else
        Deferred.Or_error.error_string
          "Could not get signatures for any of the queries!"
    in
    f ()

  let run_wrapper common_opts msa_opts : unit =
    let open Async in
    never_returns
      (Scheduler.go_main
         ~main:(fun () ->
           let result = run common_opts msa_opts in
           don't_wait_for
             (Deferred.map result ~f:(fun result ->
                  match result with
                  | Ok () -> shutdown 0
                  | Error err ->
                      Logger.fatal (fun () -> Error.to_string_hum err);
                      shutdown 1)))
         ())
end

(* Some options are specific to the subcommand. *)
type specific_opts =
  | Pasv_check_opts of Check.opts
  | Pasv_hmm_opts of Hmm.opts
  | Pasv_msa_opts of Msa.opts
  | Pasv_select_opts of Select.opts

let run (common_opts : common_opts) (opts : specific_opts) =
  match opts with
  | Pasv_check_opts opts -> Check.run common_opts opts
  | Pasv_hmm_opts opts -> Hmm.run common_opts opts
  | Pasv_msa_opts opts -> Msa.run_wrapper common_opts opts
  | Pasv_select_opts opts -> Select.run common_opts opts
