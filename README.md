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

With `pkg-config` you can just use the `Makefile`...

```
make
```

And the binaries will be in the `bin` directory.

Right now the make file only works if you have `pkg-config`. If you don't want to install it, run these commands (replacing the actual location of your clustal libraries).

```
mkdir -p bin
gcc -Wall -g -O2 -o bin/split_seqs src/split_seqs.c -lz
gcc -c -Wall -g -O2 -I/usr/local/include/clustalo/ src/group_seqs.c
g++ -Wall -g -O2 -o bin/group_seqs -L/usr/local/lib -lclustalo group_seqs.o
gcc -Wall -g -O2   -c -o vendor/tommyhashlin.o vendor/tommyhashlin.c
gcc -Wall -g -O2   -c -o vendor/tommyhash.o vendor/tommyhash.c
gcc -Wall -g -O2   -c -o vendor/tommylist.o vendor/tommylist.c
gcc -Wall -g -O2 -o bin/partition_seqs vendor/tommyhashlin.o vendor/tommyhash.o vendor/tommylist.o src/partition_seqs.c -lz
```

Note the need for `g++`...it's needed for the clustal api.

The file locations on your computer may be different.

## Usage

The individual commands...

### split_seqs

```
USAGE: ./split_seqs <1: number of splits> <2: seq file>
```

### group_seqs

```
Usage: ./group_seqs <1: num iterations> <2: refs.fa> <3: queries.fa> <4: region start (1-based position)> <5: region end (1-based position)> pos1 pos2 ... posN
```

### partition_seqs

```
USAGE: bin/partition_seqs <1: seq file> *.seq_types
```

### Ruby wrapper script

If you have ruby installed, you can run the above three commands in parallel.

```
USAGE: scripts/group_and_partition.rb bin_dir threads num_iters refs.fa queries.fa start end pos1 pos2 ... posN
```

### Example

If I want to run the program with multiple cores...

Split the query file up.

```
bin/split_seqs 3 test_files/16_references.fasta
```

Make the group file for each of the split query files.

```
parallel --jobs 3 "bin/group_seqs 0 test_files/03_references.fasta {} -1 -1 762" ::: test_files/16_references.fasta.split_*
```

And finally partition the original query file based on the type column.

```
bin/partition_seqs test_files/16_references.fasta test_files/16_references.fasta.split_*.seq_groups
```

## Picking reference sequences

You can include as many reference sequences as you would like, but make the the first one in the reference file is the one you want to annotate against. In other, this is the sequence with which columns in the aligment with be named.
