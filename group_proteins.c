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
spans_region_p(int region_start,
               int region_end,
               int aln_region_start,
               int aln_region_end,
               int cur_query_i,
               mseq_t* references)
{
  /* does the query span the region? */
  int spans_start = 0;
  int spans_end = 0;
  int spans_region = 0;
  int aln_i = 0;
  char cur_char = 0;

  if (region_start >= 0 && region_end >= region_start) {
    for (aln_i = 0;
         aln_i < references->sqinfo[cur_query_i].len;
         ++aln_i) {

      cur_char = references->seq[cur_query_i][aln_i];

      if (aln_i <= aln_region_start && cur_char != '-') {
        spans_start = 1;
      }

      if (aln_i >= aln_region_end && cur_char != '-') {
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

  return spans_region;
}

void
set_key_aln_posns(int region_start,
                  int region_end,
                  int* aln_region_start,
                  int* aln_region_end,
                  int num_key_posns,
                  int* key_posns,
                  int* aln_key_posns,
                  mseq_t* references)
{
  assert(references->aligned);
  int ref_posn = -1;
  int aln_i = 0;
  int key_posn_i = 0;

  /* Convert key_posns to their respective positions in this
     alignment. */
  for (aln_i = 0; aln_i < references->sqinfo[0].len; ++aln_i) {
    if (references->seq[0][aln_i] != '-') {
      ++ref_posn;

      if (ref_posn == region_start) {
        aln_region_start[0] = aln_i;
      }

      if (ref_posn == region_end) {
        aln_region_end[0] = aln_i;
      }

      for (key_posn_i = 0; key_posn_i < num_key_posns; ++key_posn_i) {
        if (ref_posn == key_posns[key_posn_i]) {
          aln_key_posns[key_posn_i] = aln_i;
        }
      }
    }
  }
}

void
print_protein_group_info(int spans_region,
                         int num_key_posns,
                         int* aln_key_posns,
                         int cur_query_i,
                         mseq_t* references)
{
  char* group = malloc((num_key_posns + 1) * sizeof(char));
  assert(group != NULL);

  /* enough space for yes_ appended */
  char* type =  malloc((4 + num_key_posns + 1) * sizeof(char));
  assert(group != NULL);

  int key_posn_i = 0;

  /* Print out the protein group info. */
  fprintf(stdout,
          "%s",
          /* the current query sequence */
          references->sqinfo[cur_query_i].name);


  /* build the oligotype */
  for (key_posn_i = 0; key_posn_i < num_key_posns; ++key_posn_i) {
    group[key_posn_i] =
      references->seq[cur_query_i][aln_key_posns[key_posn_i]];
  }
  group[num_key_posns] = '\0';

  if (spans_region == 1) {
    sprintf(type, " %s_yes", group);
    fprintf(stdout, "%s yes", type);
  } else if (spans_region == 0) {
    sprintf(type, " %s_no", group);
    fprintf(stdout, "%s no", type);
  } else {
    sprintf(type, " %s", group);
    fprintf(stdout, "%s na", type);
  }

  fprintf(stdout, " %s", group);

  for (key_posn_i = 0; key_posn_i < num_key_posns; ++key_posn_i) {
    fprintf(stdout, " %c", group[key_posn_i]);
  }
  fprintf(stdout, "\n");

  /* if (WriteAlignment(references, NULL, MSAFILE_A2M, 70, FALSE)) { */
  /*     Log(&rLog, LOG_FATAL, "Could not save alignment"); */
  /* } */

  free(group);
  free(type);
}

int
main(int argc, char *argv[])
{
  opts_t rAlnOpts;

  mseq_t* references = NULL;
  mseq_t* queries = NULL;

  char* refs_fname;
  char* queries_fname;

  int openmp_threads = 1;
  int posn_argv_offset = 0;

  /* loop indices */
  int cur_query_i = 0;
  int key_posn_i = 0;
  int q_i = 0; /* query idx */

  LogDefaultSetup(&rLog);
  /* rLog.iLogLevelEnabled = LOG_DEBUG; */

  SetDefaultAlnOpts(&rAlnOpts);

  InitClustalOmega(openmp_threads);

  /* Get sequence input file name from command line
   */
  int num_required_args = 4;
  if (argc < num_required_args + 1) {
    Log(&rLog,
        LOG_FATAL,
        "\nUsage: %s "
        "<1: refs.fa> "
        "<2: queries.fa> "
        "<3: region start (1-based position)> "
        "<4: region end (1-based position)> "
        "pos1 pos2 ... posN\n",
        argv[0]);
  }

  refs_fname = argv[1];
  queries_fname = argv[2];
  int region_start = strtol(argv[3], NULL, 10) - 1;
  int region_end  = strtol(argv[4], NULL, 10) - 1;

  if (region_end < region_start) {
    Log(&rLog,
        LOG_FATAL,
        "region end (%d) cannot be less than region start (%d)",
        region_end + 1,
        region_start + 1);
  }

  int aln_region_start = 0;
  int aln_region_end = 0;

  int spans_region = 0;

  int num_key_posns = argc - num_required_args - 1;

  int* key_posns = malloc(num_key_posns * sizeof(int));
  if (key_posns == NULL) {
    Log(&rLog, LOG_FATAL, "Memory error allocating for key_posns");
  }
  int* aln_key_posns = malloc(num_key_posns * sizeof(int));
  if (aln_key_posns == NULL) {
    Log(&rLog, LOG_FATAL, "Memory error allocating for aln_key_posns");
  }

  fprintf(stdout, "seq type spans_region group");
  posn_argv_offset = num_required_args + 1;
  for (key_posn_i = 0; key_posn_i < num_key_posns; ++key_posn_i) {
    key_posns[key_posn_i] =
      strtol(argv[key_posn_i + posn_argv_offset], NULL, 10) - 1;

    if (key_posns[key_posn_i] < 1) {
      Log(&rLog,
          LOG_FATAL,
          "key position #%d (%d) must be 1 or greater",
          key_posn_i,
          key_posns[key_posn_i] + 1);
    }

    fprintf(stdout, " aa_at_%s", argv[key_posn_i + posn_argv_offset]);
  }
  fprintf(stdout, "\n");

  /* Read the queries. TODO better would be not to have to save all
     these in memory. */
  NewMSeq(&queries);
  if (ReadSequences(queries,         /* mseq_t* multiple seq struct */
                    queries_fname,   /* char* seqfile */
                    SEQTYPE_UNKNOWN, /* iSeqType */
                    SEQTYPE_UNKNOWN, /* iSeqFmt */
                    FALSE,           /* bIsProfile */
                    FALSE,           /* bDealignInputSeqs */
                    INT_MAX,         /* iMaxNumSeq */
                    INT_MAX,         /* iMaxSeqLen */
                    NULL             /* char* pcHMMBatch */
                    )) {
    Log(&rLog,
        LOG_FATAL,
        "Reading sequence file '%s' failed",
        queries_fname);
  }

  /* TODO for some reason, DupMSeq, and AddSeq don't really work when
     trying to add both from the ref read above and the query seqs. so
     just re-read the refs every time */
  for (q_i = 0; q_i < queries->nseqs; ++q_i) {
    NewMSeq(&references);
    if (ReadSequences(references,     /* mseq_t* multiple seq struct */
                      refs_fname,        /* char* seqfile */
                      SEQTYPE_UNKNOWN, /* iSeqType */
                      SEQTYPE_UNKNOWN, /* iSeqFmt */
                      FALSE,           /* bIsProfile */
                      FALSE,           /* bDealignInputSeqs */
                      INT_MAX,         /* iMaxNumSeq */
                      INT_MAX,         /* iMaxSeqLen */
                      NULL             /* char* pcHMMBatch */
                      )) {
      Log(&rLog,
          LOG_FATAL,
          "Reading sequence file '%s' failed",
          refs_fname);
    }

    AddSeq(&references,
           queries->sqinfo[q_i].name,
           queries->seq[q_i]);


    /* TODO not 100% sure why this needs to be reset. I think it is in
       AddSeq. */
    references->seqtype = SEQTYPE_PROTEIN;

    if (Align(references, NULL, &rAlnOpts)) {
      Log(&rLog,
          LOG_FATAL,
          "A fatal error happended during the alignment process");
    }

    /* convert key posistions to their respective positions in this
       alignment */
    set_key_aln_posns(region_start,
                      region_end,
                      &aln_region_start,
                      &aln_region_end,
                      num_key_posns,
                      key_posns,
                      aln_key_posns,
                      references);

    cur_query_i = references->nseqs - 1;
    spans_region = spans_region_p(region_start,
                                  region_end,
                                  aln_region_start,
                                  aln_region_end,
                                  cur_query_i,
                                  references);

    print_protein_group_info(spans_region,
                             num_key_posns,
                             aln_key_posns,
                             cur_query_i,
                             references);

    FreeMSeq(&references);
  }


  FreeMSeq(&references);
  FreeMSeq(&queries);

  free(key_posns);
  free(aln_key_posns);

  return EXIT_SUCCESS;
}
