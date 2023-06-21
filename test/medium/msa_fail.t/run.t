Set up environment variables.

  $ export SANITIZE_LOGS=sanitize_logs.sh
  $ export QUERIES=amk_queries.fa
  $ export REFS=P00582.refs.fa
  $ export MAIN_REF=amk_main_ref.fa
  $ export OUTDIR=apple
  $ export RESIDUES=50,52,54
  $ export ROI_START=20
  $ export ROI_END=80
  $ export SANITIZE_LOGS=./sanitize_logs
  $ export DOES_FILE_EXIST=../../helpers/does_file_exist

This aln outfile is okay as our query set only has one sequence.

  $ export ALN_OUTFILE=apple/refs_and_query_0.aln.fa

TODO need a way to test one of the queries failing but the others being okay.

###############################
#### Mixing up input files ####
###############################

Queries is not a fasta.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --roi-start=80 --roi-end=20 --outdir="${OUTDIR}" bad_fa.txt "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- file 'bad_fa.txt' doesn't look like an fasta file.  Check the file format!

Refs is not a fasta.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --roi-start=80 --roi-end=20 --outdir="${OUTDIR}" "${QUERIES}" bad_fa.txt "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- file 'bad_fa.txt' doesn't look like an fasta file.  Check the file format!

Queries is empty

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --roi-start=80 --roi-end=20 --outdir="${OUTDIR}" empty.txt "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- file 'empty.txt' doesn't look like an fasta file.  Check the file format!

Refs is empty.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --roi-start=80 --roi-end=20 --outdir="${OUTDIR}" "${QUERIES}" empty.txt "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- file 'empty.txt' doesn't look like an fasta file.  Check the file format!

#### Real zany stuff here

