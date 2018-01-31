TEST_D = test_files

.PHONY: test

test: pasv
	rm -r pasv_outdir; ruby pasv -a mafft -i '%s > %s' -p '\--thread 1 \--quiet' -m 1 -t 4 -r $(TEST_D)/amk_ref.faa -q $(TEST_D)/amk_queries.faa -s 200 -e 800 -o pasv_outdir 500 501
	diff pasv_outdir/pasv.partition_CF_Yes.fa $(TEST_D)/expected/pasv.partition_CF_Yes.fa
	diff pasv_outdir/pasv.partition_ED_No.fa $(TEST_D)/expected/pasv.partition_ED_No.fa
	diff pasv_outdir/pasv.partition_ED_Yes.fa $(TEST_D)/expected/pasv.partition_ED_Yes.fa
	diff pasv_outdir/pasv_counts.txt $(TEST_D)/expected/pasv_counts.txt
