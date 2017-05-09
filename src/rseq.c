#include <assert.h>
#include <stdio.h>
#include "rseq.h"
#include "err_codes.h"

/* Returns -1 when something went wrong. Includes room for the
   terminating null char.

   head_len is the length of the header not including the terminating
   null char.

*/
static int
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

/* Returns -1 on fail, 0 on sucess */
static int
set_header(rseq_t* rseq,
           kseq_t* kseq)

{
  int header_size = get_header_size(kseq);
  assert(header_size != -1);

  char buf[header_size];

  int ret_code = 0;

  if (kseq->comment.l) {
    /* TODO use snprinf */
    ret_code = sprintf(buf,
                       "%s %s",
                       kseq->name.s,
                       kseq->comment.s);

    if (ret_code < 0) { /* sprintf failed */
      return -1;
    }

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
  rseq_t* rseq = malloc(sizeof(rseq_t));
  PANIC_MEM(rseq, stderr);

  ret_code = set_header(rseq, kseq);
  PANIC_UNLESS(ret_code == 0,
               STD_ERR,
               stderr, "set_header failed");

  rseq->seq = strdup(kseq->seq.s);
  PANIC_MEM(rseq->seq, stderr);

  rseq->seq_len = kseq->seq.l;

  return rseq;
}

void
rseq_destroy(rseq_t* rseq)
{
  free(rseq->head);
  free(rseq->seq);
  free(rseq->key_chars);
  free(rseq);
}

void
rseq_print(FILE* fstream, rseq_t* rseq)
{
  int ret_code = fprintf(fstream,
                         ">%s\n"
                         "%s\n",
                         rseq->head,
                         rseq->seq);
  assert(ret_code >= 0);
}
