These don't test any weird CLI problems, just whether the results are
correct on the full query set with and without the ROI.

Set up environment variables.

  $ export QUERIES=amk_queries.fa
  $ export REFS=P00582.refs.fa
  $ export OUTDIR=apple
  $ export RESIDUES=50,52,54
  $ export EXPECTED_SIGNATURES=expected.amk_queries.pasv_signatures.tsv
  $ export EXPECTED_SIGNATURES_WITH_ROI=expected.with_roi.amk_queries.pasv_signatures.tsv
  $ export EXPECTED_VV_LOG=expected.sanitized_vv_log.txt
  $ export EXPECTED_V_LOG=expected.sanitized_v_log.txt
  $ export ACTUAL_SIGNATURES=amk_queries.pasv_signatures.tsv
  $ export ROI_START=20
  $ export ROI_END=80

Without ROI.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -v --jobs=4 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  $ bash check_results.sh "${EXPECTED_SIGNATURES}" "${OUTDIR}/${ACTUAL_SIGNATURES}"
  $ bash sanitize_logs.sh err > err_sanitized
  $ diff "${EXPECTED_V_LOG}" err_sanitized

With ROI.  Note that the log sanitizing is a bit different as the
order may be different since it's async.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --jobs=4 --outdir="${OUTDIR}" --roi-start="${ROI_START}" --roi-end="${ROI_END}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  $ bash check_results.sh "${EXPECTED_SIGNATURES_WITH_ROI}" "${OUTDIR}/${ACTUAL_SIGNATURES}"
  $ bash sanitize_logs.sh err > err_sanitized
  $ diff "${EXPECTED_VV_LOG}" err_sanitized

#########################################
#### Using mafft instead of clustalo ####
#########################################

Without ROI.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -v --aligner=mafft --alignment-parameters='--thread 1 --auto' --jobs=4 --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  $ bash check_results.sh "${EXPECTED_SIGNATURES}" "${OUTDIR}/${ACTUAL_SIGNATURES}"
  $ bash sanitize_logs.sh err > err_sanitized
  $ diff "${EXPECTED_V_LOG}" err_sanitized

With ROI.  Note that the log sanitizing is a bit different as the
order may be different since it's async.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa -vv --aligner=mafft --alignment-parameters='--thread 1 --auto' --jobs=4 --outdir="${OUTDIR}" --roi-start="${ROI_START}" --roi-end="${ROI_END}" "${QUERIES}" "${REFS}" "${RESIDUES}" 2> err
  $ bash check_results.sh "${EXPECTED_SIGNATURES_WITH_ROI}" "${OUTDIR}/${ACTUAL_SIGNATURES}"
  $ bash sanitize_logs.sh err > err_sanitized
  $ diff "${EXPECTED_VV_LOG}" err_sanitized