Bad exit code, no output file is made.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=./clustalo.msa_fail --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: ./clustalo.msa_fail --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  E, [DATE TIME PID] ERROR -- Command (./clustalo.msa_fail --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Max attempts exceeded.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  E, [DATE TIME PID] ERROR -- Error running msa: ("clustalo failed"
   ("job failed after max-retries"
    ("Process.run failed"
     ((prog ./clustalo.msa_fail)
      (args
       (--threads=1 -i apple/refs_and_query_0.fa -o
        apple/refs_and_query_0.aln.fa))
      (exit_status (Exit_non_zero 47)) (stdout "")
      (stderr ("a bad thing happened..." ""))))))
  F, [DATE TIME PID] FATAL -- Could not get signatures for any of the queries!


Bad exit code, output file made, but pasv still removes it.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=./clustalo.msa_fail_with_output_aln_file --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${DOES_FILE_EXIST}" "${ALN_OUTFILE}"
  no
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: ./clustalo.msa_fail_with_output_aln_file --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail_with_output_aln_file --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail_with_output_aln_file)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail_with_output_aln_file --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail_with_output_aln_file)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail_with_output_aln_file --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail_with_output_aln_file)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail_with_output_aln_file --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail_with_output_aln_file)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail_with_output_aln_file --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail_with_output_aln_file)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail_with_output_aln_file --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail_with_output_aln_file)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail_with_output_aln_file --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail_with_output_aln_file)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail_with_output_aln_file --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail_with_output_aln_file)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail_with_output_aln_file --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail_with_output_aln_file)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./clustalo.msa_fail_with_output_aln_file --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail_with_output_aln_file)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  E, [DATE TIME PID] ERROR -- Command (./clustalo.msa_fail_with_output_aln_file --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) failed.  Max attempts exceeded.
  Error was: ("Process.run failed"
   ((prog ./clustalo.msa_fail_with_output_aln_file)
    (args
     (--threads=1 -i apple/refs_and_query_0.fa -o
      apple/refs_and_query_0.aln.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  E, [DATE TIME PID] ERROR -- Error running msa: ("clustalo failed"
   ("job failed after max-retries"
    ("Process.run failed"
     ((prog ./clustalo.msa_fail_with_output_aln_file)
      (args
       (--threads=1 -i apple/refs_and_query_0.fa -o
        apple/refs_and_query_0.aln.fa))
      (exit_status (Exit_non_zero 47)) (stdout "")
      (stderr ("a bad thing happened..." ""))))))
  F, [DATE TIME PID] FATAL -- Could not get signatures for any of the queries!

Good exit code, but the outfile doesn't exist.  This would be a bug in
the MSA software.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=./clustalo.msa_success_no_outfile --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: ./clustalo.msa_success_no_outfile --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa
  E, [DATE TIME PID] ERROR -- Error running msa: Command (./clustalo.msa_success_no_outfile --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa) succeeded, but the outfile (apple/refs_and_query_0.aln.fa) does not exist!
  F, [DATE TIME PID] FATAL -- Could not get signatures for any of the queries!
This one outputs "fake" aln file without key reference.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=./clustalo.msa_success_no_key_ref --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: ./clustalo.msa_success_no_key_ref --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa
  E, [DATE TIME PID] ERROR -- ("error in check_alignment"
   "We didn't find the key ref sequence in 'apple/refs_and_query_0.aln.fa'")
  F, [DATE TIME PID] FATAL -- Could not get signatures for any of the queries!

This one outputs "fake" aln file with zero length query seq.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=./clustalo.msa_success_zero_len_seqs --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: ./clustalo.msa_success_zero_len_seqs --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa
  E, [DATE TIME PID] ERROR -- ("error in check_alignment"
   ("Error parsing alignment"
    (lib/check_alignment.ml.Bad_aln_length
     "Seq num: 2, Expected length: 4, Actual length: 0")))
  F, [DATE TIME PID] FATAL -- Could not get signatures for any of the queries!

This one outputs "fake" aln file with no queries, just key seqs.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=./clustalo.msa_success_only_key_seqs --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: ./clustalo.msa_success_only_key_seqs --threads=1 -i apple/refs_and_query_0.fa -o apple/refs_and_query_0.aln.fa
  E, [DATE TIME PID] ERROR -- ("error in check_alignment"
   "Should have at least one non-key record in 'apple/refs_and_query_0.aln.fa'")
  F, [DATE TIME PID] FATAL -- Could not get signatures for any of the queries!

###############
#### Mafft ####
###############

Same as above, but trick the software to go down the mafft pipeline.

Bad exit code, no output file is made.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=./mafft.msa_fail --alignment-parameters='--auto --thread 1' --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: ./mafft.msa_fail --auto --thread 1 apple/refs_and_query_0.fa
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  E, [DATE TIME PID] ERROR -- Command (./mafft.msa_fail --auto --thread 1 apple/refs_and_query_0.fa) failed.  Max attempts exceeded.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  E, [DATE TIME PID] ERROR -- Error running msa: ("mafft failed"
   ("job failed after max-retries"
    ("Process.run failed"
     ((prog ./mafft.msa_fail)
      (args (--auto --thread 1 apple/refs_and_query_0.fa))
      (exit_status (Exit_non_zero 47)) (stdout "")
      (stderr ("a bad thing happened..." ""))))))
  F, [DATE TIME PID] FATAL -- Could not get signatures for any of the queries!


Bad exit code, output file is made.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=./mafft.msa_fail_with_output_aln_file --alignment-parameters='--auto --thread 1' --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${DOES_FILE_EXIST}" "${ALN_OUTFILE}"
  no
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: ./mafft.msa_fail_with_output_aln_file --auto --thread 1 apple/refs_and_query_0.fa
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail_with_output_aln_file --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail_with_output_aln_file)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail_with_output_aln_file --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail_with_output_aln_file)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail_with_output_aln_file --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail_with_output_aln_file)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail_with_output_aln_file --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail_with_output_aln_file)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail_with_output_aln_file --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail_with_output_aln_file)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail_with_output_aln_file --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail_with_output_aln_file)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail_with_output_aln_file --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail_with_output_aln_file)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail_with_output_aln_file --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail_with_output_aln_file)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail_with_output_aln_file --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail_with_output_aln_file)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  W, [DATE TIME PID] WARN -- Command (./mafft.msa_fail_with_output_aln_file --auto --thread 1 apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail_with_output_aln_file)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  E, [DATE TIME PID] ERROR -- Command (./mafft.msa_fail_with_output_aln_file --auto --thread 1 apple/refs_and_query_0.fa) failed.  Max attempts exceeded.
  Error was: ("Process.run failed"
   ((prog ./mafft.msa_fail_with_output_aln_file)
    (args (--auto --thread 1 apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 47)) (stdout "")
    (stderr ("a bad thing happened..." ""))))
  E, [DATE TIME PID] ERROR -- Error running msa: ("mafft failed"
   ("job failed after max-retries"
    ("Process.run failed"
     ((prog ./mafft.msa_fail_with_output_aln_file)
      (args (--auto --thread 1 apple/refs_and_query_0.fa))
      (exit_status (Exit_non_zero 47)) (stdout "")
      (stderr ("a bad thing happened..." ""))))))
  F, [DATE TIME PID] FATAL -- Could not get signatures for any of the queries!

