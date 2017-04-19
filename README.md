# Group Proteins

Partition protein sequences with respect to how they align with important positions on a reference sequence, for example, identifying phage lifestyle based on 762 position of the DNA polA protein in *E. coli*. 

It is basically a generalized version of [this](https://github.com/dnasko/dna_pola_762_caller) program, which was inspired by [this](http://www.nature.com/ismej/journal/v8/n1/full/ismej2013124a.html) paper by Schmidt et al. The user can pick any references with any regions of intersest and with any set of key residues with which to partition protein sequences.

## Requirements

### Clustal Omega

This program uses the [Clustal Omega C api](http://www.clustal.org/omega/clustalo-api/index.html) (version 1.2.4), so you are going to need to [install Clustal Omega from source](http://www.clustal.org/omega/clustal-omega-1.2.4.tar.gz).

[Install](http://www.clustal.org/omega/clustal-omega-1.2.4.tar.gz) Clustal Omega version `1.2.4` to ensure that it works. I know for a fact it won't work with `1.1.0`, and any other versions, I'm not sure.

### pkg-config

Not a hard requirement, but it makes compiling easier. You can find it [here](https://www.freedesktop.org/wiki/Software/pkg-config/).

## Compiling

With `pkg-config`...

```
gcc -c -O2 -g -Wall $(pkg-config --cflags clustalo) group_proteins.c 
g++ -g -Wall -o group_proteins $(pkg-config --libs clustalo) group_proteins.o
``` 

Without `pkg-config`, you just need to specify where the `clustalo` headers and libs are located manually like so....

```
gcc -c -O2 -g -Wall -I/usr/local/include/clustalo/ group_proteins.c 
g++ -g -Wall -o group_proteins -L/usr/local/lib -lclustalo group_proteins.o
```

The file locations on your computer may be different.

## Usage

```
USAGE: ./group_proteins <1: refs.fa> <2: queries.fa> <3: region start (1-based position)> <4: region end (1-based position)> pos1 pos2 ... posN
```

### Example

```
group_proteins refs.fa queries.fa 100 200 125 127 134
```

The above command will tell you whether the queries span the region from 100-200 on the first sequence in the `refs.fa` file. Also, it will give you the group info for the three positions `125`, `127`, and `134`.

And the output might look something like this....

```
seq spans_region group aa_at_762 aa_at_777
seq1 yes YV Y V
seq2 yes FL F L
```

It's space delimited. You can now use this file to pick only sequences in certain groups, e.g., thos with tyrosine at the 762 position with respect to the reference....`awk` 'till your heart's content!

## Picking reference sequences

You can include as many reference sequences as you would like, but make the the first one in the reference file is the one you want to annotate against. In other, this is the sequence with which columns in the aligment with be named.
