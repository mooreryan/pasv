open! Core

type t = { dir : string; basename : string; suffix : string option }

let of_string s =
  let dir, name = Filename.split s in
  let basename, suffix = Filename.split_extension name in
  { dir; basename; suffix }

let to_string f =
  match f.suffix with
  | Some suffix ->
      Filename.concat f.dir (Printf.sprintf "%s.%s" f.basename suffix)
  | None -> Filename.concat f.dir f.basename
