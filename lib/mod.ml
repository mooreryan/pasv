open! Core

(* wrt: with respect to *)
module rec Position : sig
  type one_indexed
  type zero_indexed
  type aln
  type raw

  type ('indexing, 'wrt) t

  type zero_indexed_aln = (zero_indexed, aln) t
  type zero_indexed_raw = (zero_indexed, raw) t
  type one_indexed_aln = (one_indexed, aln) t
  type one_indexed_raw = (one_indexed, raw) t

  module Map_wrt : sig
    (* For mapping from one indexing to the other. *)
    type ('indexing, 'from, 'to_) t
    val empty_zero_raw_aln : unit -> (zero_indexed, raw, aln) t
    val add_exn :
      ('indexing, 'from, 'to_) t ->
      from:('indexing, 'from) Position.t ->
      to_:('indexing, 'to_) Position.t ->
      ('indexing, 'from, 'to_) t
    val find_or_error :
      ('indexing, 'from, 'to_) t ->
      ('indexing, 'from) Position.t ->
      ('indexing, 'to_) Position.t Or_error.t
    val length : ('indexing, 'from, 'to_) t -> int
  end

  module List : sig
    type ('indexing, 'wrt) t

    val to_list : ('indexing, 'wrt) t -> int list
    val one_raw_of_list : int list -> (one_indexed, raw) t

    val one_to_zero : (one_indexed, 'wrt) t -> (zero_indexed, 'wrt) t

    val zero_raw_to_zero_aln :
      (zero_indexed, raw, aln) Map_wrt.t ->
      (* (int, int, Int.comparator_witness) Map.t -> *)
      (zero_indexed, raw) t ->
      (zero_indexed, aln) t Or_error.t
  end

  val ( + ) : ('indexing, 'wrt) t -> ('indexing, 'wrt) t -> ('indexing, 'wrt) t
  val add : ('indexing, 'wrt) t -> ('indexing, 'wrt) t -> ('indexing, 'wrt) t
  val to_int : ('indexing, 'wrt) t -> int

  (* You can only compare positions that have the same indexing and wrt. *)
  val compare : ('indexing, 'wrt) t -> ('indexing, 'wrt) t -> int
  val equal : ('indexing, 'wrt) t -> ('indexing, 'wrt) t -> bool
  val ( < ) : ('indexing, 'wrt) t -> ('indexing, 'wrt) t -> bool
  val ( <= ) : ('indexing, 'wrt) t -> ('indexing, 'wrt) t -> bool
  val ( > ) : ('indexing, 'wrt) t -> ('indexing, 'wrt) t -> bool
  val ( >= ) : ('indexing, 'wrt) t -> ('indexing, 'wrt) t -> bool

  val zero_raw_of_int : int -> (zero_indexed, raw) t
  val one_raw_of_int : int -> (one_indexed, raw) t

  val zero_aln_of_int : int -> (zero_indexed, aln) t
  val one_aln_of_int : int -> (one_indexed, aln) t

  val one_to_zero : (one_indexed, 'wrt) t -> (zero_indexed, 'wrt) t
  val zero_raw_to_zero_aln :
    (zero_indexed, raw, aln) Map_wrt.t ->
    (* (int, int, Int.comparator_witness) Map.t -> *)
    (zero_indexed, raw) t ->
    (zero_indexed, aln) t Or_error.t
end = struct
  type one_indexed
  type zero_indexed
  type aln
  type raw

  type ('indexing, 'wrt) t = int

  type zero_indexed_aln = (zero_indexed, aln) t
  type zero_indexed_raw = (zero_indexed, raw) t
  type one_indexed_aln = (one_indexed, aln) t
  type one_indexed_raw = (one_indexed, raw) t

  module Map_wrt = struct
    type ('indexing, 'from, 'to_) t =
      (int, int, Int.comparator_witness) Core.Map.t

    let empty_zero_raw_aln () = Core.Map.empty (module Int)
    let add_exn map ~from ~to_ = Map.add_exn map ~key:from ~data:to_
    let find_or_error map key = Map.find_or_error map key
    let length map = Map.length map
  end

  module List = struct
    type ('indexing, 'wrt) t = int list

    let to_list x = x
    let one_raw_of_list x = x

    let one_to_zero positions = List.map positions ~f:Position.one_to_zero

    let zero_raw_to_zero_aln pos_map positions =
      Or_error.all
      @@ List.map positions ~f:(Position.zero_raw_to_zero_aln pos_map)
  end

  let add x y = x + y
  let ( + ) = add

  let to_int x = x

  let compare = Int.compare
  let equal = Int.equal
  let ( < ) = Int.( < )
  let ( <= ) = Int.( <= )
  let ( > ) = Int.( > )
  let ( >= ) = Int.( >= )

  let zero_raw_of_int x = x
  let one_raw_of_int x = x

  let zero_aln_of_int x = x
  let one_aln_of_int x = x

  let one_to_zero x = x - 1
  let zero_raw_to_zero_aln pos_map x = Map.find_or_error pos_map x
end

and Record : sig
  type 'position t

  val aln_of_fasta_record : Bio_io.Fasta_record.t -> Position.aln t
  val raw_of_fasta_record : Bio_io.Fasta_record.t -> Position.raw t

  val to_fasta_record : 'positions t -> Bio_io.Fasta_record.t

  val get_aln_residues :
    (Position.zero_indexed, Position.aln) Position.List.t ->
    Position.aln t ->
    string list
end = struct
  type 'position t = Bio_io.Fasta_record.t

  let aln_of_fasta_record x = x
  let raw_of_fasta_record x = x

  let to_fasta_record x = x

  let get_aln_residues positions record =
    let seq = Bio_io.Fasta_record.seq record in
    List.map positions ~f:(fun aln_i -> String.of_char @@ String.get seq aln_i)
end
