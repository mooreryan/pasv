(lang dune 2.8)

(generate_opam_files true)

(cram enable)

(package
 (name pasv)
 (version 2.0.2)
 (license "MIT")
 (maintainers "Ryan Moore")
 (authors "Ryan Moore")
 (homepage "https://github.com/mooreryan/pasv")
 (source (github mooreryan/pasv))
 (documentation "https://mooreryan.github.io/pasv/")
 (bug_reports "https://github.com/mooreryan/pasv/issues")
 (synopsis "pasv -- protein active site validation")
 (depends
   async
  (bio_io (and (>= "0.3.0") (< "0.4.0")))
  (bisect_ppx :dev)
   core
  (core_kernel (= "v0.14.1"))
   cmdliner
   little_logger
   ocaml
   ppx_deriving
   ppx_jane
  (ppx_optcomp (= "v0.14.2"))
   re2))
