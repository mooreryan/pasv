#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "aln.h"
#include "err_codes.h"

struct aln_arg_t*
aln_arg_init(tommy_array* ref_seqs,
             tommy_array* query_seqs,
             int tid,
             int num_workers,
             char* tmp_dir,
             char* query_fname)
{
  struct aln_arg_t* aln_arg = malloc(sizeof *aln_arg);
  PANIC_MEM(aln_arg, stderr);

  aln_arg->ref_seqs    = ref_seqs;
  aln_arg->query_seqs  = query_seqs;
  aln_arg->tid         = tid;
  aln_arg->num_workers = num_workers;
  aln_arg->tmp_dir     = tmp_dir;
  aln_arg->query_fname = query_fname;

  return aln_arg;
}

/* TODO why not use this function? */
/* void */
/* aln_arg_destroy(struct aln_arg_t* aln_arg) */
/* { */
/*   int i = 0; */

/*   for (i = 0; i < aln_arg->num_ref_seqs; ++i ) { */
/*     free(tommy_array_get(aln_arg->ref_seqs, i)); */
/*   } */
/*   tommy_array_done(aln_arg->ref_seqs); */
/*   free(aln_arg->ref_seqs); */

/*   for (i = 0; i < aln_arg->num_query_seqs; ++i ) { */
/*     free(tommy_array_get(aln_arg->query_seqs, i)); */
/*   } */
/*   tommy_array_done(aln_arg->query_seqs); */
/*   free(aln_arg->query_seqs); */

/*   free(aln_arg); */
/* } */

void*
run_aln(void* the_arg)
{
  struct aln_arg_t* aln_arg = the_arg;

  struct aln_ret_val_t* ret_val =
    malloc(sizeof *ret_val);
  PANIC_MEM(ret_val, stderr);

  ret_val->outfiles = malloc(sizeof *ret_val->outfiles);
  PANIC_MEM(ret_val->outfiles, stderr);
  tommy_array_init(ret_val->outfiles);

  int tid = aln_arg->tid;
  int status = 0;
  pid_t pid = 0;
  int query_i = 0;

  for (query_i = 0; query_i < tommy_array_size(aln_arg->query_seqs); ++query_i) {
    if ((query_i % aln_arg->num_workers) == tid) { /* this seq is for this thread */

      /* TODO check for file overwriting */
      /* TODO will blow up if path is longer than 999 chars */
      char aln_infile[1000];
      snprintf(aln_infile, 999, "%s/pasv_%d_%d", aln_arg->tmp_dir, query_i, tid);

      char aln_outfile[1000];
      snprintf(aln_outfile, 999, "%s.aln.fa", aln_infile);

      tommy_array_insert(ret_val->outfiles, strdup(aln_outfile));
      /* TODO drop the force and die if outfiles exist */
      char* aln_argv[] = { "clustalo",
                       "--force",
                       "-i", aln_infile,
                       "-o", aln_outfile,
                       "--iter", "0",
                       NULL };

      /* fd = mkstemp(aln_infile); */
      FILE* fp = fopen(aln_infile, "w");
      PANIC_IF(fp == NULL,
               errno,
               stderr,
               "Error opening '%s': %s",
               aln_infile,
               strerror(errno));

      /* write the ref seqs */
      for (int x = 0; x < tommy_array_size(aln_arg->ref_seqs); ++x) {
        fprintf(fp,
                ">ref_%d thread_%d\n%s\n",
                x,
                tid,
                tommy_array_get(aln_arg->ref_seqs, x));
      }

      /* and the query */
      fprintf(fp,
              ">query_%d thread_%d\n%s\n",
              query_i,
              tid,
              tommy_array_get(aln_arg->query_seqs, query_i));
      fclose(fp);

      pid = fork();
      PANIC_IF(pid == -1,
               errno,
               stderr,
               "Error forking: %s",
               strerror(errno));

      if (pid == 0) { /* child */
        execvp("clustalo", aln_argv);
      } else if (pid > 1) { /* parent */
        pid = wait(&status);
        PANIC_IF(pid == -1,
                 errno,
                 stderr,
                 "Error while waiting on child process: %s",
                 strerror(errno));
      }
    }
  }

  ret_val->ret_code = 0;
  pthread_exit(ret_val);
}
