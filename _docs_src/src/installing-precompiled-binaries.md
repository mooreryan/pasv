# Installing Precompiled Binaries

The simplest way to get started with PASV is to use one of the precompiled binaries available on the [releases](https://github.com/mooreryan/pasv/releases) page.

A couple different "flavors" are available:

* MacOS -- use this if you have a Mac.  I have not tested it on the new Arm chip macs, only intel.
* Linux (Ubuntu, dynamic linking)
  * This should work on Ubuntu-like systems (e.g., Debian and possible others).
  * It does have some dynamically linked C/C++ libraries, so it may not work if you have an older system.  See the release page for more info.
* Linux (Alpine, static linking)
  * This *should* work on most Linux systems.
  * It is statically linked, so it should *Just Work* :)
  * If you are on Linux, this is the one you probably want.

You can find them all on the [releases](https://github.com/mooreryan/pasv/releases) page.

Additionally, you will need to install the [external dependencies](./installing-external-dependencies.md) that PASV relies on.
