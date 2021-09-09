Set up environment.

  $ export QUERIES=amk_queries.fa
  $ export REFS=P00582.refs.fa
  $ export REFS_HMM=P00582.refs.aln.hmm
  $ export MAIN_REF=amk_main_ref.fa
  $ export OUTDIR=apple
  $ export RESIDUES=50,52,54
  $ export SANITIZE_LOGS=$PWD/../../helpers/sanitize_logs

In these examples, we keep the first entry in the path as dune uses
this to get pasv exe working.

#############
#### MSA ####
#############

When mafft isn't on the path, it's an error.  

  $ PATH=`echo $PATH | cut -f1 -d':'` pasv msa --outdir=apple --aligner=mafft "${QUERIES}" "${REFS}" "${RESIDUES}" --jobs=2 2> log
  [1]
  $ "${SANITIZE_LOGS}" log | sed -E 's|Exit_non_zero [0-9]+|Exit_non_zero CODE|g'
  F, [DATE TIME PID] FATAL -- 'mafft' doesn't look like an executable file.  Is it a path to an executable file?  If not, is it a command on your PATH?  Error: (Unix.Exit_or_signal (Exit_non_zero CODE))

When clustalo isn't on the path, it's an error.  

  $ PATH=`echo $PATH | cut -f1 -d':'` pasv msa --outdir=apple --aligner=clustalo "${QUERIES}" "${REFS}" "${RESIDUES}" --jobs=2 2> log
  [1]
  $ "${SANITIZE_LOGS}" log | sed -E 's|Exit_non_zero [0-9]+|Exit_non_zero CODE|g'
  F, [DATE TIME PID] FATAL -- 'clustalo' doesn't look like an executable file.  Is it a path to an executable file?  If not, is it a command on your PATH?  Error: (Unix.Exit_or_signal (Exit_non_zero CODE))

When the path to mafft isn't executable, it's an error.

  $ PATH=`echo $PATH | cut -f1 -d':'` pasv msa --outdir=apple --aligner=./mafft "${QUERIES}" "${REFS}" "${RESIDUES}" --jobs=2 2> log
  [1]
  $ "${SANITIZE_LOGS}" log | sed -E 's|Exit_non_zero [0-9]+|Exit_non_zero CODE|g'
  F, [DATE TIME PID] FATAL -- './mafft' doesn't look like an executable file.  Is it a path to an executable file?  If not, is it a command on your PATH?  Error: (Unix.Exit_or_signal (Exit_non_zero CODE))

When the path to clustalo isn't executable, it's an error.

  $ PATH=`echo $PATH | cut -f1 -d':'` pasv msa --outdir=apple --aligner=./clustalo "${QUERIES}" "${REFS}" "${RESIDUES}" --jobs=2 2> log
  [1]
  $ "${SANITIZE_LOGS}" log | sed -E 's|Exit_non_zero [0-9]+|Exit_non_zero CODE|g'
  F, [DATE TIME PID] FATAL -- './clustalo' doesn't look like an executable file.  Is it a path to an executable file?  If not, is it a command on your PATH?  Error: (Unix.Exit_or_signal (Exit_non_zero CODE))

#############
#### HMM ####
#############

When hmmalign isn't on the path, it's an error.  

  $ PATH=`echo $PATH | cut -f1 -d':'` pasv hmm --outdir=apple --hmmalign=hmmalign "${QUERIES}" "${REFS_HMM}" "${MAIN_REF}" "${RESIDUES}" 2> log
  [1]
  $ "${SANITIZE_LOGS}" log | sed -E 's|Exit_non_zero [0-9]+|Exit_non_zero CODE|g'
  F, [DATE TIME PID] FATAL -- 'hmmalign' doesn't look like an executable file.  Is it a path to an executable file?  If not, is it a command on your PATH?  Error: (Unix.Exit_or_signal (Exit_non_zero CODE))

When the path to hmmalign isn't executable, it's an error.

  $ PATH=`echo $PATH | cut -f1 -d':'` pasv hmm --outdir=apple --hmmalign=./hmmalign "${QUERIES}" "${REFS_HMM}" "${MAIN_REF}" "${RESIDUES}" 2> log
  [1]
  $ "${SANITIZE_LOGS}" log | sed -E 's|Exit_non_zero [0-9]+|Exit_non_zero CODE|g'
  F, [DATE TIME PID] FATAL -- './hmmalign' doesn't look like an executable file.  Is it a path to an executable file?  If not, is it a command on your PATH?  Error: (Unix.Exit_or_signal (Exit_non_zero CODE))
