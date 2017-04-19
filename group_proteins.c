/* gcc -c -ansi -g -Wall $(pkg-config --cflags clustalo)
   group_proteins.c && g++ -g -Wall -o group_proteins $(pkg-config
   --libs clustalo) group_proteins.o && time ./group_proteins polA.fa
   queries.fa 762 23 */

#include <assert.h>
#include <stdio.h>
#include "clustal-omega.h"

/* void ReplaceLastSeq(mseq_t **prMSeqDest_p, char *pcSeqName, char *pcSeqRes) */
/* { */
/*   int iSeqIdx = 0; */
/*   SQINFO sqinfo; */

/*   assert(NULL != prMSeqDest_p); */
/*   assert(NULL != pcSeqName); */
/*   assert(NULL != pcSeqRes); */

/*   iSeqIdx = (*prMSeqDest_p)->nseqs-1; */

/*   /\* (*prMSeqDest_p)->seq =  (char **) *\/ */
/*   /\*     CKREALLOC((*prMSeqDest_p)->seq, (iSeqIdx+1) * sizeof(char *)); *\/ */
/*   /\* (*prMSeqDest_p)->orig_seq =  (char **) *\/ */
/*   /\*     CKREALLOC((*prMSeqDest_p)->orig_seq, (iSeqIdx+1) * sizeof(char *)); *\/ */
/*   /\* (*prMSeqDest_p)->sqinfo =  (SQINFO *) *\/ */
/*   /\*     CKREALLOC((*prMSeqDest_p)->sqinfo, (iSeqIdx+1) * sizeof(SQINFO)); *\/ */


/*   (*prMSeqDest_p)->seq[iSeqIdx] = CkStrdup(pcSeqRes); */
/*   (*prMSeqDest_p)->orig_seq[iSeqIdx] = CkStrdup(pcSeqRes); */

/*   /\* TODO the sqinfo part might not be exactly correct... *\/ */

/*   /\* should probably get ri of SqInfo altogether in the long run and just */
/*      transfer the intersting members into our own struct */
/*   *\/ */
/*   sqinfo.flags = 0; /\* init *\/ */

/*   sqinfo.len = strlen(pcSeqRes); */
/*   sqinfo.flags |= SQINFO_LEN; */

/*   /\* name is an array of SQINFO_NAMELEN length *\/ */
/*   strncpy(sqinfo.name, pcSeqName, SQINFO_NAMELEN-1); */
/*   sqinfo.name[SQINFO_NAMELEN-1] = '\0'; */
/*   sqinfo.flags |= SQINFO_NAME; */

/*   SeqinfoCopy(&(*prMSeqDest_p)->sqinfo[iSeqIdx], */
/*               & sqinfo); */

/*   /\* (*prMSeqDest_p)->nseqs++; *\/ */

/*   return; */
/* } */

