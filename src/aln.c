#include <assert.h>
#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "aln.h"
#include "err_codes.h"

/* If str is empty, will return "" in the array */
tommy_array*
tokenize(char* str, char* split_on)
{
  assert(str != NULL);
  assert(split_on != NULL);

  tommy_array* tokens = malloc(sizeof *tokens);
  PANIC_MEM(tokens, stderr);
  tommy_array_init(tokens);

  char* token = NULL;
  char* string = NULL;
  char* tofree = NULL;
  char* tmp = NULL;

  tofree = string = strdup(str);
  PANIC_MEM(string, stderr);

  while ((token = strsep(&string, split_on)) != NULL) {
    tmp = strdup(token);
    PANIC_MEM(tmp, stderr);
    tommy_array_insert(tokens, tmp);
  }

  free(tofree);

  return tokens;
}

/* The char* vals in this array will need to be free'd */
char**
make_aligner_opts(char* aligner,
                  char* aln_infile,
                  char* aln_outfile,
                  char* opt_string)
{

  int i = 0;
  int token_i = 0;
  tommy_array* tokens = NULL;
  int num_tokens = 0;

  tokens = tokenize(opt_string, " ");
  num_tokens = tommy_array_size(tokens);
  char* first_token = tommy_array_get(tokens, 0);

  if (num_tokens == 1 && (strcmp(first_token, "") == 0)) {
    /* Free the first str cos we won't get to it again */
    free(tommy_array_get(tokens, 0));
    num_tokens = 0;
  }

  char* tmp_str = NULL;
  char** aln_argv = NULL;

  if (strncmp("clustalo", aligner, 100) == 0) {
    aln_argv = malloc(sizeof *aln_argv * (1 + 5 + num_tokens));
    PANIC_MEM(aln_argv, stderr);

    tmp_str = strdup("clustalo");
    PANIC_MEM(tmp_str, stderr);
    aln_argv[i++] = tmp_str;

    if (num_tokens > 0) {
      for (token_i = 0; token_i < num_tokens; ++token_i) {
        aln_argv[i + token_i] = tommy_array_get(tokens, token_i);
      }

      i += token_i;
    }

    tmp_str = strdup("-i");
    PANIC_MEM(tmp_str, stderr);
    aln_argv[i++] = tmp_str;

    tmp_str = strdup(aln_infile);
    PANIC_MEM(tmp_str, stderr);
    aln_argv[i++] = tmp_str;

    tmp_str = strdup("-o");
    PANIC_MEM(tmp_str, stderr);
    aln_argv[i++] = tmp_str;

    tmp_str = strdup(aln_outfile);
    PANIC_MEM(tmp_str, stderr);
    aln_argv[i++] = tmp_str;

    aln_argv[i++] = NULL;

    PANIC_UNLESS(i == 1 + 5 + num_tokens,
                 STD_ERR,
                 stderr,
                 "something went wrong, token_i: %d, num_tokens: %d",
                 token_i,
                 num_tokens);
  } else {
    /* TODO handle bad aligner */
  }

  /* TODO this doesn't deallocate the things in the array right? */
  tommy_array_done(tokens);
  free(tokens);

  return aln_argv;
}

struct aln_arg_t*
aln_arg_init(tommy_array* ref_seqs,
             tommy_array* query_seqs,
             int tid,
             int num_workers,
             char* tmp_dir,
             char* query_fname,
             char* aligner,
             char* prefs)
{
  struct aln_arg_t* aln_arg = malloc(sizeof *aln_arg);
  PANIC_MEM(aln_arg, stderr);

  aln_arg->ref_seqs    = ref_seqs;
  aln_arg->query_seqs  = query_seqs;
  aln_arg->tid         = tid;
  aln_arg->num_workers = num_workers;
  aln_arg->tmp_dir     = tmp_dir;
  aln_arg->query_fname = query_fname;
  aln_arg->aligner     = aligner;
  aln_arg->prefs       = prefs;

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

  for (query_i = 0;
       query_i < tommy_array_size(aln_arg->query_seqs);
       ++query_i) {
    /* this seq is for this thread */
    if ((query_i % aln_arg->num_workers) == tid) {

      /* TODO check for file overwriting */
      /* TODO will blow up if path is longer than 999 chars */
      char aln_infile[1000];
      snprintf(aln_infile,
               999,
               "%s/pasv_%d_%d",
               aln_arg->tmp_dir,
               query_i, tid);

      char aln_outfile[1000];
      snprintf(aln_outfile, 999, "%s.aln.fa", aln_infile);

      tommy_array_insert(ret_val->outfiles, strdup(aln_outfile));
      /* TODO drop the force and die if outfiles exist */
      char** aln_argv = make_aligner_opts(aln_arg->aligner,
                                          aln_infile,
                                          aln_outfile,
                                          aln_arg->prefs);
      PANIC_MEM(aln_argv, stderr);

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
        /* TODO gracefully handle aligner failure */
        PANIC_IF(execvp("clustalo", aln_argv) == -1,
                 errno,
                 stderr,
                 "The alignment command failed: %s\n",
                 strerror(errno));
      } else if (pid > 1) { /* parent */
        pid = wait(&status);
        PANIC_IF(pid == -1,
                 errno,
                 stderr,
                 "Error while waiting on child process: %s",
                 strerror(errno));

        /* TODO is this the best place to panic (from inside the
           thread? */
        PANIC_UNLESS_FILE_CAN_BE_READ(stderr, aln_outfile);

        int arg_i = 0;
        for (arg_i = 0; aln_argv[arg_i] != NULL; ++arg_i) {
          free(aln_argv[arg_i]);
        }
        free(aln_argv);
      }
    }
  }

  ret_val->ret_code = 0;
  pthread_exit(ret_val);
}
