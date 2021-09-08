(lang dune 2.8)

(generate_opam_files true)

(cram enable)

(package
 (name pasv)
 (version 2.0.0-alpha)
 (license "MIT")
 (maintainers "Ryan Moore")
 (authors "Ryan Moore")
 (homepage "https://github.com/mooreryan/little_logger")
 (source (github mooreryan/little_logger))
 (documentation "https://github.com/mooreryan/little_logger/wiki")
 (bug_reports "https://github.com/mooreryan/little_logger/issues")
 (synopsis "pasv -- protein active site validation")
 (depends
   async
   bio_io
  (bisect_ppx :dev)
   core
   cmdliner
   little_logger
   ocaml
   ppx_deriving
   ppx_jane
   re2))
