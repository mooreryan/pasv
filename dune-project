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
   (and
    (>= "v0.15.0")
    (< "v0.16.0")))
  (bio_io
   (and
    (>= "0.6.0")
    (< "0.7.0")))
  (bisect_ppx
   (and
    (>= "2.8.0")
    (< "2.9.0")))
  (core
   (and
    (>= "v0.15.0")
    (< "v0.16.0")))
  (core_unix
   (and
    (>= "v0.15.0")
    (< "v0.16.0")))
  (cmdliner
   (and
    (>= "1.2.0")
    (< "1.3.0")))
  (little_logger
   (and
    (>= "0.2.0")
    (< "0.3.0")))
  (ocaml
   (= "4.14.1"))
  (ocamlformat
   (= "0.25.1"))
  (ppx_jane
   (and
    (>= "v0.15.0")
    (< "v0.16.0")))
  (re2
   (and
    (>= "v0.15.0")
    (< "v0.16.0")))))
