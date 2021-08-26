open! Core
open Little_logger

(* Note: some of these have type annotations to help Merlin out with making the
   inferred types look nicer. *)

module Msa = struct
  open Async

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

  let remove_if_exists filename =
    if Utils.is_file filename then Sys.remove filename else return ()

  (* Printable representation of a command run by Process.run *)
  let cmd_to_string (prog : string) args =
    let args = String.concat args ~sep:" " in
    [%string "%{prog} %{args}"]

  (* Some errors we will retry. Let the user know we will retry and what the
     command was. *)
  let log_retryable_error prog args err =
    let msg =
      let cmd = cmd_to_string prog args in
      [%string
        "Command (%{cmd}) failed.  Will retry.\n\
         Error was: %{Error.to_string_hum err}"]
    in
    Logger.swarning msg

  (* Eventually, we stop retrying. Let the user know there will be no more
     retries and what the error was. *)
  let log_final_error prog args err =
    let msg =
      let cmd = cmd_to_string prog args in
      [%string
        "Command (%{cmd}) failed.  Max attempts exceeded.\n\
         Error was: %{Error.to_string_hum err}"]
    in
    Logger.serror msg

  let run_until_succes_or_error ?(delay = 0.1) prog args max_retries =
    let delay =
      if Float.(delay <= 0.0) then sec 0.0
      else Time.Span.randomize (sec delay) ~percent:(Percent.of_percentage 25.)
    in
    let rec loop num_tries =
      match%bind Process.run ~prog ~args () with
      | Ok stdout -> Deferred.Or_error.return stdout
      | Error err ->
          if num_tries < max_retries then (
            log_retryable_error prog args err;
            (* We want to give just a little bit of delay before retrying the
               job again. *)
            let%bind (_ : unit) = after delay in
            loop (num_tries + 1))
          else (
            log_final_error prog args err;
            Deferred.Or_error.fail err
            |> Deferred.Or_error.tag ~tag:"job failed after max-retries")
    in
    loop 0

  let run_mafft opts exe : string Deferred.Or_error.t =
    let args = make_mafft_args opts in
    Logger.debug (fun () ->
        let cmd = cmd_to_string exe args in
        "Running command: " ^ cmd);
    match%bind run_until_succes_or_error exe args opts.max_retries with
    | Ok stdout ->
        (* stdout for mafft is the actual alignment *)
        let%bind (_ : unit) =
          Writer.with_file opts.outfile ~perm:0o644 ~f:(fun writer ->
              Deferred.return @@ Writer.write_line writer stdout)
        in
        (* The stdout gets written to the aln file. Stderr is lost this way...if
           you need it, you will need to change to a lower level function that
           Process.run. Return a string here to match with run_clustalo. *)
        Deferred.Or_error.return ""
    | Error err ->
        Deferred.Or_error.fail err |> Deferred.Or_error.tag ~tag:"mafft failed"

  (* Similar to run_mafft, except that clustalo outputs files to deal with. *)
  let run_clustalo opts exe : string Deferred.Or_error.t =
    let args = make_clustalo_args opts in
    let cmd = cmd_to_string exe args in
    Logger.debug (fun () -> "Running command: " ^ cmd);
    match%bind run_until_succes_or_error exe args opts.max_retries with
    | Ok stdout ->
        (* We double check the the outfile actually exists. *)
        if Utils.is_file opts.outfile then Deferred.Or_error.return stdout
          (* And if not return an informative error. *)
        else
          Deferred.Or_error.errorf
            "Command (%s) succeeded, but the outfile (%s) does not exist!" cmd
            opts.outfile
    | Error err ->
        (* Aligner failed so make sure the outfile is cleaned up. *)
        let%bind (_ : unit) = remove_if_exists opts.outfile in
        Deferred.Or_error.fail err
        |> Deferred.Or_error.tag ~tag:"clustalo failed"

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
