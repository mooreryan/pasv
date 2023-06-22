# PASV

[![Build and Test](https://github.com/mooreryan/pasv/actions/workflows/build_and_test.yml/badge.svg?branch=main)](https://github.com/mooreryan/pasv/actions/workflows/build_and_test.yml) [![Build and Test Static](https://github.com/mooreryan/pasv/actions/workflows/build_and_test_static.yml/badge.svg?branch=main)](https://github.com/mooreryan/pasv/actions/workflows/build_and_test_static.yml) [![Generate Docs](https://github.com/mooreryan/pasv/actions/workflows/generate_docs.yml/badge.svg?branch=main)](https://github.com/mooreryan/pasv/actions/workflows/generate_docs.yml)

[![code on GitHub](https://img.shields.io/badge/code-GitHub-blue)](https://github.com/mooreryan/pasv) [![GitHub issues](https://img.shields.io/github/issues/mooreryan/pasv)](https://github.com/mooreryan/pasv/issues) [![Coverage Status](https://coveralls.io/repos/github/mooreryan/pasv/badge.svg?branch=main)](https://coveralls.io/github/mooreryan/pasv?branch=main)

**P**rotein **A**ctive **S**ite **V**alidation

Post-homology search validation and partitioning of sequences by specific residues (active sites, conserved residues, etc).

## Documentation

For background and motivation as well as information on installation and usage, please visit the [documentation website](https://mooreryan.github.io/pasv/).

## Citation

If you use pasv, please cite the PASV [preprint](https://doi.org/10.1101/2021.01.20.427478). Thank you!!

## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/pasv)

Copyright (c) 2017 - 2023 Ryan Moore.

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.

## Hacking

The default branch was recently renamed from `master` to `main`. If you have a local clone of the repository, you will need to update it.

```
git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a
```
