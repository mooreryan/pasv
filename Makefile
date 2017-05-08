CC = gcc
MKDIR_P = mkdir -p
CFLAGS = -Wall -g -O2
LDFLAGS = -lz
BIN = bin
VENDOR = vendor
SRC = src

OBJS = $(VENDOR)/tommyarray.o \
       $(VENDOR)/tommyhashlin.o \
       $(VENDOR)/tommyhash.o \
       $(VENDOR)/tommylist.o

CLUSTAL_CFLAGS = `pkg-config --cflags clustalo`
CLUSTAL_LIBS = `pkg-config --libs clustalo`

.PHONY: all
.PHONY: clean
.PHONY: clean_test

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
	-rm test_files/*type* test_files/*split* test_files/*group*
