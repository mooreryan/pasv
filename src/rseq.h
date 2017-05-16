#ifndef RSEQ_H
#define RSEQ_H

#include <zlib.h>

#include "../vendor/tommyhashlin.h"

#include "../vendor/kseq.h"

KSEQ_INIT(gzFile, gzread)

typedef struct rseq_t {
  char* head;
  char* seq;
  char* key_chars;
  char* type;

  tommy_node node;

  int head_len;
  int seq_len;
  int spans_region;
  int first_ref_seq;
  int ref_seq;
  int query_seq;

} rseq_t;

/* Includes space for the terminating null char */
int
get_header_size(kseq_t* kseq);

char*
get_header_from_kseq(kseq_t* kseq);

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

/* Compares headers, if header is eq the seq is eq */
int
rseq_compare(const void* arg, const void* rseq);

tommy_uint32_t
rseq_hash_head(rseq_t* rseq);

int
rseq_try_insert_hashlin(rseq_t* rseq, tommy_hashlin* hash);



#endif