int
main(int argc, char *argv[])
{
  /* the multiple sequence structure */
  mseq_t *prMSeq_ref = NULL;
  mseq_t *prMSeq_query = NULL;
  /* for openmp: number of threads to use */
  int iThreads = 1;
  /* alignment options to use */
  opts_t rAlnOpts;
  /* an input file */
  char *ref_seqs;
  char *query_seqs;


  /* Must happen first: setup logger */
  LogDefaultSetup(&rLog);

  SetDefaultAlnOpts(&rAlnOpts);

  InitClustalOmega(iThreads);

  /* Get sequence input file name from command line
   */
  if (argc < 4) {
    fprintf(stderr, "USAGE: %s refs.fa queries.fa pos1 pos2 ...\n", argv[0]);
    exit(1);
  }
  ref_seqs = argv[1];
  query_seqs = argv[2];

  int num_posns = argc - 3;


  fprintf(stderr, "argc: %d\n", argc);
  int* posns = malloc(num_posns * sizeof(int));
  int* aln_posns = malloc(num_posns * sizeof(int));
  char* oligotype = malloc((num_posns + 1) * sizeof(char));

  fprintf(stdout,
          "seq oligotype");
  for (int i = 0; i < num_posns; ++i) {
    posns[i] = strtol(argv[i+3], NULL, 10) - 1;
    fprintf(stdout, " aa_at_%s", argv[i+3]);
  }
  fprintf(stdout, "\n");

  /* Read sequence file
   */
  NewMSeq(&prMSeq_query);
  if (ReadSequences(prMSeq_query,     /* mseq_t* multiple seq struct */
                    query_seqs,        /* char* seqfile */
                    SEQTYPE_UNKNOWN, /* iSeqType */
                    SEQTYPE_UNKNOWN, /* iSeqFmt */
                    FALSE,           /* bIsProfile */
                    FALSE,           /* bDealignInputSeqs */
                    INT_MAX,         /* iMaxNumSeq */
                    INT_MAX,         /* iMaxSeqLen */
                    NULL             /* char* pcHMMBatch */
                    )) {
    Log(&rLog, LOG_FATAL, "Reading sequence file '%s' failed", query_seqs);
  }

  /* TODO for some reason, DupMSeq, and AddSeq don't really work when
     trying to add both from the ref read above and the query seqs. so
     just re-read the refs every time */
  for (int q_idx = 0; q_idx < prMSeq_query->nseqs; ++q_idx) {
    NewMSeq(&prMSeq_ref);
    if (ReadSequences(prMSeq_ref,     /* mseq_t* multiple seq struct */
                      ref_seqs,        /* char* seqfile */
                      SEQTYPE_UNKNOWN, /* iSeqType */
                      SEQTYPE_UNKNOWN, /* iSeqFmt */
                      FALSE,           /* bIsProfile */
                      FALSE,           /* bDealignInputSeqs */
                      INT_MAX,         /* iMaxNumSeq */
                      INT_MAX,         /* iMaxSeqLen */
                      NULL             /* char* pcHMMBatch */
                      )) {
      Log(&rLog, LOG_FATAL, "Reading sequence file '%s' failed", ref_seqs);
    }

    AddSeq(&prMSeq_ref,
           prMSeq_query->sqinfo[q_idx].name,
           prMSeq_query->seq[q_idx]);


    prMSeq_ref->seqtype = SEQTYPE_PROTEIN;

    if (Align(prMSeq_ref, NULL, &rAlnOpts)) {
      Log(&rLog, LOG_FATAL, "A fatal error happended during the alignment process");
    }

    assert(prMSeq_ref->aligned);
    int ref_pos = 0;
    for (int i = 0; i < prMSeq_ref->sqinfo[0].len; ++i) {
      if (prMSeq_ref->seq[0][i] != '-') {
        ref_pos++;
        for (int j = 0; j < num_posns; ++j) {
          if (ref_pos == posns[j]) {
            aln_posns[j] = i+1;
          }
        }
      }
    }

    fprintf(stdout,
            "%s",
            prMSeq_ref->sqinfo[prMSeq_ref->nseqs-1].name);

    for (int k = 0; k < num_posns; ++k) {
      oligotype[k] = prMSeq_ref->seq[prMSeq_ref->nseqs-1][aln_posns[k]];
    }
    oligotype[k] = '\0';

    fprintf(stdout,
            " %s",
            oligotype);

    for (int z = 0; z < num_posns; ++z) {
      fprintf(stdout, " %c", oligotype[z]);
    }
    fprintf(stdout,
            "\n");

    FreeMSeq(&prMSeq_ref);
  }


  FreeMSeq(&prMSeq_ref);
  FreeMSeq(&prMSeq_query);

  free(posns);
  free(aln_posns);
  free(oligotype);

  Log(&rLog, LOG_INFO, "Successfull program exit");

  return EXIT_SUCCESS;
}
/***   end of main()   ***/
