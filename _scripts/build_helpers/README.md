# Build helpers

Scripts to help build different versions of `pasv`.

## Static build

### Docker image

For the statically linked build, we use the Opam Alpine Docker image (`ocaml/opam:alpine-ocaml-4.12`) as the base and then install the deps in new container.

```
time sudo docker build --network=host -t pasv_alpine_static -f Dockerfile.build_static . ; alert
```

If you change the dependencies, don't forget to rebuild this image.

### Building an exe

First, make sure the `./_scripts/build_helpers/bin_dune_static` dune file has the proper changes w.r.t. the `./bin/dune` file.  (E.g., just the static linking opts.)

If you change the `./bin/dune` file, you should remake the patched version.  The `build_static` scripts take care of actually making and applying the patch for you.

Finally, run the `build_static` script in the Docker container from the root directory of the `pasv` repository.

```
$ time sudo docker run --network=host -v $(pwd):$(pwd) -w $(pwd) --rm -it pasv_alpine_static _scripts/build_helpers/build_static
```
