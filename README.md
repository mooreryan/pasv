# PASV

**P**rotein **A**ctive **S**ite **V**alidator

## Overview

Filter and partition protein sequences with respect to how they align with important positions on a reference sequence.  For example, identifying phage lifestyle based on 762 position of the DNA polA protein in *E. coli* (see [this paper](http://www.nature.com/ismej/journal/v8/n1/full/ismej2013124a.html)).

The user can pick any references with any regions of intersest and with any set of key residues with which to partition protein sequences. Also, any alignmet software can be used for the alignment.

## Installing

### Docker image

If you are not used to using Ruby programs, just use the Docker image that we've made.  Find it [here](TODO).

### Dependencies

#### Alignment software

You need to have some kind of multiple sequence alignment software installed somewhere on your path. PASV supports MAAFT and Clustal Omega out of the box, but any MSA software will work as long as it is on your path.

#### Other stuff

You need a Ruby interpreter, at least version 2, and the `gem` command to install RubyGems.

I highly recommend using `rvm` to manage your installation of Ruby.  Get it [here](https://rvm.io).

The following Gems:

- bundler (for installing dependencies).
- abort_if, ~> 0.2.0
- parse_fasta, ~> 2.3
- parallel, ~> 1.12, >= 1.12.1
- pasv_lib, ~> 0.1.1
- trollop, ~> 2.1, >= 2.1.2

See how to install these below.

### Get the code

Use git to clone the git repository.

```
$ git clone https://github.com/mooreryan/pasv.git
```

or download a release from [here](https://github.com/mooreryan/pasv/releases).

### Get the needed RubyGems

First make sure you have bundler installed.

```
$ gem install bundler
```

Then

`cd` into the `pasv` directory and type `bundle install`, to install the dependencies.

That's it.  If you want, you could move or symlink the `pasv` program to somewhere on your path.  Assuming `~/bin` is on your path, you could type

```
$ ln -s $PWD/pasv $HOME/bin
```

from the source directory.

## Usage

### Synopsis

```
Usage: pasv [-a aligner] [-p 'alignment params'] [-i 'I/O format string'] [-s region_start] [-e region_end] [-o outdir] [-t num cpus] -r ref_seqs -q query_seqs pos1
[pos2 ...]
```

### Other info

If you are not interested in a spanning region, do not pass `-s` and
`-e` or pass `'-s -1 -e -1'`.

When you specify options for the aligner or I/O string for the
aligner and those options start with a `-` (dash) character, you
must put a `\` (backslash) character in front of the dash like this:

```
-p '\--threads 1 \--iterations 1'
```

or like this

```
-i '\-i %s \-o %s'
```

If some sequences have identical headers, only the first one will be
kept.



### Example

You can run PASV on the test files by running `make test` or by using a command like this:

```
$ pasv -a mafft -m 1 -t 4 -r test_files/amk_ref.faa -q test_files/amk_queries.faa -s 200 -e 800 500 501
```

Each partition that PASV finds will have its own fasta file like this:

```
$ tree pasv_outdir/
pasv_outdir/
├── pasv.partition_CF_Yes.fa
├── pasv.partition_ED_No.fa
├── pasv.partition_ED_Yes.fa
└── pasv_counts.txt
```

In this case, the partition combines the amino acid's at sites 500 and 501, as well as if it spans the region from 200 to 800.

### Passing in command line args to the MSA software

PASV can pass in command line arguments to whichever MSA software you want to use with the `-p` command. Say you want to do more iterations in Clustal Omega. The option for this is `--iter num_of_iterations`. So, to use 3 iterations, you would pass this flag to the `pasv` command

```
-p '\--iter 3'
```

**NOTE**: Please note the `\` infront of the first `-` in the command being passed.  This is required to properly parse the options.

How about if we want to use MAFFT and adjust the gap opening penalty to 3. The option for gap opening penalty in MAFFT is `--op`. For fun, we can also change the `--maxiterate` option at the same time. So in PASV, you would do that like so

```
pasv -a mafft -p '\--op 3 \--maxiterate 1000' ...
```

This shows how you can pass in any command line args to the MSA software you want.

*Note*: When using by default, PASV tells `mafft` and `clustalo` to use a single thread as many instances of the software will be running concurrently.  You could play around with this to possibly get better performance.  E.g., if you have 8 cores, with `mafft` you could pass in `--cpus 4 -p '\--thread 2'` to have 4 instances of mafft running two threads each.  In general, it is probably better to just use all your cpus for PASV with the `--cpus` option.

### Using other alignment software

Support for MAFFT and Clustal Omega are supported directly. However, any MSA software should work if it is on your path. You just need to set the `-i` option to tell `pasv` how you favorite MSA program handles input and output.

#### Example

If Clustal Omega weren't supported already, here is how you could use it with `pasv`.

Running `clustalo --help` shows an example of running Clustal Omega like this...

```
clustalo -i my-in-seqs.fa -o my-out-seqs.fa -v
```

The key here is you specify input and output files to the program. In this case it is `-i input_file -o output_file`. To tell `pasv` how to use this, you would pass in `'\-i %s \-o %s'` to `pasv`'s `-i` option like so

```
pasv -a clustalo -i '\-i %s \-o %s' [other options]
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

Great, so now we build the I/O string like this `'\-in %s \-out %s'` and pass everything in to the `pasv` command like this

```
pasv -a muscle -i '\-in %s \-out %s' ...
```

## Picking reference sequences

You can include as many reference sequences as you would like, but make the the first one in the reference file is the one you want to annotate against. In other words, this is the sequence with which columns in the aligment with be named.

## Known Issues

When using Clustal Omega, we recommend passing in `-p '--threads 1'` or to some other low number because Clustal Omega uses all cpus by default.
