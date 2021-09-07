# Picking Key References and Residue Positions

## References

### For MSA mode

The PASV manuscript goes in to a *lot* of detail about best practices for picking reference sequences for your gene of interest.  If you want the details check out the paper :)

For example, for ribonucleotide reductase (RNR) sequences, I got a bunch of annotated sequences from the RNRdb, hand validated them, and then tested a BUNCH of ways of picking references sequences from among them.  For Clustal Omega, most randomly chosen reference sets worked pretty well, but there were a couple of points to keep in mind when making a reference set for your protein of interest.

Mainly it boils down to just a couple of important points:

- Select between 10 and 20 sequences if possible.
- Select sequences that align well with each other.
- Select full length protein sequences (as opposed to partial sequences).

### For HMM mode

This part of the documentation isn't finished yet :)

## Residues/Positions

The manuscript goes into a lot of detail about this as well, so I encourage you check it out :)

Here's the TL;DR:

- Pick residues that are important to protein function.
- Pick residues that have been biochemically characterized.
- Pick residues that are invariant (or at least highly conserved).

If your lucky, you will find a small set of residues that will satisfy all these conditions!

For example, in RNR, there are certain residues key to proper protein function.  So if there are point mutations in the key residues, then we have some pretty good evidence that the sequence represents a non-functional RNR (or some other protein entirely).  Again, see the manuscript for more info about this.
