# PASV

**P**rotein **A**ctive **S**ite **V**alidater

## Overview

Partition protein sequences with respect to how they align with important positions on a reference sequence, for example, identifying phage lifestyle based on 762 position of the DNA polA protein in *E. coli*.

It is basically a generalized version of [this](https://github.com/dnasko/dna_pola_762_caller) program, which was inspired by [this](http://www.nature.com/ismej/journal/v8/n1/full/ismej2013124a.html) paper by Schmidt et al. The user can pick any references with any regions of intersest and with any set of key residues with which to partition protein sequences. Also, any alignmet software can be used for the alignment.

## Dependencies

### Alignment software

You need to have some kind of multiple sequence alignment software installed somewhere on your path. PASV supports MAAFT and Clustal Omega out of the box, but any MSA software will work as long as it is on your path.

## Installing

### Get the code

Use git to clone the git repository.

```
$ git clone https://github.com/mooreryan/pasv.git
```

### Compile it

`cd` into the `pasv` directory and type `make`.

This will put the `pasv` binary program into a directory called `bin` in this folder. You can now move this file to somewhere on your path if you want.

## Usage

### Synopsis

```
pasv [-a aligner] [-p 'alignment params'] [-i 'I/O format string'] [-s region_start] [-e region_end] -d alignment_file_dir -o output_base_name -t num_threads -r ref_seqs -q query_seqs pos1 [pos2 ...] 
```

### Example

You can run the test files like this.

```
$ bin/pasv -a mafft -s 700 -e 800 -d align_dir -o pola -t 2 -r test_files/refs.fa -q test_files/queries.fa 762 765
```

And the output directory contents will be these...

```
$ tree align_dir/

align_dir/
├── pasv.q_0.t_0.aln.fa
├── pasv.q_1.t_1.aln.fa
└── pola.type_info.txt
```

## Picking reference sequences

You can include as many reference sequences as you would like, but make the the first one in the reference file is the one you want to annotate against. In other, this is the sequence with which columns in the aligment with be named.
