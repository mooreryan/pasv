/* TODO if there is a lower case letter at the position, it will be a
   different type */

#include <assert.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>
#include <zlib.h>

#include "../vendor/kseq.h"
#include "../vendor/tommyarray.h"

#define MAX_SEQS 100

KSEQ_INIT(gzFile, gzread)

struct rseq_t {
  char* seq;
  char* name;
  char* key_chars;

  int seq_len;
  int name_len;
  int spans_region;
};

void
rseq_destroy(struct rseq_t* rseq)
{
  free(rseq->seq);
  free(rseq->name);
  free(rseq->key_chars);

  free(rseq);
}

struct rseq_t*
get_aln_posns(char* aln_outfile,
              int num_ref_seqs,
              int num_key_posns,
              int* key_posns,
              int region_start,
              int region_end)
{

  /* char buf[1000]; */
  /* fprintf(stderr, "catting %s\n", aln_outfile); */
  /* sprintf(buf, "cat %s", aln_outfile); */
  /* system(buf); */
  /* fprintf(stderr, "just catted %s\n", aln_outfile); */

  struct rseq_t* rseq = malloc(sizeof(struct rseq_t));
  assert (rseq != NULL);

  gzFile seq_f = gzopen(aln_outfile, "r");
  if (seq_f == NULL) {
    fprintf(stderr, "panic gzopen %s\n", aln_outfile);
    exit(99);
  }
  kseq_t* seq = kseq_init(seq_f);
  if (seq == NULL) {
    fprintf(stderr, "PANIC kseq_init!");
    exit(100);
  }

  int seq_i = -1;
  int l = 0;
  int ref_posn = -1;
  int aln_i = 0;
  int key_posn_i = 0;
  int aln_region_start = 0;
  int aln_region_end = 0;
  int aln_key_posns[num_key_posns];
  char* key_chars = malloc((num_key_posns+1) * sizeof(char));

  int spans_start = 0;
  int spans_end = 0;
  int spans_region = 0;
  assert(key_chars != NULL);

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

      rseq->seq = strdup(seq->seq.s);
      rseq->seq_len = seq->seq.l;
      rseq->name = strdup(seq->name.s);
      rseq->name_len = seq->name.l;
      rseq->key_chars = key_chars;
      rseq->spans_region = spans_region;
    }
  }

  gzclose(seq_f);
  kseq_destroy(seq);

  return rseq;
}

struct arg_t {
  char** ref_seqs;
  char** query_seqs;

  int num_ref_seqs;
  int num_query_seqs;

  /* Thread number */
  int tid;
  int num_workers;
};

struct arg_t*
arg_init(char** ref_seqs, int num_ref_seqs,
         char** query_seqs, int num_query_seqs,
         int tid,
         int num_workers)
{
  struct arg_t* arg = malloc(sizeof(struct arg_t));
  assert(arg != NULL);

  arg->ref_seqs = ref_seqs;
  arg->query_seqs = query_seqs;
  arg->num_ref_seqs = num_ref_seqs;
  arg->num_query_seqs = num_query_seqs;
  arg->tid = tid;
  arg->num_workers = num_workers;

  return arg;
}

void
arg_destroy(struct arg_t* arg)
{
  int i = 0;

  for (i = 0; i < arg->num_ref_seqs; ++i ) {
    free(arg->ref_seqs[i]);
  }
  free(arg->ref_seqs);

  for (i = 0; i < arg->num_query_seqs; ++i ) {
    free(arg->query_seqs[i]);
  }
  free(arg->query_seqs);

  free(arg);
}

struct hello_fork_ret_val_t {
  tommy_array* outfiles;
  int ret_code;
};

void*
hello_fork(void* the_arg)
{


  struct arg_t* arg = the_arg;

  struct hello_fork_ret_val_t* ret_val = malloc(sizeof(struct hello_fork_ret_val_t));
  assert(ret_val != NULL);

  ret_val->outfiles = malloc(sizeof(tommy_array));
  tommy_array_init(ret_val->outfiles);

  int tid = arg->tid;
  int status = 0;
  pid_t pid = 0;

  for (int y = 0; y < arg->num_query_seqs; ++y) {
    if ((y % arg->num_workers) == tid) { /* this seq is for this thread */
      char aln_infile[32];
      sprintf(aln_infile, "tmpf_%d_%d", y, tid);

      char aln_outfile[32];
      sprintf(aln_outfile, "%s_out", aln_infile);

      tommy_array_insert(ret_val->outfiles, strdup(aln_outfile));
      char* argv[] = { "clustalo",
                       "-i", aln_infile,
                       "-o", aln_outfile,
                       "--iter", "0",
                       NULL };

      /* fd = mkstemp(aln_infile); */
      FILE* fp = fopen(aln_infile, "w");
      if (fp == NULL) {
        fprintf(stderr, "FATAL -- couldn't open '%s' for writing\n", aln_infile);
      }

      /* dprintf(fd, "\n\n\n\nQUERY: %d, THREAD: %d\n", y, tid); */
      /* write the ref seqs */
      for (int x = 0; x < arg->num_ref_seqs; ++x) {
        fprintf(fp, ">ref_%d thread_%d\n%s\n", x, tid, arg->ref_seqs[x]);
      }

      /* and the query */
      fprintf(fp, ">query_%d thread_%d\n%s\n", y, tid, arg->query_seqs[y]);
      fclose(fp);

      pid = fork();
      if (pid == -1) {
        continue;
        /* return (void*)(intptr_t)1; */
      } else if (pid == 0) { /* child */
        execvp("clustalo", argv);
      } else if (pid > 1) { /* parent */
        /* TODO the child processes are possibly leaking memory from the
           pthread_create call in the main function according to
           valgrind */
        pid = wait(&status);

        if (!WIFEXITED(status)) { /* if child did not terminate normally */
          exit(98);
          /* fprintf(stderr, "FATAL -- The child did not terminate normally!\n"); */
          /* return (void*)(intptr_t)2; */
        }
        /* TODO ensure file is unlinked? */
        /* unlink(aln_infile); */
        /* return (void*)(intptr_t)0; */
        /* ret_val->ret_code = 0; */
        /* ret_val; */

      } else { /* something went wrong */
        continue;
        /* return (void*)(intptr_t)3; */
      }
      /* get_aln_posns(aln_outfile); */
    }
  }

  ret_val->ret_code = 0;
  pthread_exit(ret_val);
}
/* if (pid == -1) {  */