Good exit code, but the outfile doesn't exist.  For mafft it means
nothing to stdout.  This would be a weird mafft bug.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=./mafft.msa_success_no_outfile --alignment-parameters='--auto --thread 1' --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: ./mafft.msa_success_no_outfile --auto --thread 1 apple/refs_and_query_0.fa
  E, [DATE TIME PID] ERROR -- ("error in check_alignment"
   ("Error parsing alignment"
    (src/fasta_in_channel.ml.Exn
     "Not at a header line, but not currently in a sequence")))
  F, [DATE TIME PID] FATAL -- Could not get signatures for any of the queries!

This one outputs "fake" aln file without key reference.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=./mafft.msa_success_no_key_ref --alignment-parameters='--auto --thread 1' --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: ./mafft.msa_success_no_key_ref --auto --thread 1 apple/refs_and_query_0.fa
  E, [DATE TIME PID] ERROR -- ("error in check_alignment"
   "We didn't find the key ref sequence in 'apple/refs_and_query_0.aln.fa'")
  F, [DATE TIME PID] FATAL -- Could not get signatures for any of the queries!

This one outputs "fake" aln file with zero length query seq.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=./mafft.msa_success_zero_len_seqs --alignment-parameters='--auto --thread 1' --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: ./mafft.msa_success_zero_len_seqs --auto --thread 1 apple/refs_and_query_0.fa
  E, [DATE TIME PID] ERROR -- ("error in check_alignment"
   ("Error parsing alignment"
    (lib/check_alignment.ml.Bad_aln_length
     "Seq num: 2, Expected length: 4, Actual length: 0")))
  F, [DATE TIME PID] FATAL -- Could not get signatures for any of the queries!


This one outputs "fake" aln file with no queries, just key seqs.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=./mafft.msa_success_only_key_seqs --alignment-parameters='--auto --thread 1' --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: ./mafft.msa_success_only_key_seqs --auto --thread 1 apple/refs_and_query_0.fa
  E, [DATE TIME PID] ERROR -- ("error in check_alignment"
   "Should have at least one non-key record in 'apple/refs_and_query_0.aln.fa'")
  F, [DATE TIME PID] FATAL -- Could not get signatures for any of the queries!

##################################
#### Bad alignment parameters ####
##################################

