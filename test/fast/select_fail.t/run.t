Set up env variables.

  $ export QUERY_FILE=queries.fa
  $ export SIGNATURE_FILE=signatures.tsv
  $ export OUTDIR=apple
  $ export SANITIZE_LOGS=$PWD/../../helpers/sanitize_logs

Bad header in signatures file.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select -F --outdir="${OUTDIR}" "${QUERY_FILE}" bad_header.tsv AAA 2> log
  [1]
  $ "${SANITIZE_LOGS}" log
  E, [DATE TIME PID] ERROR -- The first column of the signature file should be 'name'.  Got 'Name'.
  E, [DATE TIME PID] ERROR -- The last column the signature file should be 'spans'.  Got 'spas'.
  E, [DATE TIME PID] ERROR -- The second to last column the signature file should be 'spans_end'.  Got 'spans-end'.
  E, [DATE TIME PID] ERROR -- The third to last column the signature file should be 'spans_start'.  Got 'spansstart'.
  E, [DATE TIME PID] ERROR -- The fourth to last column the signature file should be 'signature'.  Got 'signatures'.
  F, [DATE TIME PID] FATAL -- Signature file 'bad_header.tsv' has a bad header!

Too few columns in header in signatures file.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select -F --outdir="${OUTDIR}" "${QUERY_FILE}" short_header.tsv AAA 2> log
  [1]
  $ "${SANITIZE_LOGS}" log
  E, [DATE TIME PID] ERROR -- Signature file should have 6 or more columns.  Got 4.
  E, [DATE TIME PID] ERROR -- The last column the signature file should be 'spans'.  Got 'spans_end'.
  E, [DATE TIME PID] ERROR -- The second to last column the signature file should be 'spans_end'.  Got 'spans_start'.
  E, [DATE TIME PID] ERROR -- The third to last column the signature file should be 'spans_start'.  Got 'signature'.
  E, [DATE TIME PID] ERROR -- The fourth to last column the signature file should be 'signature'.  Got 'name'.
  F, [DATE TIME PID] FATAL -- Signature file 'short_header.tsv' has a bad header!

Bad signatures file.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select -F --outdir="${OUTDIR}" "${QUERY_FILE}" bad_signatures.txt AAA 2> log
  [1]
  $ "${SANITIZE_LOGS}" log
  E, [DATE TIME PID] ERROR -- Signature file should have 6 or more columns.  Got 1.
  E, [DATE TIME PID] ERROR -- The first column of the signature file should be 'name'.  Got 'bad sig file'.
  E, [DATE TIME PID] ERROR -- The last column the signature file should be 'spans'.  Got 'bad sig file'.
  E, [DATE TIME PID] ERROR -- Couldn't get 'spans_end' column from header.  It's probably too short.  Bad index (-1); ary length is (1).
  E, [DATE TIME PID] ERROR -- Couldn't get 'spans_start' column from header.  It's probably too short.  Bad index (-2); ary length is (1).
  E, [DATE TIME PID] ERROR -- Couldn't get 'signature' column from header.  It's probably too short.  Bad index (-3); ary length is (1).
  F, [DATE TIME PID] FATAL -- Signature file 'bad_signatures.txt' has a bad header!

Bad row length (Seq_06)

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select -F --outdir="${OUTDIR}" "${QUERY_FILE}" bad_row_length.tsv AAA 2> log
  [1]
  $ "${SANITIZE_LOGS}" log
  F, [DATE TIME PID] FATAL -- Line 'Seq_06__ABA__Yes__No__Start	A	B	A	Yes	No	Start' had 7 column(s) but should have had 8 columns.

Bad fasta file.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select -F --outdir="${OUTDIR}" bad_fasta.fa "${SIGNATURE_FILE}" AAA 2> log
  [1]
  $ "${SANITIZE_LOGS}" log
  F, [DATE TIME PID] FATAL -- file 'bad_fasta.fa' doesn't look like an fasta file.  Check the file format!

Wrong seqs in fasta file.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select -F --outdir="${OUTDIR}" wrong_seqs.fa "${SIGNATURE_FILE}" AAA 2> log
  $ "${SANITIZE_LOGS}" log
  W, [DATE TIME PID] WARN -- No query sequences were printed.  Do your query file and signatures file match?

Non-existing signature (fixed-strings, keep)

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select -F --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" XXX 2> log
  [1]
  $ "${SANITIZE_LOGS}" log
  W, [DATE TIME PID] WARN -- There were no sequence IDs to keep!  Outdir 'apple' will be empty.  Check your signatures and make sure they're correct!  You did not pass --reject...did you mean to?    You passed --fixed-strings...did you mean to?

Non-existing signature (fixed-strings, reject)

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject -F --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA,ABA,ACB,ADB 2> log
  [1]
  $ "${SANITIZE_LOGS}" log
  W, [DATE TIME PID] WARN -- There were no sequence IDs to keep!  Outdir 'apple' will be empty.  Check your signatures and make sure they're correct!  You passed --reject...did you mean to?    You passed --fixed-strings...did you mean to?

Non-existing signature (regex, keep)

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" XXX 2> log
  [1]
  $ "${SANITIZE_LOGS}" log
  W, [DATE TIME PID] WARN -- There were no sequence IDs to keep!  Outdir 'apple' will be empty.  Check your signatures and make sure they're correct!  You did not pass --reject...did you mean to?    You did not pass --fixed-strings...did you mean to?

Non-existing signature (regex, reject)

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA,ABA,ACB,ADB 2> log
  [1]
  $ "${SANITIZE_LOGS}" log
  W, [DATE TIME PID] WARN -- There were no sequence IDs to keep!  Outdir 'apple' will be empty.  Check your signatures and make sure they're correct!  You passed --reject...did you mean to?    You did not pass --fixed-strings...did you mean to?

Empty signature file.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject --outdir="${OUTDIR}" "${QUERY_FILE}" empty_file AAA 2> log
  [1]
  $ "${SANITIZE_LOGS}" log
  F, [DATE TIME PID] FATAL -- Signature file 'empty_file' has no lines!

Empty fasta file.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject --outdir="${OUTDIR}" empty_file "${SIGNATURE_FILE}" AAA 2> log
  [1]
  $ "${SANITIZE_LOGS}" log
  F, [DATE TIME PID] FATAL -- file 'empty_file' doesn't look like an fasta file.  Check the file format!

Duplicate signatures.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --outdir="${OUTDIR}" "${QUERY_FILE}" duplicate_signatures.tsv AAA 2> log
  [1]
  $ "${SANITIZE_LOGS}" log
  F, [DATE TIME PID] FATAL -- Name Seq_01__AAA__Yes__Yes__Both was duplicated in the signatures file.  pasv does not duplicate sequences in the signatures file.  Did you edit the file by hand?  If not, please submit a bug report.
