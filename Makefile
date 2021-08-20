BROWSER = firefox
NAME=pasv
TEST_COV_D = /tmp/pasv

.PHONY: build
build:
	dune build

.PHONY: test_slow
test_slow: build
	dune test test/slow

.PHONY: test_medium
test_medium: build
	dune test test/medium

.PHONY: test_fast
test_fast: build
	dune test test/fast

.PHONY: test
test: test_fast test_medium test_slow

.PHONY: test_coverage
test_coverage:
	if [ -d $(TEST_COV_D) ]; then rm -r $(TEST_COV_D); fi
	mkdir -p $(TEST_COV_D)
	BISECT_FILE=$(TEST_COV_D)/$(NAME) dune runtest --no-print-directory \
	  --instrument-with bisect_ppx --force
	bisect-ppx-report html --coverage-path $(TEST_COV_D)
	bisect-ppx-report summary --coverage-path $(TEST_COV_D)

.PHONY: test_coverage_open
test_coverage_open: test_coverage
	$(BROWSER) _coverage/index.html

.PHONY: send_coverage
send_coverage: test_coverage
	bisect-ppx-report send-to Coveralls --coverage-path $(TEST_COV_D)
