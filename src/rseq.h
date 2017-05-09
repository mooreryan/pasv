#ifndef RSEQ_H
#define RSEQ_H

#include <zlib.h>
#include "kseq.h"

KSEQ_INIT(gzFile, gzread)

typedef struct rseq_t {
  char* head;
  char* seq;
  char* key_chars;

  int head_len;
  int seq_len;
  int spans_region;

} rseq_t;

static int
get_header_size(kseq_t* kseq);

static int
set_header(rseq_t* rseq,
           kseq_t* kseq);

rseq_t*
rseq_init(kseq_t* kseq);

void
rseq_destroy(rseq_t* rseq);

void
rseq_print(FILE* fstream,
           rseq_t* rseq);

#endif
