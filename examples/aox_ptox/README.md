# AOX/PTOX Example

This shows how you can run the AOX/PTOX example from the manuscript.

What we want to do is to use the positions in the motifs identified in the [Nobre manuscript](http://dx.doi.org/10.3389/fpls.2016.00868) in order to distinguish between AOX and PTOX peptides.  

To do this, we will run the same queries, which are a mix of AOX and PTOX peptides, through PASV twice:  once with the AOX references, and once with the PTOX references.  Then you can check the key residue signatures for all the queries in both runs and compare them.  If a query has the proper AOX motif in the AOX run, mark it as AOX; if it doesn't have the correct motif, mark it not-AOX.  Then do the same thing for the PTOX motif in the PTOX run.  Combining these two "annotations" you can classify the sequences.  Now, if any of the sequences had the proper motif in both the AOX and the PTOX runs, then that sequence would be marked as ambiguous, but as we saw in the PASV paper, this didn't happen. 

One thing to note is that the numbers you see for the key residues are those motifs from the paper with respect to the first reference sequence in the `refs_aox.fa.gz` and `refs_ptox.fa.gz` files.

## Run PASV

Note:  I'm using [PASV v1.3.0](https://github.com/mooreryan/pasv/releases/tag/v1.3.0) for these examples.

### With AOX References

The wrapper script to run PASV with the AOX references.  If you want to use a different amount of threads, feel free to change it in the script.

```sh
dir="$1"

refs="${dir}/refs_aox.fa.gz"
queries="${dir}/all.fa.gz"
threads=4
outdir="${dir}/pasv_output_aox"

date && time pasv \
  --refs ${refs} \
  --queries ${queries} \
  --aligner clustalo \
  --threads ${threads} \
  --outdir ${outdir} \
  233 234 235 236 237 238 239 \
  283 284 285 286 287
```

From inside the `./examples/aox_ptox` directory, run:

```
$ sh run_pasv_aox.sh .
```

After a couple of minutes, PASV will finish.  Here is the resulting directory.

```
$ tree pasv_output_aox/
pasv_output_aox/
├── pasv.partition_EFHHLLIVERHA.fa
├── pasv.partition_EMHHLLIVEGHA.fa
├── pasv.partition_EMHHLLIVEHHA.fa
├── pasv.partition_EMHHLLIVENHA.fa
├── pasv.partition_EMHHLLIVESHA.fa
├── pasv.partition_ERMHLMTLEEEA.fa
├── pasv_counts.txt
└── pasv_types.txt

0 directories, 8 files
```

### With PTOX References

The wrapper script to run PASV with the PTOX references.  If you want to use a different amount of threads, feel free to change it in the script.

```sh
dir="$1"

refs="${dir}/refs_ptox.fa.gz"
queries="${dir}/all.fa.gz"
threads=4
outdir="${dir}/pasv_output_ptox"

date && time pasv \
  --refs ${refs} \
  --queries ${queries} \
  --aligner clustalo \
  --threads ${threads} \
  --outdir ${outdir} \
  157 158 160 161 \
  177 178 179 180 182 183
```  

From inside the `./examples/aox_ptox` directory, run:

```
$ sh run_pasv_ptox.sh .
```

After a couple of minutes, PASV will finish.  Here is the resulting directory.

```
tree pasv_output_ptox/
pasv_output_ptox/
├── pasv.partition_----MHLMFM.fa
├── pasv.partition_G---MHLMFM.fa
├── pasv.partition_G---MHLMMV.fa
├── pasv.partition_GFHSMHLMFM.fa
├── pasv.partition_GG--MHLMFI.fa
├── pasv.partition_GG--MHLMFL.fa
├── pasv.partition_GG--MHLMFM.fa
├── pasv.partition_GG--MHLMME.fa
├── pasv.partition_GG--MHLMMM.fa
├── pasv.partition_GG--MHLMMV.fa
├── pasv.partition_GG--MHLMVV.fa
├── pasv.partition_GGI-MHLMFM.fa
├── pasv.partition_GGIRMHLMFL.fa
├── pasv.partition_GGIRMHLMFM.fa
├── pasv.partition_GWRRHHLLME.fa
├── pasv.partition_KFHSMHLMFM.fa
├── pasv.partition_KFHSMHLMMI.fa
├── pasv.partition_KFHSMHLMMV.fa
├── pasv.partition_KFQSMHLMMV.fa
├── pasv.partition_RFHSMHLMFI.fa
├── pasv.partition_RFHSMHLMFL.fa
├── pasv.partition_RFHSMHLMFM.fa
├── pasv.partition_RFQSMHLMFI.fa
├── pasv.partition_RFQSMHLMFM.fa
├── pasv.partition_RFQSMHLMMV.fa
├── pasv_counts.txt
└── pasv_types.txt

0 directories, 27 files
```

## Interpreting the output

- The `pasv.partition_*` files contain query sequences with the given key residue signature.  By default, only signatures that had at least two sequences will have their own FASTA file.
- The `pasv_counts.txt` file shows all the signatures and how many query sequences had that signature.
- The `pasv_types.txt` file shows more detailed information for all the query sequences.  You could use this to pull sequences with a specific key residue signature that you are interested in.

### "Classifying" sequences

#### Count AOX & PTOX sequences

First, let's check the number of AOX and PTOX sequences that are in the queries.  

I have named the query sequences in such a way that all true AOX sequences start with `aox` and all true PTOX sequences start with `ptox`.  This way we can use a couple of `awk` commands to check the results.

(Again, I'm working from the `./examples/aox_ptox` directory.)

How many AOX sequences?

```
$ gunzip -c all.fa.gz | grep -c '^>aox'
254
```

How many PTOX sequences?

```
$ gunzip -c all.fa.gz | grep -c '^>ptox'
82
```

It's always good to do "sanity checks" so let's make sure the total number of sequences matches up to what we expect (`254 + 82 = 336`).

```
gunzip -c all.fa.gz | grep -c '^>'
336
```

Yep, that's correct.

#### Checking the key residue signatures

The correct AOX signature is `ERMHLMTLEEEA` and the correct PTOX signature is `GWRRHHLLME`.

Just so it is clear, in the AOX reference run, any sequence with the correct AOX key signature (`ERMHLMTLEEEA`) we mark as AOX (i.e., PASV has "predicted" it to be AOX) and any sequence with any other signature is not-AOX.  PTOX works in a similar way.

I will do all these checks a couple of different ways, both for fun and just as another "sanity check".

##### AOX

How many AOX sequnces have the AOX signature? (Answer: `254`)

```
$ awk '$1 ~ /^aox/ && $2 == "ERMHLMTLEEEA"' pasv_output_aox/pasv_types.txt | wc -l
      254   
```

How many PTOX sequnces have the AOX signature? (Answer: `0`)

```
$ awk '$1 ~ /^ptox/ && $2 == "ERMHLMTLEEEA"' pasv_output_aox/pasv_types.txt | wc -l
      0   
```

How many AOX sequnces do not have the AOX signature? (Answer: `0`)

```
$ awk '$1 ~ /^aox/ && $2 != "ERMHLMTLEEEA"' pasv_output_aox/pasv_types.txt | wc -l
      0   
```

How many PTOX sequnces do not have the AOX signature? (Answer: `82`)

```
$ awk '$1 ~ /^ptox/ && $2 != "ERMHLMTLEEEA"' pasv_output_aox/pasv_types.txt | wc -l
      82   
```

Do the headers of the AOX sequences and those sequences with the AOX signature match? (Answer: Yes)

```
$ diff \
    <(awk '$2 == "ERMHLMTLEEEA" {print $1}' pasv_output_aox/pasv_types.txt | sort) \
    <(gunzip -c all.fa.gz | grep '^>aox' | sed 's/^>//' | sort) && \
  echo $?
0
```

##### PTOX

How many PTOX sequnces have the PTOX signature? (Answer: `82`)

```
$ awk '$1 ~ /^ptox/ && $2 == "GWRRHHLLME"' pasv_output_ptox/pasv_types.txt | wc -l
      82   
```

How many AOX sequnces have the PTOX signature? (Answer: `0`)

```
$ awk '$1 ~ /^aox/ && $2 == "GWRRHHLLME"' pasv_output_ptox/pasv_types.txt | wc -l
      0   
```

How many PTOX sequnces do not have the PTOX signature? (Answer: `0`)

```
$ awk '$1 ~ /^ptox/ && $2 != "GWRRHHLLME"' pasv_output_ptox/pasv_types.txt | wc -l
      0   
```

How many AOX sequnces do not have the PTOX signature? (Answer: `254`)

```
$ awk '$1 ~ /^aox/ && $2 != "GWRRHHLLME"' pasv_output_ptox/pasv_types.txt | wc -l
      254   
```

Do the headers of the PTOX sequences and those sequences with the PTOX signature match? (Answer: Yes)

```
$ diff \
    <(awk '$2 == "GWRRHHLLME" {print $1}' pasv_output_ptox/pasv_types.txt | sort) \
    <(gunzip -c all.fa.gz | grep '^>ptox' | sed 's/^>//' | sort) && \
  echo $?
0
```

## So what's the result?

As you can see, 100% of manually annotated AOX sequences had the proper AOX signature and 100% of manually annotated PTOX sequences had the proper PTOX signature.  Nice!
