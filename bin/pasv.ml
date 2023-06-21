open! Core
open Cmdliner
open Little_logger
open Pasv_lib

let parse_cli () =
  let cmd =
    Cmd.group ~default:Cli.Command.Root.term Cli.Command.Root.info
      Cli.subcommands
  in
  match Cmd.eval_value cmd with
  | Ok (`Ok opts) ->
      Either.first opts
  | Ok `Help | Ok `Version ->
      Either.second 0
  | Error _ ->
      Either.second 1

let main () =
  Logger.set_log_level Logger.Level.Debug ;
  match parse_cli () with
  | First (common_opts, opts) ->
      Logger.set_log_level common_opts.verbosity ;
      Pasv.run common_opts opts
  | Second code ->
      exit code

let () = main ()
