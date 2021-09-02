Set up env variables.

  $ export QUERY_FILE=queries.fa
  $ export SIGNATURE_FILE=signatures.tsv
  $ export OUTDIR=apple
  $ export SANITIZE_LOGS=$PWD/../../helpers/sanitize_logs

Make sure it doesn't run out of file handles.  There was an out of
file handle error while testing on larger files, so this test is to
ensure it stays okay.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select -vv -F --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" ABC,CBA 2> log.txt
  $ "${SANITIZE_LOGS}" log.txt
  D, [DATE TIME PID] DEBUG -- outfile file: apple/signature_ABC.fa
  D, [DATE TIME PID] DEBUG -- outfile file: apple/signature_CBA.fa
  $ grep -c '^>' apple/*
  apple/signature_ABC.fa:1000
  apple/signature_CBA.fa:25
