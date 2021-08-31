Set up environment variables.

  $ export QUERIES=amk_queries.fa
  $ export REFS=P00582.refs.aln.hmm
  $ export MAIN_REF=amk_main_ref.fa
  $ export OUTDIR=apple
  $ export RESIDUES=50,52,54
  $ export EXPECTED_SIGNATURES=expected.amk_queries.pasv_signatures.tsv
  $ export ACTUAL_SIGNATURES=amk_queries.pasv_signatures.tsv
  $ export ROI_START=20
  $ export ROI_END=80
  $ export EXPECTED_SIGNATURES_WITH_ROI=expected.with_roi.amk_queries.pasv_signatures.tsv
  $ export SANITIZE_LOGS=$PWD/../../helpers/sanitize_logs


Help screen

  $ pasv hmm --help=plain
  NAME
         pasv-hmm - use hmm alignments
  
  SYNOPSIS
         pasv hmm [OPTION]... QUERIES REFERENCES KEY_REFERENCE KEY_RESIDUES
  
  DESCRIPTION
         Use the hmmalign to compute alignments.
  
         The key reference sequence and all queries are aligned together
         against the reference HMM.
  
  ARGUMENTS
         KEY_REFERENCE (required)
             Path to key reference sequence.
  
         KEY_RESIDUES (required)
             Key residues (comma separated)
  
         QUERIES (required)
             Path to query sequences.
  
         REFERENCES (required)
             Path to reference HMM.
  
  OPTIONS
         -e ROI_END, --roi-end=ROI_END
             Region of interest end (ROI) (1-indexed)
  
         -h HMMALIGN, --hmmalign=HMMALIGN (absent=hmmalign)
             Name of hmmer hmmalign executable. If it is a name, then it is
             searched on the PATH, if it is a path, it is treated as a path to
             the executable.
  
         -k, --keep
             Keep intermediate files
  
         -s ROI_START, --roi-start=ROI_START
             Region of interest start (ROI) (1-indexed)
  
  COMMON OPTIONS
         These options are common to all commands.
  
         -f, --force
             If the outdir already exists, just keep going.
  
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of `auto',
             `pager', `groff' or `plain'. With `auto', the format is `pager` or
             `plain' whenever the TERM env var is `dumb' or undefined.
  
         -o OUTDIR, --outdir=OUTDIR (absent=.)
             Out directory
  
         -q, --quiet
             Silence all log messages. Takes over -v and --verbosity.
  
         -v, --verbose
             Increase verbosity. Repeatable, but more than twice does not bring
             more.
  
         --version
             Show version information.
  
  MORE HELP
         Use `pasv COMMAND --help' for help on a single command.
  
  BUGS
         Please report any bugs or issues on GitHub.
         (https://github.com/mooreryan/pasv/issues)
  
  SEE ALSO
         For full documentation, please see the PASV wiki.
         (https://github.com/mooreryan/pasv/wiki)
  
         If you use pasv, please cite our manuscript:
         https://doi.org/10.1101/2021.01.20.427478
  
  AUTHORS
         Ryan M. Moore <https://orcid.org/0000-0003-3337-8184>
  
  EXAMPLES
         === Quick start
  
           $ pasv hmm queries.faa refs.hmm main_ref.faa 500,502,504
  
         === Specifying an output directory, ROI start, and ROI end
  
           $ pasv hmm --outdir=pasv_output \ 
                      --roi-start=200 \ 
                      --roi-end=800 \ 
                      queries.faa \ 
                      refs.hmm \ 
                      main_ref.faa \ 
                      500,502,504
  
Non empty (default) outdir without --force gives error.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- --outdir '.' already exists but --force was not given

Non empty (default) outdir with --force works

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --force "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES}" "${ACTUAL_SIGNATURES}"

Non empty outdir without --force gives error.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ mkdir "${OUTDIR}"
  $ pasv hmm --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- --outdir 'apple' already exists but --force was not given

Non empty outdir with --force works.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ mkdir "${OUTDIR}" && touch "${OUTDIR}"/pie
  $ pasv hmm --force --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

Keep intermediate files works.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --keep --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

Running twice with same args will give an error.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  $ pasv hmm --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- --outdir 'apple' already exists but --force was not given

Running twice with same args with --force works.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  $ pasv hmm --force --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

With ROI.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --outdir="${OUTDIR}" --roi-start="${ROI_START}" --roi-end="${ROI_END}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES_WITH_ROI}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

Quiet overrides verbosity.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm -vv --quiet --outdir="${OUTDIR}" --roi-start="${ROI_START}" --roi-end="${ROI_END}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES_WITH_ROI}" "${OUTDIR}/${ACTUAL_SIGNATURES}"
