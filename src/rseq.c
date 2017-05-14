#include <assert.h>
#include <stdio.h>
#include "rseq.h"
#include "err_codes.h"

/* Returns -1 when something went wrong. Includes room for the
   terminating null char.

   head_len is the length of the header not including the terminating
   null char.

*/
int
get_header_size(kseq_t* kseq)
{
  if (kseq->comment.l && kseq->name.l) {
    /* plus 1 for the space and plus one for the null char */
    return kseq->name.l + 1 + kseq->comment.l + 1;
  } else if (kseq->name.l) {
    return kseq->name.l + 1;
  } else {
    return -1;
  }
}

/* Allocates a new char* on the heap */
char*
get_header_from_kseq(kseq_t* kseq)
{
  char* header = NULL;
  int header_size = get_header_size(kseq);
  PANIC_IF(header_size == -1,
           STD_ERR,
           stderr,
           "Could not get header size for %s",
           kseq->name.s);

  char buf[header_size];

  if (kseq->comment.l) {
    snprintf(buf,
             header_size,
             "%s %s",
             kseq->name.s,
             kseq->comment.s);

    /* TODO use strndup */
    header = strdup(buf);
  } else {
    header = strdup(kseq->name.s);
  }

  PANIC_MEM(header, stderr);

  return header;
}

/* Returns -1 on fail, 0 on sucess */
static int
set_header(rseq_t* rseq,
           kseq_t* kseq)

{
  int header_size = get_header_size(kseq);
  PANIC_IF(header_size == -1,
           STD_ERR,
           stderr,
           "Could not get header size for %s",
           kseq->name.s);

  char buf[header_size];

  if (kseq->comment.l) {
    snprintf(buf,
             header_size,
             "%s %s",
             kseq->name.s,
             kseq->comment.s);

    /* TODO use strndup */
    rseq->head = strdup(buf);
  } else {
    rseq->head = strdup(kseq->name.s);
  }

  PANIC_MEM(rseq->head, stderr);

  rseq->head_len = header_size - 1;

  return 0;
}


rseq_t*
rseq_init(kseq_t* kseq)
{
  int ret_code = 0;
  rseq_t* rseq = malloc(sizeof *rseq);
  PANIC_MEM(rseq, stderr);

  ret_code = set_header(rseq, kseq);
  PANIC_UNLESS(ret_code == 0,
               STD_ERR,
               stderr, "set_header failed");

  rseq->seq = strdup(kseq->seq.s);
  PANIC_MEM(rseq->seq, stderr);

  rseq->seq_len = kseq->seq.l;

  rseq->key_chars = NULL;
  rseq->type = NULL;
  rseq->spans_region = 0;
  rseq->first_ref_seq = 0;
  rseq->query_seq = 0;

  return rseq;
}

void
rseq_destroy(rseq_t* rseq)
{
  free(rseq->head);
  free(rseq->seq);
  free(rseq->key_chars);
  free(rseq->type);
  free(rseq);
}

void
rseq_print(FILE* fstream, rseq_t* rseq)
{
  fprintf(fstream,
          ">%s\n"
          "%s\n",
          rseq->head,
          rseq->seq);
}

int
rseq_compare(const void* arg, const void* rseq)
{
  return strcmp((const char*)arg,
                ((const rseq_t*)rseq)->head);
}

tommy_uint32_t
rseq_hash_head(rseq_t* rseq)
{
  return tommy_strhash_u32(0, rseq->head);
}

void
rseq_try_insert_hashlin(rseq_t* rseq, tommy_hashlin* hash)
{
  rseq_t* tmp = NULL;
  tommy_uint32_t hashed_head = rseq_hash_head(rseq);

  tmp = tommy_hashlin_search(hash,
                             rseq_compare,
                             rseq->head,
                             hashed_head);

  PANIC_IF(tmp,
           STD_ERR,
           stderr,
           "Header '%s' is repeated",
           rseq->head);

  tommy_hashlin_insert(hash,
                       &rseq->node,
                       rseq,
                       hashed_head);
}
