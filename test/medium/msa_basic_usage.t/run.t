Basic successful MSA tests.  The queries are only 1 sequence to make
it quick.  Full tests are in the test/slow folder.

Set up environment variables.

  $ export QUERIES=amk_queries.fa
  $ export REFS=P00582.refs.fa
  $ export OUTDIR=apple
  $ export RESIDUES=50,52,54
  $ export EXPECTED_SIGNATURES=expected.amk_queries.pasv_signatures.tsv
  $ export EXPECTED_SIGNATURES_WITH_ROI=expected.with_roi.amk_queries.pasv_signatures.tsv
  $ export ACTUAL_SIGNATURES=amk_queries.pasv_signatures.tsv
  $ export ROI_START=20
  $ export ROI_END=80
  $ export SANITIZE_LOGS=$PWD/../../helpers/sanitize_logs

Help screen

  $ pasv msa --help=plain
  NAME
         pasv-msa - use multiple sequence alignments
  
  SYNOPSIS
         pasv msa [OPTION]... QUERIES REFERENCES KEY_RESIDUES
  
  DESCRIPTION
         Use a multiple sequence aligner for the alignments.
  
         Each query is aligned individually with reference sequences
  
  ARGUMENTS
         KEY_RESIDUES (required)
             Key residues (comma separated)
  
         QUERIES (required)
             Path to query sequences.
  
         REFERENCES (required)
             Path to reference sequence fasta.
  
  OPTIONS
         -a ALIGNER, --aligner=ALIGNER (absent=clustalo)
             Name of aligner executable. If it is a name, then it is searched
             on the PATH, if it is a path, it is treated as a path to the
             executable.
  
         --alignment-parameters=ALIGNMENT_PARAMETERS (absent=--threads=1)
             Other alignment params. If the you need spaces, put single quotes
             around them. This is very important...you need to use the `=`
             between the flag and the argument like this:
             --alignment-parameters=--auto, or whatever args you want. If the
             parameters include '-' characters, do it like so
             --alignment-parameters='--threads 1 --thingies 46'. The default
             shown is for clustalo. If the aligner is set to mafft (eg with
             --aligner=mafft), then the default will be '--thread 1 --auto'. If
             you don't want that, you can specify the this option in the usual
             way.
  
         -e ROI_END, --roi-end=ROI_END
             Region of interest end (ROI) (1-indexed)
  
         -j JOBS, --jobs=JOBS (absent=1)
             Number of jobs to run.
  
         -k, --keep
             Keep intermediate files
  
         -r MAX_RETRIES, --max-retries=MAX_RETRIES (absent=10)
             Maximum number of job retries. Sometimes the MSA software will
             fail, so individual jobs will be retried until they succeed or
             until this number of tries is reached.
  
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
  
           $ pasv msa queries.faa refs.faa 500,502,504
  
         === Specifying an output directory, ROI start, ROI end, and num. jobs
  
           $ pasv msa --outdir=pasv_output \ 
                      --roi-start=200 \ 
                      --roi-end=800 \ 
                      --jobs=4 \ 
                      queries.faa \ 
                      refs.faa \ 
                      500,502,504
  


Basic usage works.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}"
  $ column -t "${OUTDIR}"/amk_queries.pasv_signatures.tsv
  name                           pos_50  pos_52  pos_54  signature  spans_start  spans_end  spans
  AMK99662_spans_both_20_80_IQK  I       Q       K       IQK        NA           NA         NA

A single residue also works.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" 50
  $ column -t "${OUTDIR}"/amk_queries.pasv_signatures.tsv
  name                           pos_50  signature  spans_start  spans_end  spans
  AMK99662_spans_both_20_80_IQK  I       I          NA           NA         NA

Non empty (default) outdir without --force gives error.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- --outdir '.' already exists but --force was not given

Non empty (default) outdir with --force works.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --force "${QUERIES}" "${REFS}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES}" "${ACTUAL_SIGNATURES}"

Non empty outdir without --force gives error.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ mkdir "${OUTDIR}"
  $ pasv msa --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- --outdir 'apple' already exists but --force was not given

Non empty outdir with --force works.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ mkdir "${OUTDIR}" && touch "${OUTDIR}"/pie
  $ pasv msa --force --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

Keep intermediate files works.  TODO actually check intermediate files.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --keep --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

Running twice with same args will give an error.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}"
  $ pasv msa --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- --outdir 'apple' already exists but --force was not given

Running twice with same args with --force works.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}"
  $ pasv msa --force --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

With ROI.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --outdir="${OUTDIR}" --roi-start="${ROI_START}" --roi-end="${ROI_END}" "${QUERIES}" "${REFS}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES_WITH_ROI}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

TODO test the other aligners not on the path.

Using mafft with no alignment params uses default mafft params.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=mafft --outdir="${OUTDIR}" --roi-start="${ROI_START}" --roi-end="${ROI_END}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> log.txt
  $ "${SANITIZE_LOGS}" log.txt
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: mafft --thread 1 --auto apple/refs_and_query_0.fa
  $ diff "${EXPECTED_SIGNATURES_WITH_ROI}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

You can specify an aligner with a path (mafft).

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --aligner=$(which mafft) --outdir="${OUTDIR}" --roi-start="${ROI_START}" --roi-end="${ROI_END}" "${QUERIES}" "${REFS}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES_WITH_ROI}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

You can specify an aligner with a path (clustalo).

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --aligner=$(which clustalo) --outdir="${OUTDIR}" --roi-start="${ROI_START}" --roi-end="${ROI_END}" "${QUERIES}" "${REFS}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES_WITH_ROI}" "${OUTDIR}/${ACTUAL_SIGNATURES}"
