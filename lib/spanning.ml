open! Core
open Mod

type spans_boundary = Yes | No | Na
let spans_boundary_to_string = function Yes -> "Yes" | No -> "No" | Na -> "NA"

type spannning_info = Both | Start | End | Neither | Na

let spanning_info_to_string = function
  | Both -> "Both"
  | Start -> "Start"
  | End -> "End"
  | Neither -> "Neither"
  | Na -> "NA"

let get_spanning_info ~spans_start ~spans_end =
  match (spans_start, spans_end) with
  | Yes, Yes -> Both
  | No, Yes -> End
  | Yes, No -> Start
  | No, No -> Neither
  | Na, Yes | Na, No | Yes, Na | No, Na | Na, Na -> Na

let spans s =
  let non_gap_char_count =
    s |> String.to_list |> List.count ~f:Utils.is_non_gap_char
  in
  if non_gap_char_count > 0 then Yes else No

let spans_roi_start (record : Position.aln Record.t) = function
  | Some (roi_start : Position.zero_indexed_aln) ->
      let record = Record.to_fasta_record record in
      let prefix_len = Position.to_int roi_start + 1 in
      let prefix = String.prefix (Bio_io.Fasta_record.seq record) prefix_len in
      spans prefix
  | None -> Na

let spans_roi_end (record : Position.aln Record.t) = function
  | Some (roi_end : Position.zero_indexed_aln) ->
      let record = Record.to_fasta_record record in
      let seq = Bio_io.Fasta_record.seq record in
      let suffix =
        let pos = Position.to_int roi_end in
        let len = String.length seq - pos in
        String.sub seq ~pos ~len
      in
      spans suffix
  | None -> Na
