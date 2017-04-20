#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <zlib.h>
#include "kseq.h"

KSEQ_INIT(gzFile, gzread)

/* Input a kseq, and print it out fastA/Q style */
void
kseq_print(FILE* outf, kseq_t* seq)
{
  if (seq->qual.l) {
    fprintf(outf, "@");
  } else {
    fprintf(outf, ">");
  }

  fprintf(outf, "%s", seq->name.s);

  if (seq->comment.l) {
    fprintf(outf, " %s\n", seq->comment.s);
  } else {
    fprintf(outf, "\n");
  }

  fprintf(outf, "%s\n", seq->seq.s);

  if (seq->qual.l) { fprintf(outf, "+\n%s\n", seq->qual.s); }
}


int main(int argc, char *argv[])
{
  if (argc != 3) {
    fprintf(stderr,
            "USAGE: %s <1: number of splits> <2: seq file>\n",
            argv[0]);

    exit(1);
  }

  long l;
  kseq_t* seq;
  long num_seqs = 0;
  int file_i = 0;
  int num_splits = 0;
  int i = 0;
  char buf[100];
  FILE** outfiles = NULL;


  num_splits = strtol(argv[1], NULL, 10);
  outfiles = malloc(num_splits * sizeof(FILE*));
  assert(outfiles != NULL);

  for (i = 0; i < num_splits; ++i) {
    sprintf(buf, "%s.split_%d", argv[2], i);
    outfiles[i] = fopen(buf, "w");
  }

  gzFile seqs_file = gzopen(argv[2], "r");
  seq = kseq_init(seqs_file);

  while ((l = kseq_read(seq)) >= 0) {
    file_i = num_seqs % num_splits;

    kseq_print(outfiles[file_i], seq);

    if (++num_seqs % 1000 == 0) {
      fprintf(stderr, "LOG -- splitting seq: %lu\r", num_seqs);
    }
  }

  for (i = 0; i < num_splits; ++i) {
    fclose(outfiles[i]);
  }

  gzclose(seqs_file);
  kseq_destroy(seq);
  free(outfiles);

  return 0;
}
