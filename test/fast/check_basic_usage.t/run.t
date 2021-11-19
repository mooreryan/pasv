Note that in this test, the alignment file has the main ref as the
first sequence and the queries from the hmm test, so the expected
values are all the same.

Set up environment variables.

  $ export ALN=amk_main_ref_queries.aln.fa
  $ export OUTDIR=apple
  $ export RESIDUES=50,52,54
  $ export EXPECTED_SIGNATURES=expected.amk_main_ref_queries.aln.pasv_signatures.tsv
  $ export ACTUAL_SIGNATURES=amk_main_ref_queries.aln.pasv_signatures.tsv
  $ export ROI_START=20
  $ export ROI_END=80
  $ export EXPECTED_SIGNATURES_WITH_ROI=expected.with_roi.amk_main_ref_queries.aln.pasv_signatures.tsv
  $ export EXPECTED_SIGNATURES_WITH_ROI_START=expected.with_start.amk_main_ref_queries.aln.pasv_signatures.tsv
  $ export EXPECTED_SIGNATURES_WITH_ROI_END=expected.with_end.amk_main_ref_queries.aln.pasv_signatures.tsv
  $ export SANITIZE_LOGS=$PWD/../../helpers/sanitize_logs

Help screen

  $ pasv check --help=plain
  NAME
         pasv-check - use precomputed alignments
  
  SYNOPSIS
         pasv check [OPTION]... ALIGNMENT KEY_RESIDUES
  
  DESCRIPTION
         Use pasv-check when you already have an alignment file in which you
         want to check key residues or ROI.
  
         I assume the first sequence is the key reference. All positions will
         be with respect to this sequence.
  
  ARGUMENTS
         ALIGNMENT (required)
             Path to alignment file.
  
         KEY_RESIDUES (required)
             Key residues (comma separated)
  
  OPTIONS
         -e ROI_END, --roi-end=ROI_END
             Region of interest end (ROI) (1-indexed)
  
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
  
           $ pasv check aln.faa 500,502,504
  
         === Specifying an output directory, ROI start, and ROI end
  
           $ pasv check --outdir=pasv_output \ 
                        --roi-start=200 \ 
                        --roi-end=800 \ 
                        aln.faa \ 
                        500,502,504
  

####################################################################

Non empty (default) outdir without --force gives error.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv check "${ALN}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- --outdir '.' already exists but --force was not given

Non empty (default) outdir with --force works

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv check --force "${ALN}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES}" "${ACTUAL_SIGNATURES}"

Non empty outdir without --force gives error.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ mkdir "${OUTDIR}"
  $ pasv check --outdir="${OUTDIR}" "${ALN}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- --outdir 'apple' already exists but --force was not given

Non empty outdir with --force works.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ mkdir "${OUTDIR}" && touch "${OUTDIR}"/pie
  $ pasv check --force --outdir="${OUTDIR}" "${ALN}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

Running twice with same args will give an error.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv check --outdir="${OUTDIR}" "${ALN}" "${RESIDUES}"
  $ pasv check --outdir="${OUTDIR}" "${ALN}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- --outdir 'apple' already exists but --force was not given

Running twice with same args with --force works.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv check --outdir="${OUTDIR}" "${ALN}" "${RESIDUES}"
  $ pasv check --force --outdir="${OUTDIR}" "${ALN}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

With ROI.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv check --outdir="${OUTDIR}" --roi-start="${ROI_START}" --roi-end="${ROI_END}" "${ALN}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES_WITH_ROI}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

With ROI start.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv check --outdir="${OUTDIR}" --roi-start="${ROI_START}" "${ALN}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES_WITH_ROI_START}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

With ROI end.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv check --outdir="${OUTDIR}" --roi-end="${ROI_END}" "${ALN}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES_WITH_ROI_END}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

Bad fasta

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv check --outdir="${OUTDIR}" --roi-start="${ROI_START}" --roi-end="${ROI_END}" bad_fa.txt "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- file 'bad_fa.txt' doesn't look like an fasta file.  Check the file format!

ROI start isn't a string

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv check --outdir="${OUTDIR}" --roi-start=apple "${ALN}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  pasv: option `--roi-start': invalid value 'apple', expected a number >= 1
  Usage: pasv check [OPTION]... ALIGNMENT KEY_RESIDUES
  Try `pasv check --help' or `pasv --help' for more information.

ROI end isn't a string

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv check --outdir="${OUTDIR}" --roi-end=apple "${ALN}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  pasv: option `--roi-end': invalid value 'apple', expected a number >= 1
  Usage: pasv check [OPTION]... ALIGNMENT KEY_RESIDUES
  Try `pasv check --help' or `pasv --help' for more information.

Check version.

  $ pasv check --version
  2.0.1
