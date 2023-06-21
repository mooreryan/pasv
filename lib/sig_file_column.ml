open! Core
open Little_logger
module U = Utils

type t = Spans | Spans_end | Spans_start | Signature

let reverse_index = function
  | Spans ->
      0
  | Spans_end ->
      1
  | Spans_start ->
      2
  | Signature ->
      3

let to_string = function
  | Spans ->
      "spans"
  | Spans_end ->
      "spans_end"
  | Spans_start ->
      "spans_start"
  | Signature ->
      "signature"

let position_name = function
  | Spans ->
      "last"
  | Spans_end ->
      "second to last"
  | Spans_start ->
      "third to last"
  | Signature ->
      "fourth to last"

let check ary col =
  let name = to_string col in
  let position_name = position_name col in
  match U.get_from_end ary (reverse_index col) with
  | Ok s ->
      let is_good = String.(s = name) in
      if not is_good then
        Logger.error (fun () ->
            [%string
              "The %{position_name} column the signature file should be \
               '%{name}'.  Got '%{s}'."] ) ;
      is_good
  | Error err ->
      Logger.error (fun () ->
          let msg = Error.to_string_hum err in
          [%string
            "Couldn't get '%{name}' column from header.  It's probably too \
             short.  %{msg}"] ) ;
      false

let get_from_header header t = U.get_from_end header @@ reverse_index t