int
main(int argc, char *argv[])
{
  int c = 0;
  char* opt_threads = NULL;
  char* opt_refs = NULL;
  char* opt_queries = NULL;
  char* opt_region_start = NULL;
  char* opt_region_end = NULL;

  static char intro[] =
    "Trust the Process. Trust the PVCpipe.";
  static char usage[] =
    "[-s region_start] [-e region_end] -t num_threads -r ref_seqs -q query_seqs pos1 [pos2 ...]";
  static char options[] =
    "-t <integer> Number of threads to use\n"
    "-r <string>  Fasta file with reference sequences\n"
    "-q <string>  Fasta file with query sequences\n"
    "-s <integer> Region start to check for spanning (deault: -1)\n"
    "-e <integer> Region end to check for spanning (deault: -1)\n";


  char doc_str[2000];
  sprintf(doc_str,
          "\n\n%s\n\nusage: %s %s\n\noptions:\n%s\n\n",
          intro,
          argv[0],
          usage,
          options);

  while ((c = getopt(argc, argv, "ht:r:q:s:e:")) != -1) {
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

  struct hello_fork_ret_val_t* ret_val;
  tommy_array* ret_vals = malloc(sizeof(tommy_array));
  tommy_array_init(ret_vals);

  tommy_array* outfiles = malloc(sizeof(tommy_array));
  tommy_array_init(outfiles);

  char** ref_seqs = malloc(MAX_SEQS * sizeof(char*));
  assert(ref_seqs != NULL);

  char** query_seqs = malloc(MAX_SEQS * sizeof(char*));
  assert(query_seqs != NULL);

  struct arg_t** args = malloc(num_threads * sizeof(struct arg_t*));
  assert(args != NULL);

  int num_ref_seqs = 0;
  while ((l = kseq_read(ref_seq)) >= 0) {
    ref_seqs[num_ref_seqs++] = strdup(ref_seq->seq.s);
  }

  int num_query_seqs = 0;
  while ((l = kseq_read(query_seq)) >= 0) {
    query_seqs[num_query_seqs++] = strdup(query_seq->seq.s);
  }

  for (i = 0; i < num_threads; ++i) {
    args[i] = arg_init(ref_seqs, num_ref_seqs,
                       query_seqs, num_query_seqs,
                       i,
                       num_threads);

    if (pthread_create(&threads[i],
                       NULL,
                       hello_fork,
                       args[i])) {
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
  char spans[10];
  char type[20];
  fprintf(stdout, "name type spans oligo");
  for (int n = 0; n < num_key_posns; ++n) {
    fprintf(stdout, " pos.%d", key_posns[n]);
  }
  fprintf(stdout, "\n");
  for (int i = 0; i < tommy_array_size(outfiles); ++i) {
    rseq = get_aln_posns(tommy_array_get(outfiles, i),
                         num_ref_seqs,
                         num_key_posns,
                         key_posns,
                         region_start,
                         region_end);

    switch(rseq->spans_region) {
    case -1:
      sprintf(spans, "NA");
      break;
    case 0:
      sprintf(spans, "No");
      break;
    case 1:
      sprintf(spans, "Yes");
      break;
    default:
      assert(0);
    }

    if (rseq->spans_region == -1) {
      sprintf(type, "%s", rseq->key_chars);
    } else {
      sprintf(type, "%s_%s", rseq->key_chars, spans);
    }

    fprintf(stdout,
            "%s %s %s %s",
            rseq->name,
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

  fprintf(stderr, "DEBUG -- num_ref_seqs: %d\n", num_ref_seqs);
  for (int z = 0; z < num_ref_seqs; ++z) {
    free(ref_seqs[z]);
  }

  fprintf(stderr, "DEBUG -- num_query_seqs: %d\n", num_query_seqs);
  for (int z = 0; z < num_query_seqs; ++z) {
    free(query_seqs[z]);
  }

  free(query_seqs);
  free(ref_seqs);

  for (i = 0; i < num_threads; ++i) {
    free(args[i]);
  }
  free(args);

  kseq_destroy(ref_seq);
  kseq_destroy(query_seq);
  gzclose(ref_fp);
  gzclose(query_fp);
  return 0;
}
