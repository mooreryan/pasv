open! Core
open Little_logger

(* Note: some of these have type annotations to help Merlin out with making the
   inferred types look nicer. *)

module Msa = struct
  type aligner = Clustalo of string | Mafft of string

  let pp_aligner ppf = function
    | Clustalo path -> Format.fprintf ppf "%s" path
    | Mafft path -> Format.fprintf ppf "%s" path

  let aligner_of_string s =
    let s' = String.lowercase s in
    if String.is_substring s' ~substring:"clustalo" then Some (Clustalo s)
    else if String.is_substring s' ~substring:"mafft" then Some (Mafft s)
    else None

  type opts = {
    infile : string;
    outfile : string;
    other_parameters : string;
    max_retries : int;
  }

  type out = {
    result : unit Or_error.t;
    stdout : string;
    stderr : string;
    opts : opts;
  }

  (* let make_msa_args opts =
   *   (\* A user provided format string with 2 string args. *\)
   *   let io_str_fmt = Scanf.format_from_string opts.io_format "%s %s" in
   *   let io_str = Printf.sprintf io_str_fmt opts.infile opts.outfile in
   *   let args = [%string "%{opts.other_parameters} %{io_str}"] in
   *   String.split args ~on:' ' *)

  let make_clustalo_args opts =
    (* There may be lots of other args, so just set them up in a single string,
       then split them. *)
    let args =
      [%string "%{opts.other_parameters} -i %{opts.infile} -o %{opts.outfile}"]
    in
    String.split args ~on:' '

  let make_mafft_args opts =
    (* There may be lots of other args, so just set them up in a single string,
       then split them. *)
    let args = [%string "%{opts.other_parameters} %{opts.infile}"] in
    String.split args ~on:' '

  let run_clustalo opts exe : string Async.Deferred.Or_error.t =
    (* We do this weird looping thing because with pasv v1 using mafft, mafft
       will just randomly fail when running a lot of threads on a server with a
       lot of CPUs and other jobs. Generally just rerunning the jobs would fix
       things. *)
    let rec loop num_tries =
      let open Async in
      let args = make_clustalo_args opts in
      Logger.debug (fun () ->
          let cmd_args = Core.String.concat args ~sep:" " in
          [%string "Running command: %{exe} %{cmd_args}"]);
      let%bind out = Process.run ~prog:exe ~args () in
      match out with
      | Ok stdout ->
          if Utils.is_file opts.outfile then Deferred.Or_error.return stdout
          else
            let cmd_args = Core.String.concat args ~sep:" " in
            Deferred.Or_error.errorf
              "Command (%s) succeeded, but the outfile (%s) does not exist!"
              [%string "%{exe} %{cmd_args}"] opts.outfile
      | Error err ->
          (* Aligner failed so make sure the outfile is cleaned up. *)
          let%bind _x =
            if Utils.is_file opts.outfile then Sys.remove opts.outfile
            else Deferred.return ()
          in
          Logger.error (fun () ->
              if num_tries < opts.max_retries then
                [%string "MSA failed.  Will retry.\n%{Error.to_string_hum err}"]
              else
                [%string
                  "MSA failed.  Max attempts exceeded.\n\
                   %{Error.to_string_hum err}"]);
          if num_tries < opts.max_retries then loop (num_tries + 1)
          else
            Deferred.Or_error.fail err
            |> Deferred.Or_error.tag ~tag:"msa failed after max-retries"
    in
    loop 0

  let run_mafft opts exe : string Async.Deferred.Or_error.t =
    let open Async in
    let rec loop num_tries =
      let args = make_mafft_args opts in
      Logger.debug (fun () ->
          let cmd_args = Core.String.concat args ~sep:" " in
          [%string "Running command: %{exe} %{cmd_args}"]);
      match%bind Process.run ~prog:exe ~args () with
      | Ok stdout ->
          (* stdout for mafft is the actual alignment *)
          let%bind (_ : unit) =
            Writer.with_file opts.outfile ~perm:0o644 ~f:(fun writer ->
                Deferred.return @@ Writer.write_line writer stdout)
          in
          (* The stdout gets written to the aln file. Stderr is lost this
             way...if you need it, you will need to change to a lower level
             function that Process.run. Return a string here to match with
             run_clustalo. *)
          Deferred.Or_error.return ""
      | Error err ->
          Logger.error (fun () ->
              if num_tries < opts.max_retries then
                [%string "MSA failed.  Will retry.\n%{Error.to_string_hum err}"]
              else
                [%string
                  "MSA failed.  Max attempts exceeded.\n\
                   %{Error.to_string_hum err}"]);
          if num_tries < opts.max_retries then loop (num_tries + 1)
          else
            Deferred.Or_error.fail err
            |> Deferred.Or_error.tag ~tag:"msa failed after max-retries"
    in
    loop 0

  let run opts = function
    | Clustalo exe -> run_clustalo opts exe
    | Mafft exe -> run_mafft opts exe
end

module Hmmalign = struct
  type opts = {
    exe : string;
    queries : string;
    targets : string;
    outfile : string;
  }
  type out = {
    result : unit Or_error.t;
    stdout : string;
    stderr : string;
    opts : opts;
  }

  (* Runs the hmmalign, waits, closes the channels, and returns stuff. *)
  let run opts =
    let cmd =
      [%string
        "%{opts.exe} --outformat=afa -o %{opts.outfile} %{opts.targets} \
         %{opts.queries}"]
    in
    Logger.debug (fun () -> [%string "Running command: %{cmd}"]);
    let chan = Unix.open_process_full cmd ~env:[||] in
    let stdout = In_channel.input_all chan.stdout in
    let stderr = In_channel.input_all chan.stderr in
    match Unix.close_process_full chan |> Unix.Exit_or_signal.or_error with
    | Ok () ->
        let result =
          if Utils.is_file opts.outfile then Or_error.return ()
          else
            Or_error.errorf
              "hmmalign succeeded, but the outfile (%s) does not exist!"
              opts.outfile
        in
        { result; stdout; stderr; opts }
    | Error err ->
        (* hmmalign failed, make sure the outfile is deleted *)
        if Utils.is_file opts.outfile then Sys.remove opts.outfile;
        let result = Or_error.error "hmmalign failed" err Error.sexp_of_t in
        { result; stdout; stderr; opts }
end
