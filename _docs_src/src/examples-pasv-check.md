# Examples: pasv-check

Of the three commands for checking residues, `pasv-check` is the simplest.

It takes two input files: a multiple sequence alignment file in fasta format, and a comma separated list of [key residue positions](./jargon.md#key-reference-sequences-positions-residues) to check.

*Note: for a lot more examples of using this and other `pasv` commands, see [here](./tons-of-examples.md).*

## Input files

### aln.fa

A multiple sequence alignment in fasta format.

The first sequence in the alignment file is treated as the [key reference sequence](./jargon.md#key-reference-sequences-positions-residues).

You can download the `aln.fa` file from [GitHub](https://raw.githubusercontent.com/mooreryan/pasv/12a37d5aa863e8cee6a0f4c3a583eee78dbfca61/_examples/pasv_check/aln.fa).

## Set up environment variables

These are some environment variables that we will use in the example scripts. I am assuming you are running this from the following directory with respect to the `pasv` source directory: `./_examples/pasv_check`. (If you are not, you can download the data files on [GitHub](https://github.com/mooreryan/pasv/tree/master/_examples/pasv_check).)

```
$ export ALN=aln.fa
$ export OUTDIR=apple
```

## Basic usage

```
# Clean up outdir if it exists.
$ [ -d "${OUTDIR}" ] && rm -r "${OUTDIR}"

# Run pasv-check.
$ pasv check --outdir="${OUTDIR}" "${ALN}" 50,52,54
```

The output file will be here: `"${OUTDIR}/aln.pasv_signatures.tsv"`.  Here are the contents:

| name                           | pos_50 | pos_52 | pos_54 | signature | spans_start | spans_end | spans |
|--------------------------------|--------|--------|--------|-----------|-------------|-----------|-------|
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

For a detailed explanation of this file's format, see [here](./pasv-output.md).

One thing to note is that there are a lot of `NA` values present in the output.  This is because we didn't provide a region of interest.  Let's see how to do that.

## With region of interest

You can also use `pasv` to check if query sequences span a [region of interest](./jargon.md#region-of-interest) with respect to the key reference sequence.

```
# Clean up outdir if it exists.
$ [ -d "${OUTDIR}" ] && rm -r "${OUTDIR}"

# Run pasv-check.
$ pasv check \
    --roi-start=20 \
    --roi-end=80 \
    --outdir="${OUTDIR}" \
    "${ALN}" \
    50,52,54
```

The output file will be here: `"${OUTDIR}/aln.pasv_signatures.tsv"`.  Here are the contents:

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

See how there is data about whether queries span the region of interest?
