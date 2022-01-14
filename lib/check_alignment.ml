open! Core
open Mod

exception Bad_aln_length of string [@@deriving sexp]

let gap_char = Re2.create_exn "[^a-zA-Z]"
let is_gap_char c = Re2.matches gap_char (String.of_char c)
let is_non_gap_char c = not (is_gap_char c)

let make_zero_raw_to_zero_aln_pos_map (aln_rec : Position.aln Record.t) =
  let _, map =
    aln_rec |> Record.to_fasta_record |> Bio_io.Fasta_record.seq
    |> String.to_array
    |> Array.foldi
         ~init:
           (Position.zero_raw_of_int 0, Position.Map_wrt.empty_zero_raw_aln ())
         ~f:(fun aln_column (seq_position, map) char ->
           let aln_column = Position.zero_aln_of_int aln_column in
           if is_gap_char char then (seq_position, map)
           else
             ( Position.(seq_position + zero_raw_of_int 1),
               (* _exn is okay here as new_seq_position is always increasing. *)
               Position.Map_wrt.add_exn map ~from:seq_position ~to_:aln_column
               (* Map.add_exn map ~key:seq_position ~data:aln_column *) ))
  in
  map

let bad_aln_length_exn seq_i ~expected_len ~actual_len =
  let i = seq_i + 1 in
  Bad_aln_length
    [%string
      "Seq num: %{i#Int}, Expected length: %{expected_len#Int}, Actual length: \
       %{actual_len#Int}"]

type alignment_file_data = {
  zero_raw_aln_pos_map :
    (Position.zero_indexed, Position.raw, Position.aln) Position.Map_wrt.t;
  records : Position.aln Record.t list;
  alignment_length : int;
  num_records : int;
}

let empty_alignment_data () =
  {
    zero_raw_aln_pos_map = Position.Map_wrt.empty_zero_raw_aln ();
    records = [];
    alignment_length = 0;
    num_records = 0;
  }

let assert_alignment_length_good ~expected_len ~actual_len i =
  if actual_len <> expected_len then
    raise @@ bad_aln_length_exn i ~expected_len ~actual_len

(* TODO the non-in-mem version has better assertions...use those here as well. *)
(* Assert some invariants and return it if good. *)
let finish_alignment_file_data data infile =
  (* If we read the whole file, but didn't hit the main reference, then the map
     will be empty. And that is an error. *)
  if Position.Map_wrt.length data.zero_raw_aln_pos_map = 0 then
    Or_error.errorf "We didn't find the key ref sequence in '%s'" infile
  else if data.num_records < 1 then
    Or_error.errorf "Should have at least one query record in '%s'" infile
  else if data.alignment_length = 0 then
    (* This shouldn't ever happen as the bad alignment length should catch
       it. *)
    Or_error.errorf "Something bad happened.  Found zero-length seqs in '%s'"
      infile
  else Or_error.return { data with records = List.rev data.records }

type alignment_infile = Basic of string | With_pasv_refs of string

(* Take a pos map and go from raw to aln positions (zero-indexed for both). *)
let get_aln_positions zero_raw_aln_pos_map zero_indexed_positions =
  Position.List.zero_raw_to_zero_aln zero_raw_aln_pos_map zero_indexed_positions
  |> Or_error.tag
       ~tag:
         "The zero-indexed raw position does not have an in zero-indexed \
          alignment position map.  Check the residues...are they out of \
          bounds?"

let make_signature_file_header
    (positions : (Position.one_indexed, Position.raw) Position.List.t) : string
    =
  let posns = Position.List.to_list positions in
  let posns = List.map posns ~f:(fun i -> "pos_" ^ Int.to_string i) in
  let posns = String.concat posns ~sep:"\t" in
  [%string "name\t%{posns}\tsignature\tspans_start\tspans_end\tspans"]

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
    s |> String.to_list |> List.count ~f:is_non_gap_char
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

let map_roi_boundary map = function
  | Some boundary -> (
      match Position.Map_wrt.find_or_error map boundary with
      | Ok roi -> Or_error.return @@ Some roi
      | Error err -> Error err)
  | None -> Or_error.return None

