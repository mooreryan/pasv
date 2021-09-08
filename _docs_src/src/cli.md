# PASV Command Line Interface

The `pasv` program has multiple commands to help you validate active sites, conserved residues, etc. in multiple sequence alignments.

## Commands

The four `pasv` commands are:

* `check`: Use pre-computed alignments
* `hmm`: Use hidden markov model (HMM) alignments
* `msa`: Use multiple sequence alignments (MSA)
* `select`: Select sequences by their signatures

## check

Use `pasv check` when you already have an alignment file in which you want to check key residues or a region of interest (ROI).

### Required arguments

`pasv check` has two required arguments.

* A multiple sequence alignment in fasta format.
    * The first sequence will be treated as the [key reference sequence](./jargon.md#key-reference-sequences-positions-residues).
	* All positions will be with respect to this sequence.
* [key residues positions](jargon.md#key-reference-sequences-positions-residues): a comma-separated list of key positions to check

For full CLI usage info, run `pasv check --help`.

## hmm

Use `pasv hmm` when you want to use HMM alignments.  In this mode, PASV uses the `hmmalign` program of [HMMER](http://hmmer.org/) to compute sequence alignments.

The key reference sequence and all queries are aligned together against the reference HMM.

### Required arguments

`pasv hmm` has four required arguments:

* [queries](jargon.md#queries-query-sequences): the query sequences
* [references](jargon.md#references-reference-sequences): the reference HMM.  This should be the output of HMMER's `hmmbuild` program
* [key reference sequence](jargon.md#key-reference-sequences-positions-residues): a fasta file with the key reference sequence
* [key residues positions](jargon.md#key-reference-sequences-positions-residues): a comma-separated list of key positions to check

For full CLI usage info, run `pasv hmm --help`.

### Reference HMM

The references should be an HMM as output by `hmmbuild` (or at least a program that generates compatible HMMs that can be used with HMMER and `hmmalign`).

The [HMMER user guide](http://eddylab.org/software/hmmer/Userguide.pdf) has detailed instructions on building HMMs, but the basic incantation for doing it is something like this:

```
$ hmmbuild [-options] <hmmfile_out> <msafile>
```

The HMM file output by this command is used as input to `pasv-hmm`.

## msa

Use `pasv msa` when you want to align each query sequence individually with a set of reference sequences.  In this mode, PASV uses one of [Clustal Omega](http://www.clustal.org/omega/) or [MAFFT](https://mafft.cbrc.jp/alignment/software/) to align sequences.

### Required arguments

`pasv msa` has three required arguments:

* [queries](jargon.md#queries-query-sequences): the query sequences
* [references](jargon.md#references-reference-sequences)
    * The reference sequences to align with each query
	* The first sequence in the fasta file should be the [key reference sequence](jargon.md#key-reference-sequences-positions-residues).
* [key residues positions](jargon.md#key-reference-sequences-positions-residues): a comma-separated list of key positions to check

For full CLI usage info, run `pasv msa --help`.

## select

Use `pasv select` to select query sequences based on their key residue signatures.

After running one of the alignment subcommands (`check`, `hmm`, or `msa`), you can run this command to select query sequences based on their signatures.

This is provided for parsing convenience.  You can always parse the signatures file yourself with bash or your favorite scripting language.

### Required arguments

`pasv select` has three required arguments:

* [queries](jargon.md#queries-query-sequences): the query sequences
* [signature file](jargon.md#signatures-signature-files)
* [signatures](jargon.md#signatures-signature-files): a comma-separated list of key positions to check

The signatures can be provided as fixed strings or regular expressions.

For full CLI usage info, run `pasv select --help`.
