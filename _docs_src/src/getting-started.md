# Getting started

Learning how to use a new command line program can be a real challenge!!  I wrote this roadmap to try and give you a little guidance on how to get started using PASV.  There are a lot of pages in the wiki, but if you follow along in this order, I think you will be able to get a good feel for the program!

## Version 1 vs. Version 2

If you're looking for the source code or documentation for `pasv` version 1 (e.g., to follow along with the [PASV manuscript](https://doi.org/10.1101/2021.01.20.427478), see the [GitHub archive](https://github.com/mooreryan/pasv_v1) and the old [wiki](https://github.com/mooreryan/pasv_v1/wiki).

Version 2 is easier to install and lets you use different methods for checking residues (multiple sequence alignment, hidden Markov models, and raw checking of alignment files).

## Installation

The easiest way to start using PASV is probably by using one of the [Docker images](./todo.md).  It comes with everything you need to run PASV, including all external dependencies.  If you are a Windows user, this is currently your only way to use PASV.

Installing PASV is also easy if you use one of the [precompiled binaries](./installing-precompiled-binaries.md).  This is actually the easier option if you already have one of [Clustal Omega](http://www.clustal.org/omega/), [MAAFT](https://mafft.cbrc.jp/alignment/software/), or [HMMER](http://hmmer.org/) installed.

Alternatively, if you are an OCaml programmer or want to run the test suite locally, you can [install PASV from source](./installing-from-source.md).

## PASV CLI

An [overview of the PASV CLI](./cli.md) is available as well as examples for using PASV.

## PASV Details

Once you've gone through the above introductory material, you will probably want to check out a few more pages.  Check out the following pages to learn about [picking good references and key residues](./picking-refs-and-residues.md).  We spent a lot of time working out best practices for these things in the manuscript, so I encourage you to check it out!

Finally, if you're stuck and need help, [open an issue](https://github.com/mooreryan/pasv/issues) and I will try and clear up any difficulties you're having!
