TEST_D = test_files
OUT_D = pasv_outdir
TMP_TYPES_FILE = $(OUT_D)/tmparstoienarstoien

.PHONY: test_clustalo
.PHONY: test_mafft
.PHONY: test

test_clustalo:
	rm -r $(OUT_D); ruby pasv -a clustalo -m 1 -t 4 -r $(TEST_D)/amk_ref.faa -q $(TEST_D)/amk_queries.faa -s 200 -e 800 -o $(OUT_D) 500 501
	diff $(OUT_D)/pasv.partition_CF_Yes.fa $(TEST_D)/expected/pasv.partition_CF_Yes.fa
	diff $(OUT_D)/pasv.partition_ED_No.fa $(TEST_D)/expected/pasv.partition_ED_No.fa
	diff $(OUT_D)/pasv.partition_ED_Yes.fa $(TEST_D)/expected/pasv.partition_ED_Yes.fa
	diff $(OUT_D)/pasv_counts.txt $(TEST_D)/expected/pasv_counts.txt
	cut -f1,2 $(OUT_D)/pasv_types.txt > $(TMP_TYPES_FILE) && diff $(TMP_TYPES_FILE) $(TEST_D)/expected/pasv_types.txt && rm $(TMP_TYPES_FILE)

test_mafft:
	rm -r $(OUT_D); ruby pasv -a mafft -m 1 -t 4 -r $(TEST_D)/amk_ref.faa -q $(TEST_D)/amk_queries.faa -s 200 -e 800 -o $(OUT_D) 500 501
	diff $(OUT_D)/pasv.partition_CF_Yes.fa $(TEST_D)/expected/pasv.partition_CF_Yes.fa
	diff $(OUT_D)/pasv.partition_ED_No.fa $(TEST_D)/expected/pasv.partition_ED_No.fa
	diff $(OUT_D)/pasv.partition_ED_Yes.fa $(TEST_D)/expected/pasv.partition_ED_Yes.fa
	diff $(OUT_D)/pasv_counts.txt $(TEST_D)/expected/pasv_counts.txt
	cut -f1,2 $(OUT_D)/pasv_types.txt > $(TMP_TYPES_FILE) && diff $(TMP_TYPES_FILE) $(TEST_D)/expected/pasv_types.txt && rm $(TMP_TYPES_FILE)

test_clustalo_docker:
	rm -r $(OUT_D); bin/pasv_docker -a clustalo -m 1 -t 4 -r $(TEST_D)/amk_ref.faa -q $(TEST_D)/amk_queries.faa -s 200 -e 800 -o $(OUT_D) 500 501
	diff $(OUT_D)/pasv.partition_CF_Yes.fa $(TEST_D)/expected/pasv.partition_CF_Yes.fa
	diff $(OUT_D)/pasv.partition_ED_No.fa $(TEST_D)/expected/pasv.partition_ED_No.fa
	diff $(OUT_D)/pasv.partition_ED_Yes.fa $(TEST_D)/expected/pasv.partition_ED_Yes.fa
	diff $(OUT_D)/pasv_counts.txt $(TEST_D)/expected/pasv_counts.txt
	cut -f1,2 $(OUT_D)/pasv_types.txt > $(TMP_TYPES_FILE) && diff $(TMP_TYPES_FILE) $(TEST_D)/expected/pasv_types.txt && rm $(TMP_TYPES_FILE)

test_mafft_docker:
	rm -r $(OUT_D); bin/pasv_docker -a mafft -m 1 -t 4 -r $(TEST_D)/amk_ref.faa -q $(TEST_D)/amk_queries.faa -s 200 -e 800 -o $(OUT_D) 500 501
	diff $(OUT_D)/pasv.partition_CF_Yes.fa $(TEST_D)/expected/pasv.partition_CF_Yes.fa
	diff $(OUT_D)/pasv.partition_ED_No.fa $(TEST_D)/expected/pasv.partition_ED_No.fa
	diff $(OUT_D)/pasv.partition_ED_Yes.fa $(TEST_D)/expected/pasv.partition_ED_Yes.fa
	diff $(OUT_D)/pasv_counts.txt $(TEST_D)/expected/pasv_counts.txt
	cut -f1,2 $(OUT_D)/pasv_types.txt > $(TMP_TYPES_FILE) && diff $(TMP_TYPES_FILE) $(TEST_D)/expected/pasv_types.txt && rm $(TMP_TYPES_FILE)

test: test_clustalo test_mafft
test_docker: test_clustalo_docker test_mafft_docker
