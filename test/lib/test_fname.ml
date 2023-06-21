open! Core
open Pasv_lib

let%test "boundary missing in position map" =
  let orig = "/apple/pie.txt.gz" in
  let fname = Fname.of_string orig in
  let fname_str = Fname.to_string fname in
  String.(orig = fname_str)

let%test_unit "checking for errors" =
  let gen =
    Quickcheck.Generator.map3 String.quickcheck_generator
      String.quickcheck_generator String.quickcheck_generator
      ~f:(fun s1 s2 s3 -> sprintf "/%s/%s/%s" s1 s2 s3)
  in
  Quickcheck.test gen ~shrinker:String.quickcheck_shrinker
    ~sexp_of:String.sexp_of_t ~examples:[""; "/4//b"] ~f:(fun s ->
      let _fname_str = Fname.to_string @@ Fname.of_string s in
      () )
