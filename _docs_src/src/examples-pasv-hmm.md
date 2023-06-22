# Examples: pasv-hmm

`pasv-hmm` is one of three `pasv` commands used to check residues in query sequences with respect to a [reference set](./jargon.md#references-reference-sequences) and a [key reference sequence](./jargon.md#key-reference-sequences-positions-residues).

_Note: for a lot more examples of using this and other `pasv` commands, see [here](./tons-of-examples.md)._

## Required arguments

`pasv hmm` has four required arguments:

- [queries](./jargon.md#queries-query-sequences): the query sequences
- [references](./jargon.md#references-reference-sequences): the reference HMM. This should be the output of HMMER's `hmmbuild` program
- [key reference sequence](./jargon.md#key-reference-sequences-positions-residues): a fasta file with the key reference sequence
- [key residues positions](./jargon.md#key-reference-sequences-positions-residues): a comma-separated list of key positions to check

For full CLI usage info, run `pasv hmm --help`.

## Set up environment variables

These are some environment variables that we will use in the example scripts. I am assuming you are running this from the following directory with respect to the `pasv` source directory: `./_examples/pasv_hmm`. (If you are not, you can download the data files on [GitHub](https://github.com/mooreryan/pasv/tree/main/_examples/pasv_hmm).)

```
$ export QUERIES=amk_queries.fa
$ export REFS=P00582.refs.aln.hmm
$ export MAIN_REF=amk_main_ref.fa
$ export OUTDIR=apple
$ export RESIDUES=50,52,54
```

## Basic usage

```
# Clean up outdir if it exists.
$ [ -d "${OUTDIR}" ] && rm -r "${OUTDIR}"

# Run pasv-hmm.
$ pasv hmm --outdir="${OUTDIR}" "${QUERIES}" "${REFS}" "${MAIN_REF}" "${RESIDUES}"
```

The output file will be `apple/amk_queries.pasv_signatures.tsv`. Here are the contents.

| name                           | pos_50 | pos_52 | pos_54 | signature | spans_start | spans_end | spans |
| ------------------------------ | ------ | ------ | ------ | --------- | ----------- | --------- | ----- |
| AMK99662_spans_start_20_60_IQK | I      | Q      | K      | IQK       | NA          | NA        | NA    |
| AMK99662_spans_start_19_60_IQK | I      | Q      | K      | IQK       | NA          | NA        | NA    |
| AMK99662_21_60_IQK             | I      | Q      | K      | IQK       | NA          | NA        | NA    |
| AMK99662_spans_end_40_80_IQK   | I      | Q      | K      | IQK       | NA          | NA        | NA    |
| AMK99662_spans_end_40_81_IQK   | I      | Q      | K      | IQK       | NA          | NA        | NA    |
| AMK99662_40_79_IQK             | I      | Q      | K      | IQK       | NA          | NA        | NA    |
| AMK99662_spans_both_20_80_IQK  | I      | Q      | K      | IQK       | NA          | NA        | NA    |
| AMK99662_spans_both_19_81_IQK  | I      | Q      | K      | IQK       | NA          | NA        | NA    |
| AMK99662_21_79_IQK             | I      | Q      | K      | IQK       | NA          | NA        | NA    |
| AMK99662_full_length_IQK       | I      | Q      | K      | IQK       | NA          | NA        | NA    |
| AMK99662_real_seq_IQK          | I      | Q      | K      | IQK       | NA          | NA        | NA    |
| AMK99662_full_length_extra_IQK | I      | Q      | K      | IQK       | NA          | NA        | NA    |
| AMK99662_spans_start_20_60_ABC | A      | B      | C      | ABC       | NA          | NA        | NA    |
| AMK99662_spans_start_19_60_ABC | A      | B      | C      | ABC       | NA          | NA        | NA    |
| AMK99662_21_60_ABC             | A      | B      | C      | ABC       | NA          | NA        | NA    |
| AMK99662_spans_end_40_80_ABC   | A      | B      | C      | ABC       | NA          | NA        | NA    |
| AMK99662_spans_end_40_81_ABC   | A      | B      | C      | ABC       | NA          | NA        | NA    |
| AMK99662_40_79_ABC             | A      | B      | C      | ABC       | NA          | NA        | NA    |
| AMK99662_spans_both_20_80_ABC  | A      | B      | C      | ABC       | NA          | NA        | NA    |
| AMK99662_spans_both_19_81_ABC  | A      | B      | C      | ABC       | NA          | NA        | NA    |
| AMK99662_21_79_ABC             | A      | B      | C      | ABC       | NA          | NA        | NA    |
| AMK99662_full_length_ABC       | A      | B      | C      | ABC       | NA          | NA        | NA    |
| AMK99662_real_seq_ABC          | A      | B      | C      | ABC       | NA          | NA        | NA    |
| AMK99662_full_length_extra_ABC | A      | B      | C      | ABC       | NA          | NA        | NA    |

<br>

For a detailed explanation of this file's format, see [here](./pasv-output.md).

One thing to note is that there are a lot of `NA` values present in the output. This is because we didn't provide a region of interest. Let's see how to do that.

## With region of interest

You can also use `pasv` to check if query sequences span a [region of interest](./jargon.md#region-of-interest) with respect to the key reference sequence.

```
# Clean up outdir if it exists.
$ [ -d "${OUTDIR}" ] && rm -r "${OUTDIR}"

# Run pasv-hmm.
$ pasv hmm \
    --roi-start=20 \
    --roi-end=80 \
    --outdir="${OUTDIR}" \
    "${QUERIES}" \
    "${REFS}" \
    "${MAIN_REF}" \
    "${RESIDUES}"
```

The output file will be here: `"${OUTDIR}/aln.pasv_signatures.tsv"`. Here are the contents:

| name                           | pos_50 | pos_52 | pos_54 | signature | spans_start | spans_end | spans   |
| ------------------------------ | ------ | ------ | ------ | --------- | ----------- | --------- | ------- |
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

See how there is data about whether queries span the region of interest?
