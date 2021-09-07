# Jargon

Let's talk about some of the "jargon" we use when talking about PASV.

## MSA: multiple sequence alignment

I will use this when talking about alignment as done by Clustal Omega and MAFFT.

This is in contrast to using HMMs to align sequences.

## HMM: hiddon markov model

`pasv` can also use HMMs to align query sequences

## PASV vs `pasv`

When you see `pasv` written in that font, I am talking about the PASV command line application.

PASV in all caps is the acronym for protein active site validation.  It's both talking about the whole `pasv` program pipeline as well as the general idea of validating aspects of your query sequences.

## Queries & query sequences

These are the sequences you are interested in.  Often these will be metagenomic sequences, or sequences output from homology search.

`pasv` will assign a signature to each query sequence based on the [residues](todo) it has at the specified [key positions](todo).

## References & reference sequences

These are the sequences you are using as "references".

Depending on the command you're running, they could be sequences to align with queries in a multiple sequence alignment, or a profile HMM used to align queries against.

## Key reference sequences, positions & residues

The `pasv` program will check residues in a particular column of an alignment.

To tell `pasv` which alignment columns to check, you specify "key" residues with respect to a reference sequence.  I call this reference, the "key reference sequence".  It doesn't have to be anything special...it is simply the sequence with which the number will be with respect to.

The key positions are the positions you care about.  They are numbered with respect to the key reference sequence.

For example, if you care about an active site at residue 200 in a protein from *E. coli*, then you would make that *E. coli* peptide your key reference sequence, and residue 200 would be your key position.  Then, `pasv` will check the residues of the query sequences that align with residue 200 with respect to the key reference sequence.

Each `pasv` command deals with key references and positions a bit differently.  For specific info, see the command documentation.

## Signatures & signature files

Each query sequence is assigned a "signature" based on the residues that query has at the given key residue positions.

A signature file lists these signatures and, optionally, whether a sequence spans a given region of interest (ROI).

The signature file is a TSV.  Here is an example.

| name                           | pos_50 | pos_52 | pos_54 | signature | spans_start | spans_end | spans   |
|--------------------------------|--------|--------|--------|-----------|-------------|-----------|---------|
| AMK99662_spans_start_20_60_IQK | I      | Q      | K      | IQK       | Yes         | No        | Start   |
| AMK99662_spans_start_19_60_IQK | I      | Q      | K      | IQK       | Yes         | No        | Start   |
| AMK99662_21_60_IQK             | I      | Q      | K      | IQK       | No          | No        | Neither |
| AMK99662_spans_end_40_80_IQK   | I      | Q      | K      | IQK       | No          | Yes       | End     |
| AMK99662_spans_end_40_81_IQK   | I      | Q      | K      | IQK       | No          | Yes       | End     |
| AMK99662_40_79_IQK             | I      | Q      | K      | IQK       | No          | No        | Neither |
| AMK99662_spans_both_20_80_IQK  | I      | Q      | K      | IQK       | Yes         | Yes       | Both    |
| AMK99662_spans_both_19_81_IQK  | I      | Q      | K      | IQK       | Yes         | Yes       | Both    |
| AMK99662_21_79_IQK             | I      | Q      | K      | IQK       | No          | No        | Neither |
| AMK99662_full_length_IQK       | I      | Q      | K      | IQK       | Yes         | Yes       | Both    |
| AMK99662_real_seq_IQK          | I      | Q      | K      | IQK       | Yes         | Yes       | Both    |
| AMK99662_full_length_extra_IQK | I      | Q      | K      | IQK       | Yes         | Yes       | Both    |
| AMK99662_spans_start_20_60_ABC | A      | B      | C      | ABC       | Yes         | No        | Start   |
| AMK99662_spans_start_19_60_ABC | A      | B      | C      | ABC       | Yes         | No        | Start   |
| AMK99662_21_60_ABC             | A      | B      | C      | ABC       | No          | No        | Neither |
| AMK99662_spans_end_40_80_ABC   | A      | B      | C      | ABC       | No          | Yes       | End     |
| AMK99662_spans_end_40_81_ABC   | A      | B      | C      | ABC       | No          | Yes       | End     |
| AMK99662_40_79_ABC             | A      | B      | C      | ABC       | No          | No        | Neither |
| AMK99662_spans_both_20_80_ABC  | A      | B      | C      | ABC       | Yes         | Yes       | Both    |
| AMK99662_spans_both_19_81_ABC  | A      | B      | C      | ABC       | Yes         | Yes       | Both    |
| AMK99662_21_79_ABC             | A      | B      | C      | ABC       | No          | No        | Neither |
| AMK99662_full_length_ABC       | A      | B      | C      | ABC       | Yes         | Yes       | Both    |
| AMK99662_real_seq_ABC          | A      | B      | C      | ABC       | Yes         | Yes       | Both    |
| AMK99662_full_length_extra_ABC | A      | B      | C      | ABC       | Yes         | Yes       | Both    |

<br>

* This run checked for a region of interest as well as the key positions 50, 52, and 54.
* `spans_start`: can be one of `Yes`, `No`, or `NA`.
* `spans_end`: can be one of `Yes`, `No`, or `NA`.
* `spans`: will be one of `Neither`, `Start`, `End`, or `Both` based on the values in `spans_start` and `spans_end`

## Region of interest

The `pasv` program can optionally check that query sequences span a given region of interest.

You provide the start and end positions with respect to the key reference, and the program will check whether each query spans the start, spans the end, or spans both start and end.
