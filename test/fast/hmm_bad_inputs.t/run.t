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


######################
#### Bad residues ####
######################

Missing residue positions.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}"
  pasv: required argument KEY_RESIDUES is missing
  Usage: pasv hmm [OPTION]… QUERIES REFERENCES KEY_REFERENCE KEY_RESIDUES
  Try 'pasv hmm --help' or 'pasv --help' for more information.
  [1]

Single of range residue.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" -234
  pasv: unknown option '-2'.
  Usage: pasv hmm [OPTION]… QUERIES REFERENCES KEY_REFERENCE KEY_RESIDUES
  Try 'pasv hmm --help' or 'pasv --help' for more information.
  [1]
  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" -234,20
  pasv: unknown option '-2'.
  Usage: pasv hmm [OPTION]… QUERIES REFERENCES KEY_REFERENCE KEY_RESIDUES
  Try 'pasv hmm --help' or 'pasv --help' for more information.
  [1]

Actually parsing negative residues. 

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" 20,-234
  pasv: KEY_RESIDUES argument: invalid element in list ('20,-234'): invalid
        value '-234', expected a number >= 1
  Usage: pasv hmm [OPTION]… QUERIES REFERENCES KEY_REFERENCE KEY_RESIDUES
  Try 'pasv hmm --help' or 'pasv --help' for more information.
  [1]

Actually parsing residues that are too high.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" 20,200000 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- 
  ("Error running pasv hmm"
   ("error in check_alignment"
    ("The zero-indexed raw position does not have an in zero-indexed alignment position map.  Check the residues...are they out of bounds?"
     ("key not found" 199999))))

#################
#### Bad ROI ####
#################

Negative ROI start (long, equals)

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --roi-start=-200 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  pasv: option '--roi-start': invalid value '-200', expected a number >= 1
  Usage: pasv hmm [OPTION]… QUERIES REFERENCES KEY_REFERENCE KEY_RESIDUES
  Try 'pasv hmm --help' or 'pasv --help' for more information.
  [1]

Negative ROI start (long, space)

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --roi-start -200 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  pasv: unknown option '-2'.
  Usage: pasv hmm [OPTION]… QUERIES REFERENCES KEY_REFERENCE KEY_RESIDUES
  Try 'pasv hmm --help' or 'pasv --help' for more information.
  [1]

Negative ROI start (short option)

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm -s-200 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  pasv: option '-s': invalid value '-200', expected a number >= 1
  Usage: pasv hmm [OPTION]… QUERIES REFERENCES KEY_REFERENCE KEY_RESIDUES
  Try 'pasv hmm --help' or 'pasv --help' for more information.
  [1]

Negative ROI start (short option)

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm -s -200 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  pasv: unknown option '-2'.
  Usage: pasv hmm [OPTION]… QUERIES REFERENCES KEY_REFERENCE KEY_RESIDUES
  Try 'pasv hmm --help' or 'pasv --help' for more information.
  [1]

Negative ROI end (long, equals)

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --roi-end=-200 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  pasv: option '--roi-end': invalid value '-200', expected a number >= 1
  Usage: pasv hmm [OPTION]… QUERIES REFERENCES KEY_REFERENCE KEY_RESIDUES
  Try 'pasv hmm --help' or 'pasv --help' for more information.
  [1]

Negative ROI end (long, space)

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --roi-end -200 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  pasv: unknown option '-2'.
  Usage: pasv hmm [OPTION]… QUERIES REFERENCES KEY_REFERENCE KEY_RESIDUES
  Try 'pasv hmm --help' or 'pasv --help' for more information.
  [1]

Negative ROI end (short option)

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm -e-200 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  pasv: option '-e': invalid value '-200', expected a number >= 1
  Usage: pasv hmm [OPTION]… QUERIES REFERENCES KEY_REFERENCE KEY_RESIDUES
  Try 'pasv hmm --help' or 'pasv --help' for more information.
  [1]

Negative ROI end (short option)

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm -e -200 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
  pasv: unknown option '-2'.
  Usage: pasv hmm [OPTION]… QUERIES REFERENCES KEY_REFERENCE KEY_RESIDUES
  Try 'pasv hmm --help' or 'pasv --help' for more information.
  [1]

ROI start equals ROI end gives error.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --roi-start=80 --roi-end=80 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- ROI start (79) is should be strictly less than ROI end (79)

ROI start greater than ROI end gives error.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --roi-start=80 --roi-end=20 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- ROI start (79) is should be strictly less than ROI end (19)

###############################
#### Mixing up input files ####
###############################

Passing fasta when I expect hmm file.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --roi-start=80 --roi-end=20 --outdir="${OUTDIR}" "${QUERIES}" "${MAIN_REF}" "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- file 'amk_main_ref.fa' doesn't look like an hmm file.  Check the file format!

Passing hmm file to queries.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --roi-start=80 --roi-end=20 --outdir="${OUTDIR}" "${REFS}" "${REFS}" "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- file 'P00582.refs.aln.hmm' doesn't look like an fasta file.  Check the file format!

Passing hmm file to key ref.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --roi-start=80 --roi-end=20 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- file 'P00582.refs.aln.hmm' doesn't look like an fasta file.  Check the file format!



########



Empty queries.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --roi-start=80 --roi-end=20 --outdir="${OUTDIR}" empty.txt "${REFS}" "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- file 'empty.txt' doesn't look like an fasta file.  Check the file format!

Empty refs.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --roi-start=80 --roi-end=20 --outdir="${OUTDIR}" "${QUERIES}" empty.txt "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- file 'empty.txt' doesn't look like an hmm file.  Check the file format!

Empty key sequence.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm --roi-start=80 --roi-end=20 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" empty.txt "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- file 'empty.txt' doesn't look like an fasta file.  Check the file format!

