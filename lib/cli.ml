open! Core
open! Cmdliner
open Version

module Converter = struct
  let aligner =
    let aligner_parser s =
      Arg.parser_of_kind_of_string
        ~kind:"clustalo, mafft, or a direct path to either program"
        Runners.Msa.aligner_of_string s
    in
    let aligner_printer : Runners.Msa.aligner Arg.printer =
      Runners.Msa.pp_aligner
    in
    Arg.conv (aligner_parser, aligner_printer)

  (* aka non-zero, positive integer *)
  let counting_number =
    let num_parser s =
      Arg.parser_of_kind_of_string ~kind:"a number >= 1"
        (fun s ->
          let open Option.Let_syntax in
          let%bind n = try Some (Int.of_string s) with _ -> None in
          if n <= 0 then None else Some n )
        s
    in
    let num_printer : int Arg.printer = Format.pp_print_int in
    Arg.conv (num_parser, num_printer)

  (* aka positive integer >= 0 *)
  let positive_number =
    let num_parser s =
      Arg.parser_of_kind_of_string ~kind:"a number >= 0"
        (fun s ->
          let open Option.Let_syntax in
          let%bind n = try Some (Int.of_string s) with _ -> None in
          if n < 0 then None else Some n )
        s
    in
    let num_printer : int Arg.printer = Format.pp_print_int in
    Arg.conv (num_parser, num_printer)
end

let queries_term =
  let doc = "Path to query sequences." in
  Arg.(required & pos 0 (some non_dir_file) None & info [] ~docv:"QUERIES" ~doc)

let keep_intermediate_files_term =
  let doc = "Keep intermediate files" in
  Arg.(value & flag & info ["k"; "keep"] ~doc)

let outdir_term =
  let doc = "Out directory" in
  Arg.(
    value & opt string "."
    & info ["o"; "outdir"] ~docv:"OUTDIR" ~doc ~docs:Manpage.s_common_options)

let force_term =
  let doc = "If the outdir already exists, just keep going." in
  Arg.(value & flag & info ["f"; "force"] ~doc ~docs:Manpage.s_common_options)

let roi_start_term =
  let doc = "Region of interest start (ROI) (1-indexed)" in
  Arg.(
    value
    & opt (some Converter.counting_number) None
    & info ["s"; "roi-start"] ~docv:"ROI_START" ~doc)

let roi_end_term =
  let doc = "Region of interest end (ROI) (1-indexed)" in
  Arg.(
    value
    & opt (some Converter.counting_number) None
    & info ["e"; "roi-end"] ~docv:"ROI_END" ~doc)

let common_opts_term =
  let make_common_opts outdir force verbosity : Pasv.common_opts =
    {outdir; force; verbosity}
  in
  Term.(
    const make_common_opts $ outdir_term $ force_term
    $ Verbosity.log_level_term ~docs:Manpage.s_common_options ())

