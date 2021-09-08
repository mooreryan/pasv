# Tons of Examples

If you want to see a ton of examples on how to run (and how to break) `pasv`, there are many examples in the [tests](https://github.com/mooreryan/pasv/tree/master/test) directory of the [pasv GitHub repository](https://github.com/mooreryan/pasv/).

With in the test directory, there are three directories, `slow`, `medium`, and `fast`.  Each of these contain directories that end in `.t`.  Each of those define a [Cram test](https://bitheap.org/cram/).  Inside of the `*.t` directories you will find a `run.t` file as well as other files necessary for the tests to run (e.g., query sequences, reference sequences, etc.).

Each `run.t` file exercises a specific aspect of using the `pasv` command line app.  The nice part about `run.t` files is that they are written as sort of "pseudo" bash scripts.  Any thing starting with a `$` is run in a sandboxed environment.  Everything else are comments describing what is going on.

The other cool thing is that each of these examples is tested under [continuous integration](./todo.md).  This means that any example that works will work with the latest version of `pasv` and any example that should fail will *not* work with the latest version of `pasv`.

Because of these two aspects, you can consider the `run.t` examples a kind of spec on `pasv` CLI usage.
