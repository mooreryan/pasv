(lang dune 2.8)

(generate_opam_files true)

(cram enable)

(package
 (name pasv)
 (version 2.0.3-SNAPSHOT)
 (license "MIT")
 (maintainers "Ryan M. Moore")
 (authors "Ryan M. Moore")
 (homepage "https://github.com/mooreryan/pasv")
 (source
  (github mooreryan/pasv))
 (documentation "https://mooreryan.github.io/pasv/")
 (bug_reports "https://github.com/mooreryan/pasv/issues")
 (synopsis "PASV -- Protein Active Site Validation")
 (depends
  (async
   (= "v0.14.0"))
  (bio_io
   (and
    (>= "0.3.0")
    (< "0.4.0")))
  (bisect_ppx
   (= "2.7.0"))
  (core
   (= "v0.14.1"))
  (core_kernel
   (= "v0.14.1"))
  (cmdliner
   (= "1.0.4"))
  (little_logger
   (= "0.2.0"))
  (ocaml
   (= "4.14.1"))
  (ocamlformat
   (= "0.20.1"))
  (ppx_jane
   (= "v0.14.0"))
  (re2
   (= "v0.14.0"))))
