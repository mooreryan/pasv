/* TODO if there is a lower case letter at the position, it will be a
   different type */

#include <assert.h>
#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

#include "../vendor/tommyarray.h"

#include "aln.h"
#include "err_codes.h"
#include "rseq.h"

struct rseq_t*
get_aln_posns(char* aln_outfile,
              int num_ref_seqs,
              int num_key_posns,
              int* key_posns,
              int region_start,
              int region_end)
{

  int l = 0;
  int aln_i = 0;
  int key_posn_i = 0;
  int seq_i = -1;

  int ref_posn = -1;

  int aln_region_start = 0;
  int aln_region_end = 0;
  int aln_key_posns[num_key_posns];

  int spans_start = 0;
  int spans_end = 0;
  int spans_region = 0;

  gzFile seq_f;
  kseq_t* seq;
  rseq_t* rseq;

  char* key_chars;

  seq_f = gzopen(aln_outfile, "r");
  PANIC_IF(seq_f == NULL,
           FILE_ERR,
           stderr, FILE_ERR_MSG, aln_outfile, "reading");

  seq = kseq_init(seq_f);
  PANIC_IF(seq == NULL,
           KSEQ_ERR,
           stderr, KSEQ_ERR_MSG, aln_outfile);

  key_chars = malloc(sizeof *key_chars * (num_key_posns+1));
  PANIC_MEM(key_chars, stderr);

  while ((l = kseq_read(seq)) >= 0) {
    ++seq_i;
    if (seq_i == 0) { /* this seq has the key positions */
      for (aln_i = 0; aln_i < seq->seq.l; ++aln_i) {
        if (seq->seq.s[aln_i] != '-') {
          ++ref_posn;

          if (ref_posn == region_start) {
            aln_region_start = aln_i;
          }

          if (ref_posn == region_end) {
            aln_region_end = aln_i;
          }

          for (key_posn_i = 0; key_posn_i < num_key_posns; ++key_posn_i) {
            if (ref_posn == key_posns[key_posn_i]) {
              aln_key_posns[key_posn_i] = aln_i;
            }
          }
        }
      }
    } else if (seq_i == num_ref_seqs) { /* the query */
      int zz = 0;
      for (zz = 0; zz < num_key_posns; ++zz) {
        key_chars[zz] = seq->seq.s[aln_key_posns[zz]];
      }
      key_chars[zz] = '\0';

      /* note, this seq is aligned */
      if (region_start >= 0 && region_end >= region_start) {
        for(zz = 0; zz < seq->seq.l; ++zz) {
          if (zz <= region_start && seq->seq.s[zz] != '-') {
            spans_start = 1;
          }

          if (zz >= region_end && seq->seq.s[zz] != '-') {
            spans_end = 1;
            break;
          }
        }

        if (spans_start && spans_end) {
          spans_region = 1;
        } else {
          spans_region = 0;
        }
      } else {
        spans_region = -1;
      }

      rseq = rseq_init(seq);
      rseq->key_chars = key_chars;
      rseq->spans_region = spans_region;
    }
  }

  gzclose(seq_f);
  kseq_destroy(seq);

  return rseq;
}

