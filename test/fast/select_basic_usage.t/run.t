Set up env variables.

  $ export QUERY_FILE=queries.fa
  $ export SIGNATURE_FILE=signatures.tsv
  $ export OUTDIR=apple
  $ export SANITIZE_LOGS=$PWD/../../helpers/sanitize_logs

####
#### Single, fixed string.
####

Keep, fixed string.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select -F --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_AAA.fa ===
  >Seq_01__AAA__Yes__Yes__Both
  AAA
  >Seq_05__AAA__Yes__No__Start
  AAA
  >Seq_09__AAA__No__Yes__End
  AAA
  >Seq_13__AAA__No__No__Neither
  AAA

Keep, fixed string.  Pattern isn't present.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select -F --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" XXX 2> log
  [1]
  $ "${SANITIZE_LOGS}" log
  W, [DATE TIME PID] WARN -- There were no sequence IDs to keep!  Outdir 'apple' will be empty.  Check your signatures and make sure they're correct!  You did not pass --reject...did you mean to?    You passed --fixed-strings...did you mean to?
  $ ls "${OUTDIR}"

Reject, fixed string.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject -F --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  ABA
  >Seq_06__ABA__Yes__No__Start
  ABA
  >Seq_10__ABA__No__Yes__End
  ABA
  >Seq_14__ABA__No__No__Neither
  ABA
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  ACB
  >Seq_07__ACB__Yes__No__Start
  ACB
  >Seq_11__ACB__No__Yes__End
  ACB
  >Seq_15__ACB__No__No__Neither
  ACB
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  ADB
  >Seq_08__ADB__Yes__No__Start
  ADB
  >Seq_12__ADB__No__Yes__End
  ADB
  >Seq_16__ADB__No__No__Neither
  ADB

Rejecting a signature that isn't actually present will print all the
sequences.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject -F --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" XXX
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_AAA.fa ===
  >Seq_01__AAA__Yes__Yes__Both
  AAA
  >Seq_05__AAA__Yes__No__Start
  AAA
  >Seq_09__AAA__No__Yes__End
  AAA
  >Seq_13__AAA__No__No__Neither
  AAA
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  ABA
  >Seq_06__ABA__Yes__No__Start
  ABA
  >Seq_10__ABA__No__Yes__End
  ABA
  >Seq_14__ABA__No__No__Neither
  ABA
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  ACB
  >Seq_07__ACB__Yes__No__Start
  ACB
  >Seq_11__ACB__No__Yes__End
  ACB
  >Seq_15__ACB__No__No__Neither
  ACB
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  ADB
  >Seq_08__ADB__Yes__No__Start
  ADB
  >Seq_12__ADB__No__Yes__End
  ADB
  >Seq_16__ADB__No__No__Neither
  ADB

Fixed string, reject.  Short options can be combined.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select -rF --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  ABA
  >Seq_06__ABA__Yes__No__Start
  ABA
  >Seq_10__ABA__No__Yes__End
  ABA
  >Seq_14__ABA__No__No__Neither
  ABA
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  ACB
  >Seq_07__ACB__Yes__No__Start
  ACB
  >Seq_11__ACB__No__Yes__End
  ACB
  >Seq_15__ACB__No__No__Neither
  ACB
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  ADB
  >Seq_08__ADB__Yes__No__Start
  ADB
  >Seq_12__ADB__No__Yes__End
  ADB
  >Seq_16__ADB__No__No__Neither
  ADB


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
  AAA
  >Seq_05__AAA__Yes__No__Start
  AAA
  >Seq_09__AAA__No__Yes__End
  AAA
  >Seq_13__AAA__No__No__Neither
  AAA

Reject

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  ABA
  >Seq_06__ABA__Yes__No__Start
  ABA
  >Seq_10__ABA__No__Yes__End
  ABA
  >Seq_14__ABA__No__No__Neither
  ABA
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  ACB
  >Seq_07__ACB__Yes__No__Start
  ACB
  >Seq_11__ACB__No__Yes__End
  ACB
  >Seq_15__ACB__No__No__Neither
  ACB
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  ADB
  >Seq_08__ADB__Yes__No__Start
  ADB
  >Seq_12__ADB__No__Yes__End
  ADB
  >Seq_16__ADB__No__No__Neither
  ADB

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
  AAA
  >Seq_05__AAA__Yes__No__Start
  AAA
  >Seq_09__AAA__No__Yes__End
  AAA
  >Seq_13__AAA__No__No__Neither
  AAA
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  ACB
  >Seq_07__ACB__Yes__No__Start
  ACB
  >Seq_11__ACB__No__Yes__End
  ACB
  >Seq_15__ACB__No__No__Neither
  ACB

