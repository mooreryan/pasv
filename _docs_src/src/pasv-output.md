# PASV Output

`pasv` programs output a tab-separated text file (TSV) that lists [key residues](jargon.md#key-reference-sequences-positions-residues), [signatures](jargon.md#signatures-signature-files), and [region of interest](jargon#region-of-interest.md) spanning info for each query sequence.

Here is how that file might look.


| name                           | pos_50 | pos_52 | pos_54 | signature | spans_start | spans_end | spans   |
|--------------------------------|--------|--------|--------|-----------|-------------|-----------|---------|
| AMK99662_spans_start_19_60_IQK | I      | Q      | K      | IQK       | Yes         | No        | Start   |
| AMK99662_spans_end_40_80_IQK   | I      | Q      | K      | IQK       | No          | Yes       | End     |
| AMK99662_spans_start_20_60_IQK | I      | Q      | K      | IQK       | Yes         | No        | Start   |
| AMK99662_21_60_IQK             | I      | Q      | K      | IQK       | No          | No        | Neither |
| AMK99662_40_79_IQK             | I      | Q      | K      | IQK       | No          | No        | Neither |
| AMK99662_spans_end_40_81_IQK   | I      | Q      | K      | IQK       | No          | Yes       | End     |
| AMK99662_spans_both_20_80_IQK  | I      | Q      | K      | IQK       | Yes         | Yes       | Both    |
| AMK99662_spans_both_19_81_IQK  | I      | Q      | K      | IQK       | Yes         | Yes       | Both    |
| AMK99662_21_79_IQK             | I      | Q      | K      | IQK       | No          | No        | Neither |
| AMK99662_full_length_IQK       | I      | Q      | K      | IQK       | Yes         | Yes       | Both    |
| AMK99662_real_seq_IQK          | I      | Q      | K      | IQK       | Yes         | Yes       | Both    |
| AMK99662_full_length_extra_IQK | I      | Q      | K      | IQK       | Yes         | Yes       | Both    |
| AMK99662_spans_start_20_60_ABC | A      | B      | C      | ABC       | Yes         | No        | Start   |
| AMK99662_spans_start_19_60_ABC | A      | B      | C      | ABC       | Yes         | No        | Start   |
| AMK99662_21_60_ABC             | A      | B      | C      | ABC       | No          | No        | Neither |
| AMK99662_spans_end_40_80_ABC   | A      | B      | C      | ABC       | No          | Yes       | End     |
| AMK99662_spans_end_40_81_ABC   | A      | B      | C      | ABC       | No          | Yes       | End     |
| AMK99662_40_79_ABC             | A      | B      | C      | ABC       | No          | No        | Neither |
| AMK99662_spans_both_20_80_ABC  | A      | B      | C      | ABC       | Yes         | Yes       | Both    |
| AMK99662_spans_both_19_81_ABC  | A      | B      | C      | ABC       | Yes         | Yes       | Both    |
| AMK99662_21_79_ABC             | A      | B      | C      | ABC       | No          | No        | Neither |
| AMK99662_full_length_ABC       | A      | B      | C      | ABC       | Yes         | Yes       | Both    |
| AMK99662_real_seq_ABC          | A      | B      | C      | ABC       | Yes         | Yes       | Both    |
| AMK99662_full_length_extra_ABC | A      | B      | C      | ABC       | Yes         | Yes       | Both    |

## Columns

* `name`
    * The ID of the sequence.
	* I.e., the part of the fasta header up until the first space.
* `pos_50`
    * This is the first [key residue position](jargon.md#key-reference-sequences-positions-residues).
	* It is the residue in the query that aligns with the residue in position 50 of the reference sequence.
* `pos_52`
    * The 2nd key residue position
* `pos_54`
    * The 3rd and final key residue position
* `signature`
    * A concatenation of the residues at each of the key residue positions for each query sequence
* `spans_start`
    * Does the query sequence span the start of a specified [region of interest](jargon#region-of-interest.md) with numbering according to the key reference sequence?
	* `Yes` or `No`
* `spans_end`
    * Does the query sequence span then end of a specified region of interest?
	* `Yes` or `No`
* `spans`
    * Will be one of `Neither`, `Start`, `End`, or `Both`
	* Based on the values in `spans_start` and `spans_end`
