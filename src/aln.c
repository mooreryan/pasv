#include <assert.h>
#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "aln.h"
#include "err_codes.h"
#include "rseq.h"
#include "tommy_helper.h"

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

char*
make_io_str(char* format, char* aln_infile, char* aln_outfile)
{
  /* TODO better string length */
  char* buf = malloc(sizeof *buf * (strlen(format) +
                                    strlen(aln_infile) +
                                    strlen(aln_outfile) +
                                    1));
  PANIC_MEM(buf, stderr);

  /* TODO validate */
  sprintf(buf, format, aln_infile, aln_outfile);

  return buf;
}

/* The char* vals in this array will need to be free'd */
char**
make_aligner_opts(char* aligner,
                  char* aln_infile,
                  char* aln_outfile,
                  char* opt_string,
                  char* io_fmt_str,
                  int*  redirect_flag)
{
  *redirect_flag = 0;

  int i = 0;
  int opt_token_i = 0;
  tommy_array* opt_tokens = NULL;
  int num_opt_tokens = 0;

  int io_token_i = 0;
  tommy_array* io_tokens = NULL;
  int num_io_tokens = 0;

  char* input_str = make_io_str(io_fmt_str,
                                aln_infile,
                                aln_outfile);

  io_tokens = tokenize(input_str, " ");
  free(input_str);
  num_io_tokens = tommy_array_size(io_tokens);
  PANIC_IF(num_io_tokens < 2, /* should at least have the in and out files */
           STD_ERR,
           stderr,
           "Not enough tokens: %d, need at least 2",
           num_io_tokens);

  opt_tokens = tokenize(opt_string, " ");
  num_opt_tokens = tommy_array_size(opt_tokens);
  char* first_opt_token = tommy_array_get(opt_tokens, 0);

  if (num_opt_tokens == 1 && (strcmp(first_opt_token, "") == 0)) {
    /* Free the first str cos we won't get to it again */
    free(tommy_array_get(opt_tokens, 0));
    num_opt_tokens = 0;
  }

  char* tmp_str = NULL;
  char** aln_argv = NULL;

  int size_of_aln_argv = 1 + num_opt_tokens + num_io_tokens + 1;
  aln_argv = malloc(sizeof *aln_argv * size_of_aln_argv);
  PANIC_MEM(aln_argv, stderr);

  tmp_str = strdup(aligner);
  PANIC_MEM(tmp_str, stderr);
  aln_argv[i++] = tmp_str;

  if (num_opt_tokens > 0) {
    for (opt_token_i = 0; opt_token_i < num_opt_tokens; ++opt_token_i) {
      aln_argv[i + opt_token_i] = tommy_array_get(opt_tokens, opt_token_i);
    }

    i += opt_token_i;
  }

  for (io_token_i = 0;
       io_token_i < num_io_tokens;
       ++io_token_i) {
    char* io_token = tommy_array_get(io_tokens, io_token_i);
    if (strcmp(io_token, ">") == 0) {
      *redirect_flag = 1;
      break;
    }
    aln_argv[i + io_token_i] = io_token;
  }

  i += io_token_i;
  aln_argv[i++] = NULL;

  /* TODO take care of this by the option validation */
  if (*redirect_flag == 1) {
    /* free all tokens including and beyond the ">" */
    for (; io_token_i < num_io_tokens; ++io_token_i) {
      free(tommy_array_get(io_tokens, io_token_i));
    }
  }

  /* This actually only holds if there is NO redirect flag */
  /* PANIC_UNLESS(i == size_of_aln_argv, */
  /*              STD_ERR, */
  /*              stderr, */
  /*              "something went wrong, opt_token_i: %d, num_opt_tokens: %d", */
  /*              opt_token_i, */
  /*              num_opt_tokens); */

  /* TODO this doesn't deallocate the things in the array right? */
  tommy_array_done(opt_tokens);
  tommy_array_done(io_tokens);

  free(opt_tokens);
  free(io_tokens);


  /* TODO return a value at the beginning indicating whether or not
     the command writes to standard output */
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
             char* prefs,
             char* io_fmt_str)
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
  aln_arg->io_fmt_str = io_fmt_str;

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

  INIT_ARRAY(ret_val->infiles);
  INIT_ARRAY(ret_val->outfiles);

  int tid = aln_arg->tid;
  int status = 0;
  pid_t pid = 0;
  int query_i = 0;
  int tmp_stdout = 0;
  int redirect_flag[] = { 0 };
  rseq_t* rseq = NULL;

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
               "%s/pasv.q_%d.t_%d",
               aln_arg->tmp_dir,
               query_i, tid);

      char aln_outfile[1000];
      snprintf(aln_outfile, 999, "%s.aln.fa", aln_infile);

      /* TODO validate the strdups */
      tommy_array_insert(ret_val->infiles, strdup(aln_infile));
      tommy_array_insert(ret_val->outfiles, strdup(aln_outfile));

      /* TODO drop the force and die if outfiles exist */
      char** aln_argv = make_aligner_opts(aln_arg->aligner,
                                          aln_infile,
                                          aln_outfile,
                                          aln_arg->prefs,
                                          aln_arg->io_fmt_str,
                                          redirect_flag);
      PANIC_MEM(aln_argv, stderr);

      /* fd = mkstemp(aln_infile); */
      FILE* fp = fopen(aln_infile, "w");
      PANIC_IF(fp == NULL,
               errno,
               stderr,
               "Error opening '%s' for writing: %s",
               aln_infile,
               strerror(errno));

      /* write the ref seqs */
      for (int x = 0; x < tommy_array_size(aln_arg->ref_seqs); ++x) {
        rseq = tommy_array_get(aln_arg->ref_seqs, x);
        rseq_print(fp, rseq);
      }

      /* and the query */
      rseq = tommy_array_get(aln_arg->query_seqs, query_i);
      rseq_print(fp, rseq);
      fclose(fp);

      pid = fork();
      PANIC_IF(pid == -1,
               errno,
               stderr,
               "Error forking: %s",
               strerror(errno));


      if (pid == 0) { /* child */
        /* TODO sometimes, the problem is that all threads will write to
           the same outfile...a fix might be to set this in the child
           only? */
        FILE* outfp = NULL;
        if (*redirect_flag == 1) { /* need to redirect stdout */
          outfp = fopen(aln_outfile, "w");
          PANIC_IF(fp == NULL,
                   errno,
                   stderr,
                   "Error opening '%s' for writing: %s",
                   aln_infile,
                   strerror(errno));

          /* So we can redirect later */
          tmp_stdout = dup(STDOUT_FILENO);
          PANIC_IF(tmp_stdout == -1,
                   errno,
                   stderr,
                   "Error duplicating stdout: %s",
                   strerror(errno));

          PANIC_IF(dup2(fileno(outfp), STDOUT_FILENO) == -1,
                   errno,
                   stderr,
                   "Error redirecting stdout to '%s': %s",
                   aln_outfile,
                   strerror(errno));
          fclose(outfp);
        }

        /* TODO gracefully handle aligner failure */
        PANIC_IF(execvp(aln_arg->aligner, aln_argv) == -1,
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

        int arg_i = 0;
        for (arg_i = 0; aln_argv[arg_i] != NULL; ++arg_i) {
          free(aln_argv[arg_i]);
        }
        free(aln_argv);
      }

      /* WARN sometimes a different thread will still have this set to
         the new fd and not stdout */
      /* if (redirect_flag == 1) { */
      /*   /\* Redirect back to stdout *\/ */
      /*   PANIC_IF(dup2(tmp_stdout, STDOUT_FILENO) == -1, */
      /*            errno, */
      /*            stderr, */
      /*            "Error redirecting back to stdout: %s", */
      /*            strerror(errno)); */
    }
  }

  ret_val->ret_code = 0;
  pthread_exit(ret_val);
}