Reject 

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" '[AC].$'
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  ABA
  >Seq_06__ABA__Yes__No__Start
  ABA
  >Seq_10__ABA__No__Yes__End
  ABA
  >Seq_14__ABA__No__No__Neither
  ABA
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  ADB
  >Seq_08__ADB__Yes__No__Start
  ADB
  >Seq_12__ADB__No__Yes__End
  ADB
  >Seq_16__ADB__No__No__Neither
  ADB

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
  AAA
  >Seq_05__AAA__Yes__No__Start
  AAA
  >Seq_09__AAA__No__Yes__End
  AAA
  >Seq_13__AAA__No__No__Neither
  AAA

Reject.  This one is a little confusing :)

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" '^.[^BCD].$'
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  ABA
  >Seq_06__ABA__Yes__No__Start
  ABA
  >Seq_10__ABA__No__Yes__End
  ABA
  >Seq_14__ABA__No__No__Neither
  ABA
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  ACB
  >Seq_07__ACB__Yes__No__Start
  ACB
  >Seq_11__ACB__No__Yes__End
  ACB
  >Seq_15__ACB__No__No__Neither
  ACB
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  ADB
  >Seq_08__ADB__Yes__No__Start
  ADB
  >Seq_12__ADB__No__Yes__End
  ADB
  >Seq_16__ADB__No__No__Neither
  ADB

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
  AAA
  >Seq_05__AAA__Yes__No__Start
  AAA
  >Seq_09__AAA__No__Yes__End
  AAA
  >Seq_13__AAA__No__No__Neither
  AAA
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  ABA
  >Seq_06__ABA__Yes__No__Start
  ABA
  >Seq_10__ABA__No__Yes__End
  ABA
  >Seq_14__ABA__No__No__Neither
  ABA

Reject

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject -F --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA,ABA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  ACB
  >Seq_07__ACB__Yes__No__Start
  ACB
  >Seq_11__ACB__No__Yes__End
  ACB
  >Seq_15__ACB__No__No__Neither
  ACB
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  ADB
  >Seq_08__ADB__Yes__No__Start
  ADB
  >Seq_12__ADB__No__Yes__End
  ADB
  >Seq_16__ADB__No__No__Neither
  ADB

Reject, but include a signature that isn't present.

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject -F --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA,ABA,XXX
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  ACB
  >Seq_07__ACB__Yes__No__Start
  ACB
  >Seq_11__ACB__No__Yes__End
  ACB
  >Seq_15__ACB__No__No__Neither
  ACB
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  ADB
  >Seq_08__ADB__Yes__No__Start
  ADB
  >Seq_12__ADB__No__Yes__End
  ADB
  >Seq_16__ADB__No__No__Neither
  ADB

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
  AAA
  >Seq_05__AAA__Yes__No__Start
  AAA
  >Seq_09__AAA__No__Yes__End
  AAA
  >Seq_13__AAA__No__No__Neither
  AAA
  === apple/signature_ABA.fa ===
  >Seq_02__ABA__Yes__Yes__Both
  ABA
  >Seq_06__ABA__Yes__No__Start
  ABA
  >Seq_10__ABA__No__Yes__End
  ABA
  >Seq_14__ABA__No__No__Neither
  ABA

Reject

  $ rm -r "${OUTDIR}" "${ACTUAL_SIGNATURES}" 2> /dev/null
  [1]
  $ pasv select --reject --outdir="${OUTDIR}" "${QUERY_FILE}" "${SIGNATURE_FILE}" AAA,ABA
  $ for f in $(ls "${OUTDIR}"/*); do echo "=== $f ==="; cat $f; done
  === apple/signature_ACB.fa ===
  >Seq_03__ACB__Yes__Yes__Both
  ACB
  >Seq_07__ACB__Yes__No__Start
  ACB
  >Seq_11__ACB__No__Yes__End
  ACB
  >Seq_15__ACB__No__No__Neither
  ACB
  === apple/signature_ADB.fa ===
  >Seq_04__ADB__Yes__Yes__Both
  ADB
  >Seq_08__ADB__Yes__No__Start
  ADB
  >Seq_12__ADB__No__Yes__End
  ADB
  >Seq_16__ADB__No__No__Neither
  ADB
