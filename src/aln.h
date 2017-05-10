#ifndef ALN_H
#define ALN_H

#include "../vendor/tommyarray.h"

struct aln_ret_val_t {
  tommy_array* outfiles;
  int ret_code;
};

struct aln_arg_t {
  tommy_array* ref_seqs;
  tommy_array* query_seqs;

  char* tmp_dir;
  char* query_fname;

  /* Thread number */
  int tid;
  int num_workers;
};

struct aln_arg_t*
aln_arg_init(tommy_array* ref_seqs,
             tommy_array* query_seqs,
             int tid,
             int num_workers,
             char* tmp_dir,
             char* query_fname);

void*
run_aln(void* the_arg);

#endif
