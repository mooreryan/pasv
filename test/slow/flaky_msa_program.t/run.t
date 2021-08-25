These don't test any weird CLI problems, just whether the results are
correct on the full query set with and without the ROI.

Set up environment variables.

  $ export QUERIES=amk_queries.fa
  $ export REFS=P00582.refs.fa
  $ export OUTDIR=apple
  $ export RESIDUES=50,52,54
  $ export EXPECTED_SIGNATURES_WITH_ROI=expected.with_roi.amk_queries.pasv_signatures.tsv
  $ export EXPECTED_VV_LOG=expected.sanitized_vv_log.txt
  $ export ACTUAL_SIGNATURES=amk_queries.pasv_signatures.tsv
  $ export ROI_START=20
  $ export ROI_END=80
  $ export SANITIZE_LOGS=./sanitize_logs

Flaky failing jobs restart.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ rm apple_pie
  $ RUN_FLAKY_MAFFT=apple_pie pasv msa -vv --aligner='./flaky_mafft'  --alignment-parameters='--thread 1 --auto' --jobs=4 --outdir="${OUTDIR}" --roi-start="${ROI_START}" --roi-end="${ROI_END}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  $ bash check_results.sh "${EXPECTED_SIGNATURES_WITH_ROI}" "${OUTDIR}/${ACTUAL_SIGNATURES}"

But if your max restarts is too low, then everything won't finish.
Max retries is 0 and jobs is 1.  flaky_mafft fails every other time in
a single threaded environment, so half the jobs will fail.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ [ -f apple_pie ] && rm apple_pie
  [1]
  $ RUN_FLAKY_MAFFT=apple_pie pasv msa -vv --max-retries=0 --aligner='./flaky_mafft'  --alignment-parameters='--thread 1 --auto' --jobs=1 --outdir="${OUTDIR}" --roi-start="${ROI_START}" --roi-end="${ROI_END}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err

Half of those jobs should fail, so this should be 13.  (12 query rows
and the header)

  $ wc -l "${OUTDIR}/${ACTUAL_SIGNATURES}"
  13 apple/amk_queries.pasv_signatures.tsv
