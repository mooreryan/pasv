# Why you may need PASV

In the [manuscipt](https://doi.org/10.1101/2021.01.20.427478 ), we used PASV for a couple of different test cases.

## Eliminating bycatch after sensitive homology search

- We used PASV to removing likely non-functional ribonucleotide-reductase (RNR) sequences based on acitve sites critical to proper RNR function.
- Of ~10,000 putative RNR sequences obtained via homology search, PASV (and manual curation) flagged ca. 2/3 of the sequences as bycatch based on key residues and aligments to a set of Class I alpha subunit and Class II RNR sequences.
- Common gene families within the bycatch sequences included RNR Class I beta subunits, thioredoxins, polymerases, helicases, and terminases.
- \>99% concordance with manual annotation

## Partitioning peptide sequences based on key residues

- Partitioning RNR Class I alpha and RNR Class II sequences
  - Using key residues to accurately partition RNR Class I alpha sequences from RNR Class II sequences
  - \>98% concordance with manual annotation
- Using amino acid signatures to differentiate Alternative oxidase (AOX) and plastid terminal oxidase (PTOX)
  - Two proteins that are challenging to differentiate by homology search alone
  - 100% concordance with manual annotation

## Other potential use cases

We didn't validate these in the manuscript, but our lab has used PASV to filter and partition DNA polymerase I (Pol I) peptides based on the residues at position 762 (*E. coli* numbering).  This position has been linked to changes in either the fidelity or efficiency of replication ([Tabor & Richardson 1995](http://dx.doi.org/10.1073/pnas.92.14.6339)), and may point mutations at this site may have implications for phage lifestyle ([Schmidt et al., 2014](http://dx.doi.org/10.1038/ismej.2013.124); [Nasko et al., 2018](http://dx.doi.org/10.3389/fmicb.2018.03053)).

There are many examples of point mutation(s) in bacterial proteins that prevent antibiotics from binding and, thus, inhibit the function of the antibiotic (e.g., K88R in *rpsL* ([Ballif et al., 2012](http://dx.doi.org/10.1186/1471-2180-12-191)), C117D in *murA* ([De_Smet et al., 1999](http://dx.doi.org/10.1099/00221287-145-11-3177)), H526T in *rpoB* ([Sajduda et al., 2004](http://dx.doi.org/10.1128/JCM.42.6.2425-2431.2004)), Q124K in EF-Tu ([Zuurmond et al., 1999](http://dx.doi.org/10.1006/jmbi.1999.3296)), V246A and V300G in *ndh* ([Vilcheze et al., 2005](http://dx.doi.org/10.1128/AAC.49.2.708-720.2005))).  Such point mutations within a protein would not be readily apparent from homology search alone.  Thus PASV could be used for validating and grouping these peptide sequences according to key point mutations following identification via homology search.
