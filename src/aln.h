#ifndef ALN_H
#define ALN_H

#include "../vendor/tommyarray.h"

struct aln_ret_val_t {
  tommy_array* infiles;
  tommy_array* outfiles;

  int ret_code;
};

struct aln_arg_t {
  tommy_array* ref_seqs;
  tommy_array* query_seqs;

  char* tmp_dir;
  char* out_basename;
  char* query_fname;

  char* aligner;
  char* prefs;
  char* io_fmt_str;

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
             char* out_basename,
             char* query_fname,
             char* aligner,
             char* prefs,
             char* io_fmt_str);

/* char** */
/* make_aligner_opts(char* aligner, */
/*                   char* aln_infile, */
/*                   char* aln_outfile, */
/*                   char* opt_string); */


void*
run_aln(void* the_arg);

#endif
