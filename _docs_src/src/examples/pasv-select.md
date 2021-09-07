# Examples: pasv-select

You can select sequences by signature using either fixed strings or regular expressions.  I will show you examples using both methods.

*Note: for a lot more examples of using this and other `pasv` commands, see [here](./tons-of-examples.md).*

## Input files

### queries.fa

There are 16 queries in the fasta file.  Here are the first few sequences.

```
>Seq_01__AAA__Yes__Yes__Both
AAA
>Seq_02__ABA__Yes__Yes__Both
ABA
>Seq_03__ACB__Yes__Yes__Both
ACB
>Seq_04__ADB__Yes__Yes__Both
ADB
>Seq_05__AAA__Yes__No__Start
AAA
```

As you can see, it is just some fake data to illustrate the `pasv-select` program.

### signatures.tsv

The signatures file is a tab-separated (TSV) file that looks like this:

| name                         | pos_50 | pos_52 | pos_54 | signature | spans_start | spans_end | spans   |
|------------------------------|--------|--------|--------|-----------|-------------|-----------|---------|
| Seq_01__AAA__Yes__Yes__Both  | A      | A      | A      | AAA       | Yes         | Yes       | Both    |
| Seq_02__ABA__Yes__Yes__Both  | A      | B      | A      | ABA       | Yes         | Yes       | Both    |
| Seq_03__ACB__Yes__Yes__Both  | A      | C      | B      | ACB       | Yes         | Yes       | Both    |
| Seq_04__ADB__Yes__Yes__Both  | A      | D      | B      | ADB       | Yes         | Yes       | Both    |
| Seq_05__AAA__Yes__No__Start  | A      | A      | A      | AAA       | Yes         | No        | Start   |
| Seq_06__ABA__Yes__No__Start  | A      | B      | A      | ABA       | Yes         | No        | Start   |
| Seq_07__ACB__Yes__No__Start  | A      | C      | B      | ACB       | Yes         | No        | Start   |
| Seq_08__ADB__Yes__No__Start  | A      | D      | B      | ADB       | Yes         | No        | Start   |
| Seq_09__AAA__No__Yes__End    | A      | A      | A      | AAA       | No          | Yes       | End     |
| Seq_10__ABA__No__Yes__End    | A      | B      | A      | ABA       | No          | Yes       | End     |
| Seq_11__ACB__No__Yes__End    | A      | C      | B      | ACB       | No          | Yes       | End     |
| Seq_12__ADB__No__Yes__End    | A      | D      | B      | ADB       | No          | Yes       | End     |
| Seq_13__AAA__No__No__Neither | A      | A      | A      | AAA       | No          | No        | Neither |
| Seq_14__ABA__No__No__Neither | A      | B      | A      | ABA       | No          | No        | Neither |
| Seq_15__ACB__No__No__Neither | A      | C      | B      | ACB       | No          | No        | Neither |
| Seq_16__ADB__No__No__Neither | A      | D      | B      | ADB       | No          | No        | Neither |



## Set up environment variables

These are some environment variables that we will use in the example scripts.  I am assuming you are running this from the following directory with respect to the `pasv` source directory: `./_examples/pasv_select`.

```
export QUERY_FILE=queries.fa
export SIGNATURE_FILE=signatures.tsv
export OUTDIR=apple
```

Note that these are just some silly test files...that's why the fasta "sequences" just look like numbers :)

## Selecting with fixed strings

### Selecting

Select queries with the signature `AAA`.

```
# Clean up outdir if it exists.
$ [ -d "${OUTDIR}" ] && rm -r "${OUTDIR}"

# Run pasv-select.
$ pasv select \
    --fixed-strings \
    --outdir="${OUTDIR}" \
    "${QUERY_FILE}" \
    "${SIGNATURE_FILE}" \
    AAA

# Print out the resulting fasta files.
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
```

### Rejecting

You can also reject queries with certain signatures by using the `--reject` flag.

Here is an example of rejecting queries with the signature `AAA`.

```
# Clean up outdir if it exists.
$ [ -d "${OUTDIR}" ] && rm -r "${OUTDIR}"

# Run pasv-select.
$ pasv select \
    --reject \
    --fixed-strings \
    --outdir="${OUTDIR}" \
    "${QUERY_FILE}" \
    "${SIGNATURE_FILE}" \
    AAA

# Print out the resulting fasta files.
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
```

As you see, there are only sequences that have a different signature than `AAA`.

### Multiple patterns

You pass multiple patterns at the same time.  If a query has any of the listed signatures it will be printed (or rejected if you pass `--reject`).

To use multiple signatures, just separate them with commas.

#### Selecting

```
# Clean up outdir if it exists.
$ [ -d "${OUTDIR}" ] && rm -r "${OUTDIR}"

# Run pasv-select.
$ pasv select \
    --fixed-strings \
    --outdir="${OUTDIR}" \
    "${QUERY_FILE}" \
    "${SIGNATURE_FILE}" \
    AAA,ABA

# Print out the resulting fasta files.
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
```

#### Rejecting

Rejecting with multiple patterns can be confusing.  This example will print sequences that **do not** have signature `AAA` or `ABA` (e.g., `ACA`, `TLA`, whatever).

```
# Clean up outdir if it exists.
$ [ -d "${OUTDIR}" ] && rm -r "${OUTDIR}"n

# Run pasv-select.
$ pasv select \
    --reject \
    --fixed-strings \
    --outdir="${OUTDIR}" \
    "${QUERY_FILE}" \
    "${SIGNATURE_FILE}" \
    AAA,ABA

# Print out the resulting fasta files.
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
```

## Selecting with regular expressions

You can also use regular expressions to select signatures.

In this file, the sequences only have the following signatures:  `AAA`, `ABA`, `ACB`, `ADB`.

So with this regular expression, `[AC].$`, I can select any signature with `A` or `C` in the 2nd position from the end.

One thing to note, you generally should put the regular expression inside single quotes.

```
# Clean up outdir if it exists.
$ [ -d "${OUTDIR}" ] && rm -r "${OUTDIR}"

# Run pasv-select.
$ pasv select \
    --outdir="${OUTDIR}" \
    "${QUERY_FILE}" \
    "${SIGNATURE_FILE}" \
    '[AC].$'

# Print out the resulting fasta files.
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
```

Note that you can use the `--reject` flag and with regular expressions, as well as passing in a comma separated list of regular expressions.  Just watch out though, it can get a little wonky if you go crazy with the regular expression matching and then try and reject it.
