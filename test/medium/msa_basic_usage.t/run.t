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

Non empty (default) outdir with --force works.

  $ rm -r "${OUTDIR}" pasv.tmp.* "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv msa --force "${QUERIES}" "${REFS}" "${RESIDUES}"
  $ diff "${EXPECTED_SIGNATURES}" "${ACTUAL_SIGNATURES}"

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
