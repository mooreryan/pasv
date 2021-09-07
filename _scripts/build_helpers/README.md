# Build helpers

Scripts to help build different versions of `pasv`.

## Static build

First, make sure the `./_scripts/build_helpers/bin_dune_static` dune file has the proper changes w.r.t. the `./bin/dune` file.  (E.g., just the static linking opts.)

If you change the `./bin/dune` file, you should remake the patched version.  The `build_static` scripts take care of actually making and applying the patch for you.

The GitHub action builds the static executable.