let common_man_sections =
  let common_opts =
    [`S Manpage.s_common_options; `P "These options are common to all commands."]
  in
  let more_help =
    [ `S "MORE HELP"
    ; `P "Use `$(mname) $(i,COMMAND) --help' for help on a single command." ]
  in
  let bugs =
    [ `S Manpage.s_bugs
    ; `P
        "Please report any bugs or issues on GitHub. \
         (https://github.com/mooreryan/pasv/issues)" ]
  in
  let see_also =
    [ `S Manpage.s_see_also
    ; `P
        "For full documentation, please see the PASV wiki. \
         (https://github.com/mooreryan/pasv/wiki)"
    ; `P
        "If you use pasv, please cite our manuscript: \
         https://doi.org/10.1101/2021.01.20.427478" ]
  in
  let authors =
    [ `S Manpage.s_authors
    ; `P "Ryan M. Moore <https://orcid.org/0000-0003-3337-8184>" ]
  in
  List.concat [common_opts; more_help; bugs; see_also; authors]

module type Pasv_command = sig
  val info : Cmd.info

  val term : (Pasv.common_opts * Pasv.specific_opts) Term.t

  val program : (Pasv.common_opts * Pasv.specific_opts) Cmd.t
end

module Command = struct
  module Check : Pasv_command = struct
    let alignment_file_term =
      let doc = "Path to alignment file." in
      Arg.(
        required
        & pos 0 (some non_dir_file) None
        & info [] ~docv:"ALIGNMENT" ~doc)

    let key_residues_term =
      let doc = "Key residues (comma separated)" in
      Arg.(
        required
        & pos 1 (some (list Converter.counting_number ~sep:',')) None
        & info [] ~docv:"KEY_RESIDUES" ~doc)

    let term =
      let opts_term =
        let make_check_opts alignment key_residues roi_start roi_end :
            Pasv.Check.opts =
          { alignment
          ; key_residues= Mod.Position.List.one_raw_of_list key_residues
          ; roi_start= Option.map roi_start ~f:Mod.Position.one_raw_of_int
          ; roi_end= Option.map roi_end ~f:Mod.Position.one_raw_of_int }
        in
        Term.(
          const make_check_opts $ alignment_file_term $ key_residues_term
          $ roi_start_term $ roi_end_term)
      in
      let combine_terms common_opts opts : Pasv.common_opts * Pasv.specific_opts
          =
        (common_opts, Pasv.Check_opts opts)
      in
      Term.(const combine_terms $ common_opts_term $ opts_term)

    let info =
      let doc = "use precomputed alignments" in
      let man =
        [ `S Manpage.s_description
        ; `P
            "Use pasv-check when you already have an alignment file in which \
             you want to check key residues or ROI."
        ; `P
            "I assume the first sequence is the key reference.  All positions \
             will be with respect to this sequence."
        ; `Blocks common_man_sections
        ; `S Manpage.s_examples
        ; `P "=== Quick start"
        ; `Pre "  \\$ pasv check aln.faa 500,502,504"
        ; `P "=== Specifying an output directory, ROI start, and ROI end"
        ; `Pre
            "  \\$ pasv check --outdir=pasv_output \\\\ \n\
            \               --roi-start=200 \\\\ \n\
            \               --roi-end=800 \\\\ \n\
            \               aln.faa \\\\ \n\
            \               500,502,504" ]
      in
      Cmd.info "check" ~version ~doc ~man ~sdocs:Manpage.s_common_options
        ~exits:[]

    let program = Cmd.v info term
  end

  module Hmm : Pasv_command = struct
    let references_hmm_term =
      let doc = "Path to reference HMM." in
      Arg.(
        required
        & pos 1 (some non_dir_file) None
        & info [] ~docv:"REFERENCES" ~doc)

    let key_reference_term =
      let doc = "Path to key reference sequence." in
      Arg.(
        required
        & pos 2 (some non_dir_file) None
        & info [] ~docv:"KEY_REFERENCE" ~doc)

    let hmmalign_term =
      let doc =
        "Name of hmmer hmmalign executable.  If it is a name, then it is \
         searched on the PATH, if it is a path, it is treated as a path to the \
         executable."
      in
      Arg.(
        value & opt string "hmmalign"
        & info ["h"; "hmmalign"] ~docv:"HMMALIGN" ~doc)

    let key_residues_term =
      let doc = "Key residues (comma separated)" in
      Arg.(
        required
        & pos 3 (some (list Converter.counting_number ~sep:',')) None
        & info [] ~docv:"KEY_RESIDUES" ~doc)

    let term =
      let opts_term =
        let make_hmm_opts queries references key_reference key_residues
            keep_intermediate_files hmmalign roi_start roi_end : Pasv.Hmm.opts =
          { queries
          ; references
          ; key_reference
          ; key_residues= Mod.Position.List.one_raw_of_list key_residues
          ; keep_intermediate_files
          ; hmmalign
          ; roi_start= Option.map roi_start ~f:Mod.Position.one_raw_of_int
          ; roi_end= Option.map roi_end ~f:Mod.Position.one_raw_of_int }
        in
        Term.(
          const make_hmm_opts $ queries_term $ references_hmm_term
          $ key_reference_term $ key_residues_term
          $ keep_intermediate_files_term $ hmmalign_term $ roi_start_term
          $ roi_end_term)
      in
      let combine_terms common_opts opts : Pasv.common_opts * Pasv.specific_opts
          =
        (common_opts, Pasv.Hmm_opts opts)
      in
      Term.(const combine_terms $ common_opts_term $ opts_term)

    let info =
      let doc = "use hmm alignments" in
      let man =
        [ `S Manpage.s_description
        ; `P "Use the hmmalign to compute alignments."
        ; `P
            "The key reference sequence and all queries are aligned together \
             against the reference HMM."
        ; `Blocks common_man_sections
        ; `S Manpage.s_examples
        ; (* standard 'EXAMPLES' section *)
          `P "=== Quick start"
        ; `Pre "  \\$ pasv hmm queries.faa refs.hmm main_ref.faa 500,502,504"
        ; `P "=== Specifying an output directory, ROI start, and ROI end"
        ; `Pre
            "  \\$ pasv hmm --outdir=pasv_output \\\\ \n\
            \             --roi-start=200 \\\\ \n\
            \             --roi-end=800 \\\\ \n\
            \             queries.faa \\\\ \n\
            \             refs.hmm \\\\ \n\
            \             main_ref.faa \\\\ \n\
            \             500,502,504" ]
      in
      Cmd.info "hmm" ~version ~doc ~man ~sdocs:Manpage.s_common_options
        ~exits:[]

    let program = Cmd.v info term
  end

  module Msa : Pasv_command = struct
    let references_fasta_term =
      let doc = "Path to reference sequence fasta." in
      Arg.(
        required
        & pos 1 (some non_dir_file) None
        & info [] ~docv:"REFERENCES" ~doc)

    let aligner_other_params_term =
      let doc =
        [%string
          "Other alignment params.  If the you need spaces, put single quotes \
           around them.  This is very important...you need to use the `=` \
           between the flag and the argument like this: \
           --alignment-parameters=--auto, or whatever args you want.  If the \
           parameters include '-' characters, do it like so \
           --alignment-parameters='--threads 1 --thingies 46'.  The default \
           shown is for clustalo.  If the aligner is set to mafft (eg with \
           --aligner=mafft), then the default will be \
           '%{Utils.default_mafft_other_aln_params}'.  If you don't want that, \
           you can specify the this option in the usual way."]
      in
      Arg.(
        value
        & opt string Utils.default_clustalo_other_aln_params
        & info ["alignment-parameters"] ~docv:"ALIGNMENT_PARAMETERS" ~doc)

    let max_retries_term =
      let doc =
        "Maximum number of job retries.  Sometimes the MSA software will fail, \
         so individual jobs will be retried until they succeed or until this \
         number of tries is reached."
      in
      Arg.(
        value
        & opt Converter.positive_number 10
        & info ["r"; "max-retries"] ~docv:"MAX_RETRIES" ~doc)

    let jobs_term =
      let doc = "Number of jobs to run." in
      Arg.(
        value
        & opt Converter.counting_number 1
        & info ["j"; "jobs"] ~docv:"JOBS" ~doc)

    let aligner_term =
      let doc =
        "Name of aligner executable.  If it is a name, then it is searched on \
         the PATH, if it is a path, it is treated as a path to the executable."
      in
      Arg.(
        value
        & opt Converter.aligner (Runners.Msa.Clustalo "clustalo")
        & info ["a"; "aligner"] ~docv:"ALIGNER" ~doc)

    let key_residues_term =
      let doc = "Key residues (comma separated)" in
      Arg.(
        required
        & pos 2 (some (list Converter.counting_number ~sep:',')) None
        & info [] ~docv:"KEY_RESIDUES" ~doc)

    let term =
      let opts_term =
        let make_msa_opts queries references key_residues
            keep_intermediate_files aligner other_parameters jobs max_retries
            roi_start roi_end : Pasv.Msa.opts =
          { queries
          ; references
          ; key_residues= Mod.Position.List.one_raw_of_list key_residues
          ; keep_intermediate_files
          ; aligner
          ; other_parameters
          ; jobs
          ; max_retries
          ; roi_start= Option.map roi_start ~f:Mod.Position.one_raw_of_int
          ; roi_end= Option.map roi_end ~f:Mod.Position.one_raw_of_int }
        in
        Term.(
          const make_msa_opts $ queries_term $ references_fasta_term
          $ key_residues_term $ keep_intermediate_files_term $ aligner_term
          $ aligner_other_params_term $ jobs_term $ max_retries_term
          $ roi_start_term $ roi_end_term)
      in
      let combine_terms common_opts opts : Pasv.common_opts * Pasv.specific_opts
          =
        (common_opts, Pasv.Msa_opts opts)
      in
      Term.(const combine_terms $ common_opts_term $ opts_term)

    let info =
      let doc = "use multiple sequence alignments" in
      let man =
        [ `S Manpage.s_description
        ; `P "Use a multiple sequence aligner for the alignments."
        ; `P "Each query is aligned individually with reference sequences"
        ; `Blocks common_man_sections
        ; `S Manpage.s_examples
        ; `P "=== Quick start"
        ; `Pre "  \\$ pasv msa queries.faa refs.faa 500,502,504"
        ; `P
            "=== Specifying an output directory, ROI start, ROI end, and num. \
             jobs"
        ; `Pre
            "  \\$ pasv msa --outdir=pasv_output \\\\ \n\
            \             --roi-start=200 \\\\ \n\
            \             --roi-end=800 \\\\ \n\
            \             --jobs=4 \\\\ \n\
            \             queries.faa \\\\ \n\
            \             refs.faa \\\\ \n\
            \             500,502,504" ]
      in
      Cmd.info "msa" ~version ~doc ~man ~sdocs:Manpage.s_common_options
        ~exits:[]

    let program = Cmd.v info term
  end

  module Root : Pasv_command = struct
    let term = Term.(ret (const (`Help (`Pager, None))) $ common_opts_term)

    let info =
      let doc = "protein active site validation" in
      let man =
        [ `S Manpage.s_description
        ; `P
            "Post-homology search validation and partitioning of sequences by \
             specific residues (active sites, conserved residues, etc)."
        ; `Blocks common_man_sections ]
      in
      Cmd.info "pasv" ~version ~doc ~man ~sdocs:Manpage.s_common_options
        ~exits:[]

    let program = Cmd.v info term
  end

  module Select : Pasv_command = struct
    let signature_file_term =
      let doc = "Path to signatures file." in
      Arg.(
        required
        & pos 1 (some non_dir_file) None
        & info [] ~docv:"SIGNATURE_FILE" ~doc)

    let signature_list_term =
      let doc = "List of signatures to keep (comma separated)" in
      Arg.(
        required
        & pos 2 (some (list string ~sep:',')) None
        & info [] ~docv:"SIGNATURES" ~doc)

    let reject_term =
      let doc =
        "Pass this flag if you want to reject the listed signatures rather \
         than keep them."
      in
      Arg.(value & flag & info ["r"; "reject"] ~doc)

    let fixed_strings_term =
      let doc =
        "Treat the signatures as literal strings instead of a regular \
         expressions."
      in
      Arg.(value & flag & info ["F"; "fixed-strings"] ~doc)

    (* This is the module's main term. *)
    let term =
      let opts_term =
        let make_select_opts query_file signature_file signature_list reject
            fixed_strings : Pasv.Select.opts =
          {query_file; signature_file; signature_list; reject; fixed_strings}
        in
        Term.(
          const make_select_opts $ queries_term $ signature_file_term
          $ signature_list_term $ reject_term $ fixed_strings_term)
      in
      let combine_terms common_opts opts : Pasv.common_opts * Pasv.specific_opts
          =
        (common_opts, Pasv.Select_opts opts)
      in
      Term.(const combine_terms $ common_opts_term $ opts_term)

    let info =
      let doc = "select sequences by signature" in
      let man =
        [ `S Manpage.s_description
        ; `P "Select query sequences based on their key residue signatures."
        ; `Blocks common_man_sections
        ; `S Manpage.s_examples
        ; `P "=== Quick start"
        ; `Pre
            "  \\$ pasv select --outdir=iqk_queries queries.fa signatures.tsv \
             IQK"
        ; `P "=== Using regular expressions"
        ; `P "This would match any signature starting with AB or AC."
        ; `Pre "  \\$ pasv select queries.fa signatures.tsv '^A[BC]'"
        ; `P "=== Invert matching"
        ; `P "Print queries that do not have the given signature(s)."
        ; `Pre "  \\$ pasv select -rF queries.fa signatures.tsv AAA,AAB" ]
      in
      Cmd.info "select" ~version ~doc ~man ~sdocs:Manpage.s_common_options
        ~exits:[]

    let program = Cmd.v info term
  end
end

let subcommands =
  [ Command.Check.program
  ; Command.Hmm.program
  ; Command.Msa.program
  ; Command.Select.program ]
