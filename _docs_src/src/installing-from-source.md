# Installing PASV from source files

If you are not already an OCaml programmer, I recommend that you download one of the [precompiled binaries](./installing-precompiled-binaries.md) or use the [Docker image](./installing-with-docker.md) instead.

If you want to compile PASV from source, you need to have a working OCaml development setup.

Additionally, you will need to install [GNU Make](https://www.gnu.org/software/make/) and the [external dependencies](./installing-external-dependencies.md) that PASV relies on.

## Set up OCaml development environment

Instructions to set up an OCaml development environment can be found [here](https://ocaml.org/learn/tutorials/up_and_running.html) or [here](https://dev.realworldocaml.org/install.html).

## Get the code

Use git to clone the git repository.

```
$ git clone https://github.com/mooreryan/pasv.git
```

or download a release from [here](https://github.com/mooreryan/pasv/releases).

## Install OCaml dependencies

```
cd pasv
opam install . --deps-only --with-doc --with-test
```

## Build, install, & run tests

```
opam exec -- make build && opam exec -- make install && opam exec -- make test
```

## Sanity check

If all went well, this should give you the path to the `pasv` executable file.

```
which pasv
```
