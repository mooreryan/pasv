# Installing External Dependencies

PASV relies on a few other software packages to align sequences.

Currently, PASV supports [Clustal Omega](http://www.clustal.org/omega/), [MAAFT](https://mafft.cbrc.jp/alignment/software/), or [HMMER](http://hmmer.org/).

For detailed instructions on installing these packages, please consult their respective installation pages.

## Example installation instructions

Here are some basic instructions for installing the required software on the latest versions of MacOS and Ubuntu Linux.

_Note: These instructions are taken from one of the [GitHub actions that builds and tests PASV](https://github.com/mooreryan/pasv/blob/main/.github/workflows/build_and_test.yml), so if it is [passing](https://github.com/mooreryan/pasv/actions/workflows/build_and_test.yml) then these instructions should still work if you have a similar OS._

### Clustal Omega (Linux)

```
mkdir -p $HOME/.local/bin
CLUSTALO_EXE=$HOME/.local/bin/clustalo
\curl -L http://www.clustal.org/omega/clustalo-1.2.4-Ubuntu-x86_64 > "$CLUSTALO_EXE"
chmod 755 "$CLUSTALO_EXE"
```

### Clustal Omega (Mac)

Note that Clustal Omega 1.2.4 is not available on MacOS.

```
mkdir -p $HOME/.local/bin
CLUSTALO_EXE=$HOME/.local/bin/clustalo
\curl -L http://www.clustal.org/omega/clustal-omega-1.2.3-macosx > "$CLUSTALO_EXE"
chmod 755 "$CLUSTALO_EXE"
```

### MAFFT

```
\curl -L https://mafft.cbrc.jp/alignment/software/mafft-7.481-without-extensions-src.tgz \
  | tar xz
cd mafft-*/core/ && make clean && make && sudo make install
```

### HMMER

```
\curl -L http://eddylab.org/software/hmmer/hmmer-3.3.2.tar.gz | tar xz
cd hmmer-3.3.2 && ./configure && make && sudo make install
```