int
main(int argc, char *argv[])
{
  int c = 0;
  char* opt_threads = NULL;
  char* opt_refs = NULL;
  char* opt_queries = NULL;
  char* opt_region_start = NULL;
  char* opt_region_end = NULL;
  char* opt_tmp_dir = NULL;

  char* query_fname = NULL;

  static char intro[] =
    "Trust the Process. Trust the PVCpipe.";
  static char usage[] =
    "[-s region_start] [-e region_end] -d tmp_dir -t num_threads -r ref_seqs -q query_seqs pos1 [pos2 ...]";
  static char options[] =
    "-t <integer> Number of threads to use\n"
    "-r <string>  Fasta file with reference sequences\n"
    "-q <string>  Fasta file with query sequences\n"
    "-s <integer> Region start to check for spanning (deault: -1)\n"
    "-e <integer> Region end to check for spanning (deault: -1)\n"
    "-d <string>  Directory for the tmp files. Create this before running the program.\n";


  char doc_str[2000];
  snprintf(doc_str,
           1999,
          "\n\n%s\n\nusage: %s %s\n\noptions:\n%s\n\n",
          intro,
          argv[0],
          usage,
          options);

  while ((c = getopt(argc, argv, "ht:r:q:s:e:d:")) != -1) {
    switch(c) {
    case 'h':
      fprintf(stderr, "%s", doc_str);
      exit(1);
    case 't':
      opt_threads = optarg;
      break;
    case 'r':
      opt_refs = optarg;
      break;
    case 'q':
      opt_queries = optarg;
      break;
    case 's':
      opt_region_start = optarg;
      break;
    case 'e':
      opt_region_end = optarg;
      break;
    case 'd':
      opt_tmp_dir = optarg;
      break;
    case '?':
      exit(1);
    default:
      exit(1);
    }
  }

  if (opt_refs == NULL) {
    fprintf(stderr, "ARG ERROR -- Missing -r arg\n%s\n", doc_str);
    exit(1);
  }

  if (opt_queries == NULL) {
    fprintf(stderr, "ARG ERROR -- Missing -q arg\n%s\n", doc_str);
    exit(1);
  }

  if (opt_tmp_dir == NULL) {
    fprintf(stderr, "ARG ERROR -- Missing -d arg\n%s\n", doc_str);
    exit(1);
  }

  PANIC_UNLESS(mkdir(opt_tmp_dir, 0755) == 0,
               errno,
               stderr,
               "Error running mkdir(%s): %s\n",
               opt_tmp_dir,
               strerror(errno));

  int num_threads = 0;
  if (opt_threads == NULL) {
    num_threads = 1;
  } else {
    num_threads = strtol(opt_threads, NULL, 10);
  }

  if (opt_region_start != NULL && opt_region_end == NULL) {
    fprintf(stderr, "ARG ERROR -- got -s but no -e\n");
    exit(1);
  }
  if (opt_region_start == NULL && opt_region_end != NULL) {
    fprintf(stderr, "ARG ERROR -- got -e but no -s\n");
    exit(1);
  }

  int region_start = 0;
  if (opt_region_start == NULL) {
    region_start = -1;
  } else {
    region_start = strtol(opt_region_start, NULL, 10);
  }

  int region_end = 0;
  if (opt_region_end == NULL) {
    region_end = -1;
  } else {
    region_end = strtol(opt_region_end, NULL, 10);
  }

  gzFile ref_fp = gzopen(opt_refs, "r");
  if (ref_fp == NULL) {
    fprintf(stderr, "FATAL -- Could not open '%s'\n", opt_refs);
    exit(1);
  }
  gzFile query_fp = gzopen(opt_queries, "r");
  if (query_fp == NULL) {
    fprintf(stderr, "FATAL -- Could not open '%s'\n", opt_queries);
    exit(1);
  }

  /* TODO can save a few bytes by removing the parsed args */
  int key_posns[argc];
  int opt_i = 0;
  int num_key_posns = 0;
  if (optind == argc) {
    fprintf(stderr, "FATAL -- no positions given\n");
    exit(1);
  }

  for (opt_i = optind; opt_i < argc; ++opt_i) {
    key_posns[num_key_posns++] = strtol(argv[opt_i], NULL, 10) - 1;
  }

  kseq_t* ref_seq;
  kseq_t* query_seq;
  int l = 0;
  int i = 0;

  ref_seq = kseq_init(ref_fp);
  query_seq = kseq_init(query_fp);

  pthread_t threads[num_threads];

  struct aln_ret_val_t* ret_val;
  tommy_array* ret_vals = malloc(sizeof *ret_vals);
  PANIC_MEM(ret_vals, stderr);
  tommy_array_init(ret_vals);

  tommy_array* outfiles = malloc(sizeof *outfiles);
  PANIC_MEM(outfiles, stderr);
  tommy_array_init(outfiles);

  tommy_array* ref_seqs = malloc(sizeof *ref_seqs);
  PANIC_MEM(ref_seqs, stderr);
  tommy_array_init(ref_seqs);

  tommy_array* query_seqs = malloc(sizeof *query_seqs);
  PANIC_MEM(query_seqs, stderr);
  tommy_array_init(query_seqs);

  struct aln_arg_t** aln_args = malloc(sizeof *aln_args * num_threads);
  PANIC_MEM(aln_args, stderr);

  while ((l = kseq_read(ref_seq)) >= 0) {
    tommy_array_insert(ref_seqs, strdup(ref_seq->seq.s));
  }

  while ((l = kseq_read(query_seq)) >= 0) {
    tommy_array_insert(query_seqs, strdup(query_seq->seq.s));
  }

  for (i = 0; i < num_threads; ++i) {
    aln_args[i] = aln_arg_init(ref_seqs,
                               query_seqs,
                               i,
                               num_threads,
                               opt_tmp_dir,
                               query_fname);

    if (pthread_create(&threads[i],
                       NULL,
                       run_aln,
                       aln_args[i])) {
      fprintf(stderr, "FATAL -- could not create thread %d\n", i);
    } else {
      fprintf(stderr, "DEBUG -- spawning thread %d\n", i);
    }
  }

  for (i = 0; i < num_threads; ++i) {
    pthread_join(threads[i], (void**)&ret_val);

    if (ret_val->ret_code != 0) {
      fprintf(stderr,
              "FATAL -- something went wrong with thread %d (%d)\n",
              i,
              ret_val->ret_code);
    } else {
      tommy_array_insert(ret_vals, ret_val);
    }
  }

  /* get all the outfiles */
  for (int i = 0; i < tommy_array_size(ret_vals); ++i) {
    ret_val = tommy_array_get(ret_vals, i);
    for (int j = 0; j < tommy_array_size(ret_val->outfiles); ++j) {
      tommy_array_insert(outfiles, tommy_array_get(ret_val->outfiles, j));
    }
  }

  /* there will be an outfile for each query */
  struct rseq_t* rseq = NULL;

  /* TODO need to assert that there are not more input posns than size
     of these char* */
  char spans[10];
  char type[20];
  fprintf(stdout, "name type spans oligo");
  for (int n = 0; n < num_key_posns; ++n) {
    fprintf(stdout, " pos.%d", key_posns[n]);
  }
  fprintf(stdout, "\n");
  int num_ref_seqs = tommy_array_size(ref_seqs);
  for (int i = 0; i < tommy_array_size(outfiles); ++i) {
    rseq = get_aln_posns(tommy_array_get(outfiles, i),
                         num_ref_seqs,
                         num_key_posns,
                         key_posns,
                         region_start,
                         region_end);

    switch(rseq->spans_region) {
    case -1:
      snprintf(spans, 9, "NA");
      break;
    case 0:
      snprintf(spans, 9, "No");
      break;
    case 1:
      snprintf(spans, 9, "Yes");
      break;
    default:
      assert(0);
    }

    if (rseq->spans_region == -1) {
      snprintf(type, 19, "%s", rseq->key_chars);
    } else {
      snprintf(type, 19, "%s_%s", rseq->key_chars, spans);
    }

    fprintf(stdout,
            "%s %s %s %s",
            rseq->head,
            type,
            spans,
            rseq->key_chars);

    for (int z = 0; z < num_key_posns; ++z) {
      fprintf(stdout, " %c", rseq->key_chars[z]);
    }
    fprintf(stdout, "\n");
    rseq_destroy(rseq);
  }

  /* Clean up */

  /* TODO clean up outfiles */

  for (int z = 0; z < tommy_array_size(ret_vals); ++z) {
    ret_val = tommy_array_get(ret_vals, z);

    for (int y = 0; y < tommy_array_size(ret_val->outfiles); ++y) {
      free(tommy_array_get(ret_val->outfiles, y));
    }

    tommy_array_done(ret_val->outfiles);
    free(ret_val->outfiles);
    free(ret_val);
  }
  tommy_array_done(ret_vals);
  free(ret_vals);

  tommy_array_done(outfiles);
  free(outfiles);

  for (int z = 0; z < tommy_array_size(ref_seqs); ++z) {
    free(tommy_array_get(ref_seqs, z));
  }

  for (int z = 0; z < tommy_array_size(query_seqs); ++z) {
    free(tommy_array_get(query_seqs, z));
  }

  tommy_array_done(query_seqs);
  free(query_seqs);

  tommy_array_done(ref_seqs);
  free(ref_seqs);

  for (i = 0; i < num_threads; ++i) {
    free(aln_args[i]);
  }
  free(aln_args);

  kseq_destroy(ref_seq);
  kseq_destroy(query_seq);
  gzclose(ref_fp);
  gzclose(query_fp);
  return 0;
}