Bogus mafft parameters is an error.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=mafft --alignment-parameters=teehee --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: mafft teehee apple/refs_and_query_0.fa
  W, [DATE TIME PID] WARN -- Command (mafft teehee apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog mafft) (args (teehee apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 1)) (stdout "")
    (stderr
     ("Unknown option:  teehee"
      ------------------------------------------------------------------------------
      "  https://mafft.cbrc.jp/alignment/software/"
      "  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)"
      ------------------------------------------------------------------------------
      "High speed:" "  % mafft in > out" "  % mafft --retree 1 in > out (fast)"
      "" "High accuracy (for <~200 sequences x <~2,000 aa/nt):"
      "  % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok)"
      "  % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out)"
      "  % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out)" ""
      "If unsure which option to use:" "  % mafft --auto in > out" ""
      "--op # :         Gap opening penalty, default: 1.53"
      "--ep # :         Offset (works like gap extension penalty), default: 0.0"
      "--maxiterate # : Maximum number of iterative refinement, default: 0"
      "--clustalout :   Output: clustal format, default: fasta"
      "--reorder :      Outorder: aligned, default: input order"
      "--quiet :        Do not report progress"
      "--thread # :     Number of threads (if unsure, --thread -1)"
      "--dash :         Add structural information (Rozewicki et al, submitted)"
      ""))))
  W, [DATE TIME PID] WARN -- Command (mafft teehee apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog mafft) (args (teehee apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 1)) (stdout "")
    (stderr
     ("Unknown option:  teehee"
      ------------------------------------------------------------------------------
      "  https://mafft.cbrc.jp/alignment/software/"
      "  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)"
      ------------------------------------------------------------------------------
      "High speed:" "  % mafft in > out" "  % mafft --retree 1 in > out (fast)"
      "" "High accuracy (for <~200 sequences x <~2,000 aa/nt):"
      "  % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok)"
      "  % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out)"
      "  % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out)" ""
      "If unsure which option to use:" "  % mafft --auto in > out" ""
      "--op # :         Gap opening penalty, default: 1.53"
      "--ep # :         Offset (works like gap extension penalty), default: 0.0"
      "--maxiterate # : Maximum number of iterative refinement, default: 0"
      "--clustalout :   Output: clustal format, default: fasta"
      "--reorder :      Outorder: aligned, default: input order"
      "--quiet :        Do not report progress"
      "--thread # :     Number of threads (if unsure, --thread -1)"
      "--dash :         Add structural information (Rozewicki et al, submitted)"
      ""))))
  W, [DATE TIME PID] WARN -- Command (mafft teehee apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog mafft) (args (teehee apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 1)) (stdout "")
    (stderr
     ("Unknown option:  teehee"
      ------------------------------------------------------------------------------
      "  https://mafft.cbrc.jp/alignment/software/"
      "  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)"
      ------------------------------------------------------------------------------
      "High speed:" "  % mafft in > out" "  % mafft --retree 1 in > out (fast)"
      "" "High accuracy (for <~200 sequences x <~2,000 aa/nt):"
      "  % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok)"
      "  % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out)"
      "  % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out)" ""
      "If unsure which option to use:" "  % mafft --auto in > out" ""
      "--op # :         Gap opening penalty, default: 1.53"
      "--ep # :         Offset (works like gap extension penalty), default: 0.0"
      "--maxiterate # : Maximum number of iterative refinement, default: 0"
      "--clustalout :   Output: clustal format, default: fasta"
      "--reorder :      Outorder: aligned, default: input order"
      "--quiet :        Do not report progress"
      "--thread # :     Number of threads (if unsure, --thread -1)"
      "--dash :         Add structural information (Rozewicki et al, submitted)"
      ""))))
  W, [DATE TIME PID] WARN -- Command (mafft teehee apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog mafft) (args (teehee apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 1)) (stdout "")
    (stderr
     ("Unknown option:  teehee"
      ------------------------------------------------------------------------------
      "  https://mafft.cbrc.jp/alignment/software/"
      "  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)"
      ------------------------------------------------------------------------------
      "High speed:" "  % mafft in > out" "  % mafft --retree 1 in > out (fast)"
      "" "High accuracy (for <~200 sequences x <~2,000 aa/nt):"
      "  % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok)"
      "  % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out)"
      "  % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out)" ""
      "If unsure which option to use:" "  % mafft --auto in > out" ""
      "--op # :         Gap opening penalty, default: 1.53"
      "--ep # :         Offset (works like gap extension penalty), default: 0.0"
      "--maxiterate # : Maximum number of iterative refinement, default: 0"
      "--clustalout :   Output: clustal format, default: fasta"
      "--reorder :      Outorder: aligned, default: input order"
      "--quiet :        Do not report progress"
      "--thread # :     Number of threads (if unsure, --thread -1)"
      "--dash :         Add structural information (Rozewicki et al, submitted)"
      ""))))
  W, [DATE TIME PID] WARN -- Command (mafft teehee apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog mafft) (args (teehee apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 1)) (stdout "")
    (stderr
     ("Unknown option:  teehee"
      ------------------------------------------------------------------------------
      "  https://mafft.cbrc.jp/alignment/software/"
      "  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)"
      ------------------------------------------------------------------------------
      "High speed:" "  % mafft in > out" "  % mafft --retree 1 in > out (fast)"
      "" "High accuracy (for <~200 sequences x <~2,000 aa/nt):"
      "  % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok)"
      "  % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out)"
      "  % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out)" ""
      "If unsure which option to use:" "  % mafft --auto in > out" ""
      "--op # :         Gap opening penalty, default: 1.53"
      "--ep # :         Offset (works like gap extension penalty), default: 0.0"
      "--maxiterate # : Maximum number of iterative refinement, default: 0"
      "--clustalout :   Output: clustal format, default: fasta"
      "--reorder :      Outorder: aligned, default: input order"
      "--quiet :        Do not report progress"
      "--thread # :     Number of threads (if unsure, --thread -1)"
      "--dash :         Add structural information (Rozewicki et al, submitted)"
      ""))))
  W, [DATE TIME PID] WARN -- Command (mafft teehee apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog mafft) (args (teehee apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 1)) (stdout "")
    (stderr
     ("Unknown option:  teehee"
      ------------------------------------------------------------------------------
      "  https://mafft.cbrc.jp/alignment/software/"
      "  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)"
      ------------------------------------------------------------------------------
      "High speed:" "  % mafft in > out" "  % mafft --retree 1 in > out (fast)"
      "" "High accuracy (for <~200 sequences x <~2,000 aa/nt):"
      "  % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok)"
      "  % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out)"
      "  % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out)" ""
      "If unsure which option to use:" "  % mafft --auto in > out" ""
      "--op # :         Gap opening penalty, default: 1.53"
      "--ep # :         Offset (works like gap extension penalty), default: 0.0"
      "--maxiterate # : Maximum number of iterative refinement, default: 0"
      "--clustalout :   Output: clustal format, default: fasta"
      "--reorder :      Outorder: aligned, default: input order"
      "--quiet :        Do not report progress"
      "--thread # :     Number of threads (if unsure, --thread -1)"
      "--dash :         Add structural information (Rozewicki et al, submitted)"
      ""))))
  W, [DATE TIME PID] WARN -- Command (mafft teehee apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog mafft) (args (teehee apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 1)) (stdout "")
    (stderr
     ("Unknown option:  teehee"
      ------------------------------------------------------------------------------
      "  https://mafft.cbrc.jp/alignment/software/"
      "  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)"
      ------------------------------------------------------------------------------
      "High speed:" "  % mafft in > out" "  % mafft --retree 1 in > out (fast)"
      "" "High accuracy (for <~200 sequences x <~2,000 aa/nt):"
      "  % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok)"
      "  % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out)"
      "  % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out)" ""
      "If unsure which option to use:" "  % mafft --auto in > out" ""
      "--op # :         Gap opening penalty, default: 1.53"
      "--ep # :         Offset (works like gap extension penalty), default: 0.0"
      "--maxiterate # : Maximum number of iterative refinement, default: 0"
      "--clustalout :   Output: clustal format, default: fasta"
      "--reorder :      Outorder: aligned, default: input order"
      "--quiet :        Do not report progress"
      "--thread # :     Number of threads (if unsure, --thread -1)"
      "--dash :         Add structural information (Rozewicki et al, submitted)"
      ""))))
  W, [DATE TIME PID] WARN -- Command (mafft teehee apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog mafft) (args (teehee apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 1)) (stdout "")
    (stderr
     ("Unknown option:  teehee"
      ------------------------------------------------------------------------------
      "  https://mafft.cbrc.jp/alignment/software/"
      "  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)"
      ------------------------------------------------------------------------------
      "High speed:" "  % mafft in > out" "  % mafft --retree 1 in > out (fast)"
      "" "High accuracy (for <~200 sequences x <~2,000 aa/nt):"
      "  % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok)"
      "  % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out)"
      "  % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out)" ""
      "If unsure which option to use:" "  % mafft --auto in > out" ""
      "--op # :         Gap opening penalty, default: 1.53"
      "--ep # :         Offset (works like gap extension penalty), default: 0.0"
      "--maxiterate # : Maximum number of iterative refinement, default: 0"
      "--clustalout :   Output: clustal format, default: fasta"
      "--reorder :      Outorder: aligned, default: input order"
      "--quiet :        Do not report progress"
      "--thread # :     Number of threads (if unsure, --thread -1)"
      "--dash :         Add structural information (Rozewicki et al, submitted)"
      ""))))
  W, [DATE TIME PID] WARN -- Command (mafft teehee apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog mafft) (args (teehee apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 1)) (stdout "")
    (stderr
     ("Unknown option:  teehee"
      ------------------------------------------------------------------------------
      "  https://mafft.cbrc.jp/alignment/software/"
      "  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)"
      ------------------------------------------------------------------------------
      "High speed:" "  % mafft in > out" "  % mafft --retree 1 in > out (fast)"
      "" "High accuracy (for <~200 sequences x <~2,000 aa/nt):"
      "  % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok)"
      "  % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out)"
      "  % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out)" ""
      "If unsure which option to use:" "  % mafft --auto in > out" ""
      "--op # :         Gap opening penalty, default: 1.53"
      "--ep # :         Offset (works like gap extension penalty), default: 0.0"
      "--maxiterate # : Maximum number of iterative refinement, default: 0"
      "--clustalout :   Output: clustal format, default: fasta"
      "--reorder :      Outorder: aligned, default: input order"
      "--quiet :        Do not report progress"
      "--thread # :     Number of threads (if unsure, --thread -1)"
      "--dash :         Add structural information (Rozewicki et al, submitted)"
      ""))))
  W, [DATE TIME PID] WARN -- Command (mafft teehee apple/refs_and_query_0.fa) failed.  Will retry.
  Error was: ("Process.run failed"
   ((prog mafft) (args (teehee apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 1)) (stdout "")
    (stderr
     ("Unknown option:  teehee"
      ------------------------------------------------------------------------------
      "  https://mafft.cbrc.jp/alignment/software/"
      "  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)"
      ------------------------------------------------------------------------------
      "High speed:" "  % mafft in > out" "  % mafft --retree 1 in > out (fast)"
      "" "High accuracy (for <~200 sequences x <~2,000 aa/nt):"
      "  % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok)"
      "  % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out)"
      "  % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out)" ""
      "If unsure which option to use:" "  % mafft --auto in > out" ""
      "--op # :         Gap opening penalty, default: 1.53"
      "--ep # :         Offset (works like gap extension penalty), default: 0.0"
      "--maxiterate # : Maximum number of iterative refinement, default: 0"
      "--clustalout :   Output: clustal format, default: fasta"
      "--reorder :      Outorder: aligned, default: input order"
      "--quiet :        Do not report progress"
      "--thread # :     Number of threads (if unsure, --thread -1)"
      "--dash :         Add structural information (Rozewicki et al, submitted)"
      ""))))
  E, [DATE TIME PID] ERROR -- Command (mafft teehee apple/refs_and_query_0.fa) failed.  Max attempts exceeded.
  Error was: ("Process.run failed"
   ((prog mafft) (args (teehee apple/refs_and_query_0.fa))
    (exit_status (Exit_non_zero 1)) (stdout "")
    (stderr
     ("Unknown option:  teehee"
      ------------------------------------------------------------------------------
      "  https://mafft.cbrc.jp/alignment/software/"
      "  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)"
      ------------------------------------------------------------------------------
      "High speed:" "  % mafft in > out" "  % mafft --retree 1 in > out (fast)"
      "" "High accuracy (for <~200 sequences x <~2,000 aa/nt):"
      "  % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok)"
      "  % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out)"
      "  % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out)" ""
      "If unsure which option to use:" "  % mafft --auto in > out" ""
      "--op # :         Gap opening penalty, default: 1.53"
      "--ep # :         Offset (works like gap extension penalty), default: 0.0"
      "--maxiterate # : Maximum number of iterative refinement, default: 0"
      "--clustalout :   Output: clustal format, default: fasta"
      "--reorder :      Outorder: aligned, default: input order"
      "--quiet :        Do not report progress"
      "--thread # :     Number of threads (if unsure, --thread -1)"
      "--dash :         Add structural information (Rozewicki et al, submitted)"
      ""))))
  E, [DATE TIME PID] ERROR -- Error running msa: ("mafft failed"
   ("job failed after max-retries"
    ("Process.run failed"
     ((prog mafft) (args (teehee apple/refs_and_query_0.fa))
      (exit_status (Exit_non_zero 1)) (stdout "")
      (stderr
       ("Unknown option:  teehee"
        ------------------------------------------------------------------------------
        "  https://mafft.cbrc.jp/alignment/software/"
        "  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)"
        ------------------------------------------------------------------------------
        "High speed:" "  % mafft in > out"
        "  % mafft --retree 1 in > out (fast)" ""
        "High accuracy (for <~200 sequences x <~2,000 aa/nt):"
        "  % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok)"
        "  % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out)"
        "  % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out)"
        "" "If unsure which option to use:" "  % mafft --auto in > out" ""
        "--op # :         Gap opening penalty, default: 1.53"
        "--ep # :         Offset (works like gap extension penalty), default: 0.0"
        "--maxiterate # : Maximum number of iterative refinement, default: 0"
        "--clustalout :   Output: clustal format, default: fasta"
        "--reorder :      Outorder: aligned, default: input order"
        "--quiet :        Do not report progress"
        "--thread # :     Number of threads (if unsure, --thread -1)"
        "--dash :         Add structural information (Rozewicki et al, submitted)"
        ""))))))
  F, [DATE TIME PID] FATAL -- Could not get signatures for any of the queries!

