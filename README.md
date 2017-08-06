# PASV

**P**rotein **A**ctive **S**ite **V**alidator

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

### Passing in command line args to the MSA software

PASV can pass in command line arguments to whichever MSA software you want to use with the `-p` command. Say you want to do more iterations in Clustal Omega. The option for this is `--iter num_of_iterations`. So, to use 3 iterations, you would pass this flag to the `pasv` command

```
-p '--iter 3'
```

How about if we want to use MAFFT and adjust the gap opening penalty to 3. The option for gap opening penalty in MAFFT is `--op`. For fun, we can also change the `--maxiterate` option at the same time. So in PASV, you would do that like so

```
pasv -a mafft -p '--op 3 --maxiterate 1000' ...
```

This shows how you can pass in any command line args to the MSA software you want.

*Note*: When using `clustalo`, you should probably pass in `-p '--threads 1'` because Clustal will default to using all cpus, which can lead to errors creating threads.

### Using other alignment software

Support for MAFFT and Clustal Omega are supported directly. However, any MSA software should work if it is on your path. You just need to set the `-i` option to tell `pasv` how you favorite MSA program handles input and output.

#### Example

If Clustal Omega weren't supported already, here is how you could use it with `pasv`.

Running `clustalo --help` shows an example of running Clustal Omega like this...

```
clustalo -i my-in-seqs.fa -o my-out-seqs.fa -v
```

The key here is you specify input and output files to the program. In this case it is `-i input_file -o output_file`. To tell `pasv` how to use this, you would pass in `'-i %s -o %s'` to `pasv`'s `-i` option like so

```
pasv -a clustalo -i '-i %s -o %s' [other options]
```

#### Another example

Let's see how we could use MAFFT if it weren't already available.

MAFFT is a bit different in that it writes output to standard out rather than to a file directly. PASV can handle this too!

First, run `mafft -h` to see how MAFFT handles input and output files. It's pretty simple...

```
mafft in > out
```

Nice...so how do we tell PASV about this? This is how the command would start...

```
pasv -a mafft -i '%s > %s' ...
```

#### Using a new aligner

The last two examples were just to show you how the I/O format strings work in PASV. Let's try to use Muscle, which PASV does not support out of the box.

First, figure out how `muscle` handles input and output by running `muscle -h`. You will see a bunch of stuff including

```
muscle -in <inputfile> -out <outputfile>
```

Great, so now we build the I/O string like this `'-in %s -out %s'` and pass everything in to the `pasv` command like this

```
pasv -a muscle -i '-in %s -out %s' ...
```

## Picking reference sequences

You can include as many reference sequences as you would like, but make the the first one in the reference file is the one you want to annotate against. In other, this is the sequence with which columns in the aligment with be named.

## Known Issues

When using Clustal Omega, we recommend passing in `-p '--threads 1'` or to some other low number because Clustal Omega uses all cpus by default.