let make_aln_record_info ~aln_positions ~roi_start ~roi_end record =
  let id = Bio_io.Fasta_record.id @@ Record.to_fasta_record record in
  let spans_start = spans_roi_start record roi_start in
  let spans_end = spans_roi_end record roi_end in
  let spans_region = get_spanning_info ~spans_start ~spans_end in
  let key_residues = Record.get_aln_residues aln_positions record in
  let signature = String.concat key_residues ~sep:"" in
  let key_residues = String.concat key_residues ~sep:"\t" in
  let line =
    let ss = spans_boundary_to_string spans_start in
    let se = spans_boundary_to_string spans_end in
    let sr = spanning_info_to_string spans_region in
    String.concat [ id; key_residues; signature; ss; se; sr ] ~sep:"\t"
  in
  line

let parse_alignment_file_basic infile =
  let open Bio_io in
  let f () =
    Fasta_in_channel.with_file_foldi_records_exn infile
      ~init:(empty_alignment_data ()) ~f:(fun i aln record ->
        let this_aln_len = String.length (Fasta_record.seq record) in
        (* Regardless of whether it is a key ref, pasv ref, or query, all aln
           lengths should match the first record's length. *)
        if i = 0 then
          let zero_raw_aln_pos_map =
            make_zero_raw_to_zero_aln_pos_map
            @@ Record.aln_of_fasta_record record
          in
          { aln with alignment_length = this_aln_len; zero_raw_aln_pos_map }
        else (
          assert_alignment_length_good i ~expected_len:aln.alignment_length
            ~actual_len:this_aln_len;
          {
            aln with
            num_records = aln.num_records + 1;
            records = Record.aln_of_fasta_record record :: aln.records;
          }))
  in
  match f () with
  (* Catches every exception. *)
  | exception exn ->
      Or_error.of_exn exn |> Or_error.tag ~tag:"Error parsing alignment"
  | aln -> finish_alignment_file_data aln infile

type parse_alignment_state = {
  unprocessed_query_records : Position.aln Record.t list;
  expected_len : int;
  key_ref_seen : bool;
  roi_start_zero_aln : (Position.zero_indexed, Position.aln) Position.t option;
  roi_end_zero_aln : (Position.zero_indexed, Position.aln) Position.t option;
  aln_positions_zero_aln :
    (Position.zero_indexed, Position.aln) Position.List.t option;
  num_queries : int;
}

let init_parse_alignment_state () =
  {
    unprocessed_query_records = [];
    expected_len = 0;
    key_ref_seen = false;
    roi_start_zero_aln = None;
    roi_end_zero_aln = None;
    aln_positions_zero_aln = None;
    num_queries = 0;
  }

let write_query_record record ~state ~out_channel =
  let aln_positions_zero_aln =
    (* If this is None, it means it wasn't set properly when we saw the key_ref
       and is a bug. *)
    Option.value_exn state.aln_positions_zero_aln
  in
  let record_info =
    make_aln_record_info record ~aln_positions:aln_positions_zero_aln
      ~roi_start:state.roi_start_zero_aln ~roi_end:state.roi_end_zero_aln
  in
  Out_channel.output_lines out_channel [ record_info ]

(* Doesn't read everything into memory. *)
(* TODO need a test in which the key ref is not first. *)
let parse_alignment_file_with_pasv_refs_streaming ~infile ~positions
    ~roi_start_zero_raw ~roi_end_zero_raw ~out_channel =
  let zero_raw_positions = Position.List.one_to_zero positions in
  let state =
    Bio_io.Fasta_in_channel.with_file_foldi_records infile
      ~init:(init_parse_alignment_state ()) ~f:(fun i state record ->
        let current_aln_len = String.length (Bio_io.Fasta_record.seq record) in
        let state =
          (* Regardless of whether it is a key ref, pasv ref, or query, all aln
             lengths should match the first record's length. *)
          if i = 0 then { state with expected_len = current_aln_len } else state
        in
        assert_alignment_length_good i ~expected_len:state.expected_len
          ~actual_len:current_aln_len;
        (* Match against the expected ID rather than the first index as some
           aligners will rearrange the order of the sequences in the alignment
           file. *)
        match (Utils.is_key_reference record, Utils.is_reference record) with
        | true, true -> assert false
        | false, false ->
            let num_queries = state.num_queries + 1 in
            let record = Record.aln_of_fasta_record record in
            (* A normal query sequence *)
            (* We have seen the state, so we can now process this record. *)
            if state.key_ref_seen then (
              write_query_record record ~state ~out_channel;
              (* TODO write test that num queries is correct *)
              { state with num_queries })
            else
              (* We haven't yet seen the key ref so we need to store this query
                 and come back to it later. *)
              let unprocessed_query_records =
                record :: state.unprocessed_query_records
              in
              { state with unprocessed_query_records; num_queries }
        (* In the msa mode, you will have refs in here to ignore. *)
        | false, true -> (* We ignore any other "non-key" references *) state
        | true, false ->
            (* Key reference *)
            let zero_raw_to_zero_aln_pos_map =
              make_zero_raw_to_zero_aln_pos_map
              @@ Record.aln_of_fasta_record record
            in
            (* ok_exn here is okay, as all errors will get caught in the
               surrounding function. *)
            let aln_positions_zero_aln =
              Or_error.ok_exn
              @@ get_aln_positions zero_raw_to_zero_aln_pos_map
                   zero_raw_positions
            in
            let roi_start_zero_aln =
              Or_error.ok_exn
              @@ map_roi_boundary zero_raw_to_zero_aln_pos_map
                   roi_start_zero_raw
            in
            let roi_end_zero_aln =
              Or_error.ok_exn
              @@ map_roi_boundary zero_raw_to_zero_aln_pos_map roi_end_zero_raw
            in
            let key_ref_seen = true in
            let state =
              {
                state with
                key_ref_seen;
                (* These are alread options as the user may not care about
                   them. *)
                roi_start_zero_aln;
                roi_end_zero_aln;
                (* Indicate that this is now present with Some *)
                aln_positions_zero_aln = Some aln_positions_zero_aln;
              }
            in
            List.iter state.unprocessed_query_records
              ~f:(write_query_record ~state ~out_channel);
            state)
  in
  match state with
  | Ok state ->
      (* We're going through the possible returns here. Each one can tag on a
         new error. *)
      let check_ref_seen =
        (* If the key ref was never seen, then that is an error. *)
        if state.key_ref_seen then Or_error.return ()
        else
          let msg =
            [%string "We didn't find the key ref sequence in '%{infile}'"]
          in
          Or_error.error_string msg
      in
      let check_num_queries =
        if state.num_queries >= 1 then Or_error.return ()
        else
          Or_error.error_string [%string "There were no queries in '%{infile}'"]
      in
      Or_error.combine_errors_unit [ check_ref_seen; check_num_queries ]
  | Error err ->
      Error err
      |> Or_error.tag ~tag:"Error in parse_alignment_file_with_pasv_refs_GOOD"

let parse_alignment_file_with_pasv_refs_in_mem infile =
  let is_key_reference = Utils.is_key_reference in
  let is_reference = Utils.is_reference in
  let open Bio_io in
  let f () =
    Fasta_in_channel.with_file_foldi_records_exn infile
      ~init:(empty_alignment_data ()) ~f:(fun i aln record ->
        let this_aln_len = String.length (Fasta_record.seq record) in
        (* Regardless of whether it is a key ref, pasv ref, or query, all aln
           lengths should match the first record's length. *)
        let aln =
          if i = 0 then { aln with alignment_length = this_aln_len } else aln
        in
        assert_alignment_length_good i ~expected_len:aln.alignment_length
          ~actual_len:this_aln_len;
        (* Match against the expected ID rather than the first index as some
           aligners will rearrange the order of the sequences in the alignment
           file. *)
        match (is_key_reference record, is_reference record) with
        | true, true -> assert false
        | true, false ->
            let zero_raw_aln_pos_map =
              make_zero_raw_to_zero_aln_pos_map
              @@ Record.aln_of_fasta_record record
            in
            { aln with zero_raw_aln_pos_map }
        (* In the pasv1 style msa, you will have refs in here to ignore. *)
        | false, true -> aln
        | false, false ->
            {
              aln with
              num_records = aln.num_records + 1;
              records = Record.aln_of_fasta_record record :: aln.records;
            })
  in
  match f () with
  (* Catches every exception. *)
  | exception exn ->
      Or_error.of_exn exn |> Or_error.tag ~tag:"Error parsing alignment"
  | aln -> finish_alignment_file_data aln infile

let parse_alignment_file = function
  | Basic infile -> parse_alignment_file_basic infile
  | With_pasv_refs infile -> parse_alignment_file_with_pasv_refs_in_mem infile

let check_alignment ~infile ~roi_start ~roi_end ~positions =
  let f () =
    let open Or_error.Let_syntax in
    let zi_positions = Position.List.one_to_zero positions in
    let%bind aln_file = parse_alignment_file infile in
    let aln_records = Array.of_list aln_file.records in
    let%bind aln_positions =
      get_aln_positions aln_file.zero_raw_aln_pos_map zi_positions
    in
    let%bind roi_start =
      map_roi_boundary aln_file.zero_raw_aln_pos_map roi_start
    in
    let%map roi_end = map_roi_boundary aln_file.zero_raw_aln_pos_map roi_end in
    let make_aln_record_info record =
      let id = Bio_io.Fasta_record.id @@ Record.to_fasta_record record in
      let spans_start = spans_roi_start record roi_start in
      let spans_end = spans_roi_end record roi_end in
      let spans_region = get_spanning_info ~spans_start ~spans_end in
      let key_residues = Record.get_aln_residues aln_positions record in
      let signature = String.concat key_residues ~sep:"" in
      let key_residues = String.concat key_residues ~sep:"\t" in
      let line =
        let ss = spans_boundary_to_string spans_start in
        let se = spans_boundary_to_string spans_end in
        let sr = spanning_info_to_string spans_region in
        String.concat [ id; key_residues; signature; ss; se; sr ] ~sep:"\t"
      in
      line
    in
    Array.map aln_records ~f:make_aln_record_info
  in
  match f () with
  | Ok signatures -> Or_error.return signatures
  | Error err -> Error err |> Or_error.tag ~tag:"error in check_alignment"

let write_signatures ~filename ~header signatures =
  Out_channel.with_file filename ~f:(fun out_chan ->
      Out_channel.output_string out_chan (header ^ "\n");
      Array.iter signatures ~f:(fun signature ->
          Out_channel.output_string out_chan (signature ^ "\n")))

let check_alignment_and_write_signatures ~roi_start ~roi_end ~positions
    ~outfile_name ~outfile_header = function
  | Basic infile ->
      let open Or_error.Let_syntax in
      let%bind signatures =
        let f () =
          let open Or_error.Let_syntax in
          let zi_positions = Position.List.one_to_zero positions in
          let%bind aln_file = parse_alignment_file_basic infile in
          let aln_records = Array.of_list aln_file.records in
          let%bind aln_positions =
            get_aln_positions aln_file.zero_raw_aln_pos_map zi_positions
          in
          let%bind roi_start =
            map_roi_boundary aln_file.zero_raw_aln_pos_map roi_start
          in
          let%map roi_end =
            map_roi_boundary aln_file.zero_raw_aln_pos_map roi_end
          in
          Array.map aln_records
            ~f:(make_aln_record_info ~aln_positions ~roi_start ~roi_end)
        in
        match f () with
        | Ok signatures -> Or_error.return signatures
        | Error err -> Error err |> Or_error.tag ~tag:"error in check_alignment"
      in
      Or_error.try_with (fun () ->
          write_signatures signatures ~filename:outfile_name
            ~header:outfile_header)
  | With_pasv_refs infile ->
      Out_channel.with_file outfile_name ~f:(fun out_channel ->
          Out_channel.output_string out_channel (outfile_header ^ "\n");
          parse_alignment_file_with_pasv_refs_streaming ~infile ~positions
            ~roi_start_zero_raw:roi_start ~roi_end_zero_raw:roi_end ~out_channel)