Using the default parameters with mafft works.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=mafft --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  $ "${SANITIZE_LOGS}" err
  I, [DATE TIME PID] INFO -- Working on query 1
  D, [DATE TIME PID] DEBUG -- Running command: mafft --thread 1 --auto apple/refs_and_query_0.fa

Special error condition for when the user sets more params for mafft
but keeps the --threads=1 from clustalo.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=mafft --alignment-parameters='--threads=1 --auto' --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  F, [DATE TIME PID] FATAL -- --other-parameters contains --threads.  This is valid for clustalo but not for mafft.  Did you use the correct aligner?  If you meant to use mafft, and you want a single thread, use --thread.  E.g., for mafft, try pasv msa --aligner=mafft --alignment-parameters='--thread 1 --auto' ...

Setting alignment parameters in weird ways raises errors.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=mafft --alignment-parameters '--auto' --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  pasv: unknown option '--auto', did you mean '-a'?
  Usage: pasv msa [OPTION]… QUERIES REFERENCES KEY_RESIDUES
  Try 'pasv msa --help' or 'pasv --help' for more information.

Bogus aligner.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=apple_pie --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  pasv: option '--aligner': invalid value 'apple_pie', expected clustalo,
        mafft, or a direct path to either program
  Usage: pasv msa [OPTION]… QUERIES REFERENCES KEY_RESIDUES
  Try 'pasv msa --help' or 'pasv --help' for more information.

Negative retries value.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --max-retries=-1 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  pasv: option '--max-retries': invalid value '-1', expected a number >= 0
  Usage: pasv msa [OPTION]… QUERIES REFERENCES KEY_RESIDUES
  Try 'pasv msa --help' or 'pasv --help' for more information.

String retries value.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --max-retries=apple --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  [1]
  $ "${SANITIZE_LOGS}" err
  pasv: option '--max-retries': invalid value 'apple', expected a number >= 0
  Usage: pasv msa [OPTION]… QUERIES REFERENCES KEY_RESIDUES
  Try 'pasv msa --help' or 'pasv --help' for more information.
