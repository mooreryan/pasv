CC = gcc
MKDIR_P = mkdir -p
CFLAGS = -Wall -g -O2 -Wno-unused-function
LDFLAGS = -lz
BIN = bin
VENDOR = vendor
SRC = src
TEST_D = test_files

OBJS := $(SRC)/aln.o \
	$(SRC)/rseq.o \
        $(VENDOR)/tommyarray.o \
        $(VENDOR)/tommyhashlin.o \
        $(VENDOR)/tommyhash.o \
        $(VENDOR)/tommylist.o

CLUSTAL_CFLAGS = `pkg-config --cflags clustalo`
CLUSTAL_LIBS = `pkg-config --libs clustalo`

.PHONY: all
.PHONY: clean
.PHONY: clean_test
.PHONY: test_ai_pvcpipe

all: bin_dir split_seqs group_seqs partition_seqs

bin_dir:
	$(MKDIR_P) $(BIN)

group_seqs:
	$(CC) -c $(CFLAGS) $(CLUSTAL_CFLAGS) $(SRC)/$@.c
	g++ $(CFLAGS) -o $(BIN)/$@ $(CLUSTAL_LIBS) $@.o


partition_seqs: $(OBJS)
	$(CC) $(CFLAGS) -o $(BIN)/$@ $^ $(SRC)/$@.c $(LDFLAGS)

split_seqs:
	$(CC) $(CFLAGS) -o $(BIN)/$@ $(SRC)/$@.c $(LDFLAGS)

ai_pvcpipe: $(OBJS)
	$(CC) $(CFLAGS) -o $(BIN)/$@ $^ $(SRC)/$@.c $(LDFLAGS) -lpthread

clean:
	-rm -r $(BIN) $(OBJS) *.o

clean_test:
	-rm $(TEST_D)/*type* $(TEST_D)/*split* $(TEST_D)/*group*

test_ai_pvcpipe:
	rm -r tmp; valgrind $(BIN)/ai_pvcpipe -a clustalo -p '--iter 0' -d tmp -s 700 -e 800 -t 2 -r $(TEST_D)/refs.fa -q $(TEST_D)/queries.fa 762 763
