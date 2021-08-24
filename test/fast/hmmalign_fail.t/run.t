Set up environment variables.

  $ export SANITIZE_LOGS=sanitize_logs.sh
  $ export QUERIES=amk_queries.fa
  $ export REFS=P00582.refs.aln.hmm
  $ export MAIN_REF=amk_main_ref.fa
  $ export OUTDIR=apple
  $ export RESIDUES=50,52,54
  $ export ROI_START=20
  $ export ROI_END=80
  $ export ALN_OUTFILE=apple/amk_queries.aln.fa
  $ export SANITIZE_LOGS=./sanitize_logs

Bad exit code

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm -vv --hmmalign=./bad_hmmalign --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  D, [DATE TIME PID] DEBUG -- Running command: ./bad_hmmalign --outformat=afa -o apple/amk_queries.aln.fa P00582.refs.aln.hmm apple/pasv.tmp.REDACTED.queries.fasta
  F, [DATE TIME PID] FATAL -- There was an error running hmmalign
  ("hmmalign failed" (Unix.Exit_or_signal (Exit_non_zero 47)))
  == hmmalign stdout ==
  
  == hmmalign stderr ==
  a bad thing happened...
  
  $ ./does_file_exist "${ALN_OUTFILE}"
  no

Good exit code, but the outfile doesn't exist.  

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm -vv --hmmalign=./hmmalign_success_no_outfile --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  D, [DATE TIME PID] DEBUG -- Running command: ./hmmalign_success_no_outfile --outformat=afa -o apple/amk_queries.aln.fa P00582.refs.aln.hmm apple/pasv.tmp.REDACTED.queries.fasta
  F, [DATE TIME PID] FATAL -- There was an error running hmmalign
  hmmalign succeeded, but the outfile (apple/amk_queries.aln.fa) does not exist!
  == hmmalign stdout ==
  a good thing
  
  == hmmalign stderr ==
  
This one outputs "fake" aln file without key reference.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm -vv --hmmalign=./success_no_key_ref --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  D, [DATE TIME PID] DEBUG -- Running command: ./success_no_key_ref --outformat=afa -o apple/amk_queries.aln.fa P00582.refs.aln.hmm apple/pasv.tmp.REDACTED.queries.fasta
  F, [DATE TIME PID] FATAL -- 
  ("Error running pasv hmm"
   ("error in check_alignment"
    "We didn't find the key ref sequence in 'apple/amk_queries.aln.fa'"))

This one outputs "fake" aln file with zero length query seq.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm -vv --hmmalign=./success_zero_len_seqs --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  D, [DATE TIME PID] DEBUG -- Running command: ./success_zero_len_seqs --outformat=afa -o apple/amk_queries.aln.fa P00582.refs.aln.hmm apple/pasv.tmp.REDACTED.queries.fasta
  F, [DATE TIME PID] FATAL -- 
  ("Error running pasv hmm"
   ("error in check_alignment"
    ("Error parsing alignment"
     (lib/check_alignment.ml.Bad_aln_length
      "Seq num: 2, Expected length: 4, Actual length: 0"))))

This one outputs "fake" aln file with no queries, just key seqs.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv hmm -vv --hmmalign=./success_only_key_seqs --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  D, [DATE TIME PID] DEBUG -- Running command: ./success_only_key_seqs --outformat=afa -o apple/amk_queries.aln.fa P00582.refs.aln.hmm apple/pasv.tmp.REDACTED.queries.fasta
  F, [DATE TIME PID] FATAL -- 
  ("Error running pasv hmm"
   ("error in check_alignment"
    "Should have at least one non-key record in 'apple/amk_queries.aln.fa'"))

