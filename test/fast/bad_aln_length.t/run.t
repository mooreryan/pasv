Bad alignment length.

  $ pasv check --outdir=apple bad.aln.fa 50,52,54 2> err
  [1]
  $ bash sanitize_logs.sh err
  F, [DATE TIME PID] FATAL -- 
  ("Error running pasv check"
   ("error in check_alignment"
    ("Error parsing alignment"
     (lib/check_alignment.ml.Bad_aln_length
      "Seq num: 2, Expected length: 4, Actual length: 3"))))
