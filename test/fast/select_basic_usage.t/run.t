Set up env variables.

  $ export QUERY_FILE=queries.fa
  $ export SIGNATURE_FILE=signatures.tsv
  $ export OUTDIR=apple

####
#### Single, fixed string.
####

Keep

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select -F --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_AAA.fa ===
  >Seq_01__AAA__Yes__Yes__Both
  01
  >Seq_05__AAA__Yes__No__Start
  05
  >Seq_09__AAA__No__Yes__End
  09
  >Seq_13__AAA__No__No__Neither
  13

Reject

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject -F --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  02
  >Seq_06__ABA__Yes__No__Start
  06
  >Seq_10__ABA__No__Yes__End
  10
  >Seq_14__ABA__No__No__Neither
  14
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  03
  >Seq_07__ACB__Yes__No__Start
  07
  >Seq_11__ACB__No__Yes__End
  11
  >Seq_15__ACB__No__No__Neither
  15
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  04
  >Seq_08__ADB__Yes__No__Start
  08
  >Seq_12__ADB__No__Yes__End
  12
  >Seq_16__ADB__No__No__Neither
  16

####
#### Single, regex.
####

Keep

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_AAA.fa ===
  >Seq_01__AAA__Yes__Yes__Both
  01
  >Seq_05__AAA__Yes__No__Start
  05
  >Seq_09__AAA__No__Yes__End
  09
  >Seq_13__AAA__No__No__Neither
  13

Reject

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  02
  >Seq_06__ABA__Yes__No__Start
  06
  >Seq_10__ABA__No__Yes__End
  10
  >Seq_14__ABA__No__No__Neither
  14
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  03
  >Seq_07__ACB__Yes__No__Start
  07
  >Seq_11__ACB__No__Yes__End
  11
  >Seq_15__ACB__No__No__Neither
  15
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  04
  >Seq_08__ADB__Yes__No__Start
  08
  >Seq_12__ADB__No__Yes__End
  12
  >Seq_16__ADB__No__No__Neither
  16

####
#### Single, regex fancy.
####

Keep 

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" '[AC].$'
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_AAA.fa ===
  >Seq_01__AAA__Yes__Yes__Both
  01
  >Seq_05__AAA__Yes__No__Start
  05
  >Seq_09__AAA__No__Yes__End
  09
  >Seq_13__AAA__No__No__Neither
  13
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  03
  >Seq_07__ACB__Yes__No__Start
  07
  >Seq_11__ACB__No__Yes__End
  11
  >Seq_15__ACB__No__No__Neither
  15

Reject 

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" '[AC].$'
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  02
  >Seq_06__ABA__Yes__No__Start
  06
  >Seq_10__ABA__No__Yes__End
  10
  >Seq_14__ABA__No__No__Neither
  14
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  04
  >Seq_08__ADB__Yes__No__Start
  08
  >Seq_12__ADB__No__Yes__End
  12
  >Seq_16__ADB__No__No__Neither
  16

####
#### Regex with 'not' sets.
####

Keep

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" '^.[^BCD].$'
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_AAA.fa ===
  >Seq_01__AAA__Yes__Yes__Both
  01
  >Seq_05__AAA__Yes__No__Start
  05
  >Seq_09__AAA__No__Yes__End
  09
  >Seq_13__AAA__No__No__Neither
  13

Reject.  This one is a little confusing :)

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" '^.[^BCD].$'
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  02
  >Seq_06__ABA__Yes__No__Start
  06
  >Seq_10__ABA__No__Yes__End
  10
  >Seq_14__ABA__No__No__Neither
  14
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  03
  >Seq_07__ACB__Yes__No__Start
  07
  >Seq_11__ACB__No__Yes__End
  11
  >Seq_15__ACB__No__No__Neither
  15
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  04
  >Seq_08__ADB__Yes__No__Start
  08
  >Seq_12__ADB__No__Yes__End
  12
  >Seq_16__ADB__No__No__Neither
  16

####################################################################
#### Multiple patterns #############################################
####################################################################

####  
#### Fixed
####

Keep

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select -F --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA,ABA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_AAA.fa ===
  >Seq_01__AAA__Yes__Yes__Both
  01
  >Seq_05__AAA__Yes__No__Start
  05
  >Seq_09__AAA__No__Yes__End
  09
  >Seq_13__AAA__No__No__Neither
  13
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  02
  >Seq_06__ABA__Yes__No__Start
  06
  >Seq_10__ABA__No__Yes__End
  10
  >Seq_14__ABA__No__No__Neither
  14

Reject

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject -F --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA,ABA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  03
  >Seq_07__ACB__Yes__No__Start
  07
  >Seq_11__ACB__No__Yes__End
  11
  >Seq_15__ACB__No__No__Neither
  15
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  04
  >Seq_08__ADB__Yes__No__Start
  08
  >Seq_12__ADB__No__Yes__End
  12
  >Seq_16__ADB__No__No__Neither
  16

####  
#### Regex (simple)
####

Keep

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA,ABA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_AAA.fa ===
  >Seq_01__AAA__Yes__Yes__Both
  01
  >Seq_05__AAA__Yes__No__Start
  05
  >Seq_09__AAA__No__Yes__End
  09
  >Seq_13__AAA__No__No__Neither
  13
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  02
  >Seq_06__ABA__Yes__No__Start
  06
  >Seq_10__ABA__No__Yes__End
  10
  >Seq_14__ABA__No__No__Neither
  14

Reject

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA,ABA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  03
  >Seq_07__ACB__Yes__No__Start
  07
  >Seq_11__ACB__No__Yes__End
  11
  >Seq_15__ACB__No__No__Neither
  15
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  04
  >Seq_08__ADB__Yes__No__Start
  08
  >Seq_12__ADB__No__Yes__End
  12
  >Seq_16__ADB__No__No__Neither
  16
