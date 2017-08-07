/* TODO if there is a lower case letter at the position, it will be a
   different type */

/* TODO handle non numbers for key posns */

#include <assert.h>
#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

#include "../vendor/tommyarray.h"
#include "../vendor/tommyhashlin.h"

#include "aln.h"
#include "err_codes.h"
#include "rseq.h"
#include "tommy_helper.h"

void
jrseq_print(void* rs)
{
  rseq_t* rseq = rs;

  fprintf(stderr,
          ">%s\n"
          "%s\n",
          rseq->head,
          rseq->seq);
}

typedef struct t2fs_t {
  char* type;
  FILE* fs;

  tommy_node node;
} t2fs_t;

void
t2fs_destroy(t2fs_t* t2fs)
{
  free(t2fs->type);
  fclose(t2fs->fs);
  free(t2fs);
}

int
t2fs_compare(const void* arg, const void* t2fs)
{
  return strcmp((const char*)arg,
                ((const t2fs_t*)t2fs)->type);
}

struct rseq_t*
get_aln_posns(char* aln_outfile,
              int num_ref_seqs,
              int num_key_posns,
              int* key_posns,
              int region_start,
              int region_end,
              tommy_hashlin* id2rseq)
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

  rseq_t* first_ref_seq = NULL;
  rseq_t* query_seq = NULL;

  int first_ref_seq_found = 0;
  int query_seq_found = 0;
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

    /* get the rseq info */
    rseq_t* tmp_rseq = NULL;
    char* seq_id = seq->name.s;
    tmp_rseq = tommy_hashlin_search(id2rseq,
                                    rseq_compare,
                                    seq_id,
                                    tommy_strhash_u32(0, seq_id));

    PANIC_UNLESS(tmp_rseq,
                 STD_ERR,
                 stderr,
                 "Could not find seq '%s' in the id2rseq hash table. If the header shown here looks as though it is missing some of the actual header from the end, your headers are probably longer than what is supported by the aligner.\n",
                 seq_id);

    if (tmp_rseq->first_ref_seq == 1) {
      ++first_ref_seq_found;
      PANIC_IF(first_ref_seq_found > 1,
               STD_ERR,
               stderr,
               "Found more than one key ref seq '%s' in file '%s'\n",
               seq->name.s,
               aln_outfile);

      first_ref_seq = rseq_init(seq);
    }

    if (tmp_rseq->query_seq == 1) {
      ++query_seq_found;

      /* with the naming scheme there should only be one */
      PANIC_IF(query_seq_found > 1,
               STD_ERR,
               stderr,
               "Found more than one pseudo query seq '%s' in file '%s'\n",
               seq->name.s,
               aln_outfile);

      query_seq = rseq_init(seq);
    }
  }

  gzclose(seq_f);
  kseq_destroy(seq);

  /* get aln positions from the first ref seq */
  for (aln_i = 0; aln_i < first_ref_seq->seq_len; ++aln_i) {
    if (first_ref_seq->seq[aln_i] != '-') {
      ++ref_posn;

      if (ref_posn == region_start) {
        aln_region_start = aln_i;
      }

      if (ref_posn == region_end) {
        aln_region_end = aln_i;
      }

      /* TODO optiize this */
      for (key_posn_i = 0; key_posn_i < num_key_posns; ++key_posn_i) {
        if (ref_posn == key_posns[key_posn_i]) {
          aln_key_posns[key_posn_i] = aln_i;
        }
      }
    }
  }
  for (key_posn_i = 0; key_posn_i < num_key_posns; ++key_posn_i) {
    PANIC_IF(key_posns[key_posn_i] >= ref_posn,
             STD_ERR,
             stderr,
             "Key pos %d is greater than length (%d) of seq '%s'",
             key_posns[key_posn_i],
             ref_posn,
             first_ref_seq->head);
  }

  /* TODO assert that there is only 1 query seq in this file */
  int zz = 0;
  for (zz = 0; zz < num_key_posns; ++zz) {
    assert(0 <= zz && zz < num_key_posns);
    assert(0 <= aln_key_posns[zz] && aln_key_posns[zz] < query_seq->seq_len);

    key_chars[zz] = query_seq->seq[aln_key_posns[zz]];
  }
  key_chars[zz] = '\0';

  /* note, this seq is aligned */
  if (region_start >= 0 && region_end >= region_start) {
    for(zz = 0; zz < query_seq->seq_len; ++zz) {
      if (zz <= region_start && query_seq->seq[zz] != '-') {
        spans_start = 1;
      }

      if (zz >= region_end && query_seq->seq[zz] != '-') {
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

  rseq_destroy(first_ref_seq);
  query_seq->key_chars = key_chars;
  query_seq->spans_region = spans_region;

  return query_seq;
}

int
main(int argc, char *argv[])
{
  int ret_code = 0;
  tommy_hashlin* id2rseq = NULL;
  tommy_hashlin* type2fs = NULL;
  t2fs_t* t2fs = NULL;

  int c = 0;
  char* opt_aligner = NULL;
  char* opt_io_fmt_str = NULL;
  char* opt_out_base = NULL;
  char* opt_prefs = NULL;
  char* opt_queries = NULL;
  char* opt_refs = NULL;
  char* opt_region_start = NULL;
  char* opt_region_end = NULL;
  char* opt_threads = NULL;
  char* opt_outdir = NULL;

  char* query_fname = NULL;

  static char version_banner[] =
    "    Version: 0.0.7\n"
    "  Copyright: 2017 Ryan Moore\n"
    "    Contact: moorer@udel.edu\n"
    "    Website: https://github.com/mooreryan/pasv\n"
    "    License: GPLv3\n";

  static char intro[] =
    "Trust the Process. Trust the PASV PVCpipe.";
  static char usage[] =
    "[-a aligner] [-p 'alignment params'] [-i 'I/O format string'] [-s region_start] [-e region_end] [-b output_base_name] [-o alignment_file_dir] [-t num_threads] -r ref_seqs -q query_seqs pos1 [pos2 ...]\n\n"
    "If you are not interested in a spanning region, do not pass -s and -e or pass '-s -1 -e -1'";
  static char options[] =
    "-h           Display help\n\n"

    "-a <string>  Name of alignment program (default: clustal)\n"
    "-p <string>  Parameters to send to alignment program (in quotes). E.g., -p '--iter 10' (default: '')\n"
    "-i <string>  IO format string for alignment program. (default: '-i %s -o %s')\n\n"

    "-o <string>  Output directory (default: pasv_outdir)\n"
    "-b <string>  Output base name (default: 'pasv')\n"

    "-t <integer> Number of threads (default: 1)\n\n"

    "-r <string>  Fasta file with reference sequences\n"
    "-q <string>  Fasta file with query sequences\n\n"

    "-s <integer> Region start to check for spanning (deault: -1)\n"
    "-e <integer> Region end to check for spanning (deault: -1)\n";



  /* TODO base this on actual doc str len */
  char doc_str[10000];
  snprintf(doc_str,
           10000,
           "\n\n%s\n\n%s\n\nusage: %s %s\n\noptions:\n\n%s\n\n",
           intro,
           version_banner,
           argv[0],
           usage,
           options);

  while ((c = getopt(argc, argv, "a:d:e:hi:o:p:q:r:s:t:")) != -1) {
    switch(c) {
    case 'a':
      opt_aligner = optarg;
      break;
    case 'b':
      opt_out_base = optarg;
      break;
    case 'e':
      opt_region_end = optarg;
      break;
    case 'h':
      fprintf(stderr, "%s", doc_str);
      exit(1);
    case 'i':
      opt_io_fmt_str = optarg;
      break;
    case 'o':
      opt_outdir = optarg;
      break;
    case 'p':
      opt_prefs = optarg;
      break;
    case 'q':
      opt_queries = optarg;
      break;
    case 'r':
      opt_refs = optarg;
      break;
    case 's':
      opt_region_start = optarg;
      break;
    case 't':
      opt_threads = optarg;
      break;
    case '?':
      exit(1);
    default:
      exit(1);
    }
  }

  /* Check the getopt args */

  /* TODO check that the aligner is actually on the path */

  PANIC_IF(opt_refs == NULL,
           OPT_ERR,
           stderr,
           "Missing the -r argument. Try %s -h for help.",
           argv[0]);

  PANIC_IF(opt_queries == NULL,
           OPT_ERR,
           stderr,
           "Missing the -q argument. Try %s -h for help.",
           argv[0]);

  if (opt_outdir == NULL) {
    opt_outdir = "pasv_outdir";
  }

  PANIC_UNLESS(mkdir(opt_outdir, 0755) == 0,
               errno,
               stderr,
               "Error running mkdir(%s): %s\n",
               opt_outdir,
               strerror(errno));

  PANIC_UNLESS_FILE_CAN_BE_READ(stderr, opt_refs);
  PANIC_UNLESS_FILE_CAN_BE_READ(stderr, opt_queries);

  if (opt_out_base == NULL) {
    opt_out_base = "pasv";
  }

  if (opt_aligner == NULL) {
    opt_aligner = "clustalo";
  }

  /* TODO use hash table lookup? */
  /* TODO use Guile script as a spec? */
  if (strcmp(opt_aligner, "clustalo") == 0) {
    if (opt_io_fmt_str != NULL) {
      fprintf(stderr, "INFO -- clustalo was selected...ignoring -i option\n");
    }
    opt_io_fmt_str = "-i %s -o %s";


  } else if (strcmp(opt_aligner, "mafft") == 0) {
    if (opt_io_fmt_str != NULL) {
      fprintf(stderr, "INFO -- mafft was selected...ignoring -i option\n");
    }
    opt_io_fmt_str = "--quiet %s > %s";
  } else {
    PANIC_IF(opt_io_fmt_str == NULL,
             OPT_ERR,
             stderr,
             "Aligner '%s' is not included by default. "
             "You can still use it, but you must provide your "
             "own I/O format string.",
             opt_aligner);
  }

  if (opt_prefs == NULL) {
    opt_prefs = "";
  }

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
    /* TODO switch to longs */
    int num = strtol(argv[opt_i], NULL, 10) - 1;
    PANIC_UNLESS(num >= 0,
                 OPT_ERR,
                 stderr,
                 "key positions must be >= 1, got %d\n",
                 num);
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



  rseq_t* tmp_rseq = NULL;

  INIT_HASHLIN(id2rseq);

  /* Parse the ref and query seqs */
  int seq_number = 0;
  while ((l = kseq_read(ref_seq)) >= 0) {

    tmp_rseq = rseq_init(ref_seq);
    PANIC_IF(tmp_rseq == NULL,
             STD_ERR,
             stderr,
             "Couldn't make rseq");

    /* one for the null and 6 for the ref___ */
    int new_head_size = tmp_rseq->head_len + 1 + 6;
    char* new_head = malloc(sizeof *new_head * new_head_size);
    PANIC_MEM(new_head, stderr);
    snprintf(new_head,
             new_head_size,
             "ref___%s",
             tmp_rseq->head);

    free(tmp_rseq->head);
    tmp_rseq->head = new_head;
    tmp_rseq->head_len = new_head_size - 1;

    int new_id_size = tmp_rseq->id_len + 1 + 6;
    char* new_id = malloc(sizeof *new_id * new_id_size);
    PANIC_MEM(new_id, stderr);
    snprintf(new_id,
             new_id_size,
             "ref___%s",
             tmp_rseq->id);

    free(tmp_rseq->id);
    tmp_rseq->id = new_id;
    tmp_rseq->id_len = new_id_size - 1;

    if (seq_number++ == 0) { /* this is the first seq */
      tmp_rseq->first_ref_seq = 1;
    } else {
      tmp_rseq->first_ref_seq = 0;
    }
    tmp_rseq->ref_seq = 1;

    ret_code = rseq_try_insert_hashlin(tmp_rseq, id2rseq);
    if (ret_code == 1) {
      tommy_array_insert(ref_seqs, tmp_rseq);
    } else if (ret_code == 0) {
      rseq_destroy(tmp_rseq);
    } else {
      PANIC_IF(1,
               STD_ERR,
               stderr,
               "Something weird happened...");
    }
  }

  while ((l = kseq_read(query_seq)) >= 0) {
    tmp_rseq = rseq_init(query_seq);
    PANIC_IF(tmp_rseq == NULL,
             STD_ERR,
             stderr,
             "Couldn't make rseq");

    tmp_rseq->query_seq = 1;

    ret_code = rseq_try_insert_hashlin(tmp_rseq, id2rseq);
    if (ret_code == 1) {
      tommy_array_insert(query_seqs, tmp_rseq);
    } else if (ret_code == 0) {
      rseq_destroy(tmp_rseq);
    } else {
      PANIC_IF(1,
               STD_ERR,
               stderr,
               "Should never get here. Something weird happened...");
    }
  }

  for (i = 0; i < num_threads; ++i) {
    aln_args[i] = aln_arg_init(ref_seqs,
                               query_seqs,
                               i,
                               num_threads,
                               opt_outdir,
                               opt_out_base,
                               query_fname,
                               opt_aligner,
                               opt_prefs,
                               opt_io_fmt_str);

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

    fprintf(stderr, "RET CODE: %d\n", ret_val->ret_code);
    /* TODO this check doesn't guard against all alignment failures */
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
      char* outfile = tommy_array_get(ret_val->outfiles, j);
      PANIC_UNLESS_FILE_CAN_BE_READ(stderr, outfile);
      tommy_array_insert(outfiles, outfile);
    }

    /* remove the infiles to the aligner */
    for (int j = 0; j < tommy_array_size(ret_val->infiles); ++j) {
      char* infile = tommy_array_get(ret_val->infiles, j);
      PANIC_UNLESS_FILE_CAN_BE_READ(stderr, infile);

      if (unlink(infile) == -1) {
        fprintf(stderr,
                "WARN -- could not delete tmp file '%s': %s\n",
                infile,
                strerror(errno));
      }
    }
  }

  /* there will be an outfile for each query */
  struct rseq_t* rseq = NULL;

  /* TODO need to assert that there are not more input posns than size
     of these char* */
  char spans[10];
  char type[20];

  char outfname[1000];
  snprintf(outfname,
           1000,
           "%s/%s.type_info.txt",
           opt_outdir,
           opt_out_base);

  PANIC_IF_FILE_CAN_BE_READ(stderr, outfname);

  FILE* outfs = fopen(outfname, "w");

  PANIC_IF(outfs == NULL,
           errno,
           stderr,
           "Could not open '%s': %s",
           outfname,
           strerror(errno));

  INIT_HASHLIN(type2fs);

  fprintf(outfs, "name\ttype\tspans\toligo");
  for (int n = 0; n < num_key_posns; ++n) {
    fprintf(outfs, "\tpos.%d", key_posns[n] + 1);
  }
  fprintf(outfs, "\n");
  int num_ref_seqs = tommy_array_size(ref_seqs);
  for (int i = 0; i < tommy_array_size(outfiles); ++i) {
    rseq = get_aln_posns(tommy_array_get(outfiles, i),
                         num_ref_seqs,
                         num_key_posns,
                         key_posns,
                         region_start,
                         region_end,
                         id2rseq);

    switch(rseq->spans_region) {
    case -1:
      snprintf(spans, 10, "NA");
      break;
    case 0:
      snprintf(spans, 10, "No");
      break;
    case 1:
      snprintf(spans, 10, "Yes");
      break;
    default:
      assert(0);
    }

    if (rseq->spans_region == -1) {
      snprintf(type, 20, "%s", rseq->key_chars);
    } else {
      snprintf(type, 20, "%s_%s", rseq->key_chars, spans);
    }

    /* check if type has a fs */
    /* TODO only hash once */
    t2fs = tommy_hashlin_search(type2fs,
                                t2fs_compare,
                                type,
                                tommy_strhash_u32(0, type));

    if (!t2fs) {
      /* add the fs to the hash */
      char fname[1000];
      /* TODO validate */
      snprintf(fname,
               1000,
               "%s/%s.type_%s.fa",
               opt_outdir,
               opt_out_base,
               type);

      t2fs = malloc(sizeof *t2fs);
      t2fs->type = strdup(type);
      PANIC_MEM(t2fs->type, stderr);
      t2fs->fs = fopen(fname, "w");
      PANIC_IF(t2fs->fs == NULL,
               errno,
               stderr,
               "Could not open '%s' for reading: %s",
               fname,
               strerror(errno));

      tommy_hashlin_insert(type2fs,
                           &t2fs->node,
                           t2fs,
                           tommy_strhash_u32(0, type));
    }

    /* now get the original non-gapped sequence */
    rseq_t* rseq_orig = tommy_hashlin_search(id2rseq,
                                             rseq_compare,
                                             rseq->id,
                                             tommy_strhash_u32(0, rseq->id));
    PANIC_UNLESS(rseq_orig,
                 STD_ERR,
                 stderr,
                 "Could not find original seq for '%s'\n",
                 rseq->head);

    rseq_print(t2fs->fs, rseq_orig);

    fprintf(outfs,
            "%s\t%s\t%s\t%s",
            rseq->head,
            type,
            spans,
            rseq->key_chars);

    for (int z = 0; z < num_key_posns; ++z) {
      fprintf(outfs, "\t%c", rseq->key_chars[z]);
    }
    fprintf(outfs, "\n");
    rseq_destroy(rseq);
  }

  /* Clean up */

  fclose(outfs);

  for (int z = 0; z < tommy_array_size(ret_vals); ++z) {
    ret_val = tommy_array_get(ret_vals, z);

    for (int y = 0; y < tommy_array_size(ret_val->outfiles); ++y) {
      free(tommy_array_get(ret_val->outfiles, y));
    }

    for (int y = 0; y < tommy_array_size(ret_val->infiles); ++y) {
      free(tommy_array_get(ret_val->infiles, y));
    }

    tommy_array_done(ret_val->infiles);
    tommy_array_done(ret_val->outfiles);

    free(ret_val->infiles);
    free(ret_val->outfiles);

    free(ret_val);
  }

  tommy_array_done(ret_vals);
  free(ret_vals);

  tommy_array_done(outfiles);
  free(outfiles);

  for (int z = 0; z < tommy_array_size(ref_seqs); ++z) {
    rseq_destroy(tommy_array_get(ref_seqs, z));
  }

  for (int z = 0; z < tommy_array_size(query_seqs); ++z) {
    rseq_destroy(tommy_array_get(query_seqs, z));
  }

  tommy_array_done(query_seqs);
  free(query_seqs);

  tommy_array_done(ref_seqs);
  free(ref_seqs);

  for (i = 0; i < num_threads; ++i) {
    free(aln_args[i]);
  }
  free(aln_args);

  tommy_hashlin_done(id2rseq);
  free(id2rseq);

  tommy_hashlin_foreach(type2fs, (tommy_foreach_func*)t2fs_destroy);
  tommy_hashlin_done(type2fs);
  free(type2fs);

  kseq_destroy(ref_seq);
  kseq_destroy(query_seq);
  gzclose(ref_fp);
  gzclose(query_fp);
  return 0;
}
