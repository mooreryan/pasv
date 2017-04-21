#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <zlib.h>
#include "../vendor/kseq.h"
#include "../vendor/tommyhashlin.h"

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

struct kv_t {
  tommy_node node;

  char* key;
  int val;
};

int
kv_compare(const void* arg, const void* kv)
{
  return strcmp((const char*)arg,
                ((const struct kv_t*)kv)->key);
}

struct kv_t*
kv_new(char* key, int val)
{
  struct kv_t* kv = malloc(sizeof(struct kv_t));
  assert(kv != NULL);

  kv->key = strdup(key);
  kv->val = val;
  return kv;
}

void
kv_destroy(struct kv_t* kv)
{
  free(kv->key);
  free(kv);
}


struct type_info_t {
  tommy_node node;

  char* type;
  int count;
  int idx;
};

struct type_info_t*
type_info_new()
{
  struct type_info_t* type_info = malloc(sizeof(struct type_info_t));
  assert(type_info != NULL);

  return type_info;
}

void
type_info_destroy(struct type_info_t* type_info)
{
  free(type_info->type);
  free(type_info);
}

int
type_info_compare(const void* arg, const void* type_info)
{
  return strcmp((const char*)arg,
                ((const struct type_info_t*)type_info)->type);
}

tommy_hashlin*
r_tommy_hashlin_new()
{
  tommy_hashlin* hashlin = malloc(sizeof(tommy_hashlin));
  assert(hashlin != NULL);
  tommy_hashlin_init(hashlin);

  return hashlin;
}



int main(int argc, char *argv[])
{
  if (argc < 3) {
    fprintf(stderr,
            "USAGE: %s "
            "<1: seq file> *.types\n",
            argv[0]);

    exit(1);
  }

  int num_types_files = argc - 2;
  FILE** types_files = malloc(num_types_files * sizeof(FILE*));
  assert(types_files != NULL);

  for (int i = 0; i < num_types_files; ++i) {
    types_files[i] = fopen(argv[i + 2], "r");
  }

  long l;
  kseq_t* seq;
  long num_seqs = 0;
  int num_types = 0;
  char* buf = malloc(1000 * sizeof(char));
  assert(buf != NULL);

  /* char* header = malloc(1000 * sizeof(char)); */
  /* assert(header != NULL); */
  /* char* type = malloc(1000 * sizeof(char)); */
  /* assert(type != NULL); */

  char* line = malloc(1000 * sizeof(char));
  assert(line != NULL);
  char* header;
  char* type;
  char* string;
  char* tofree;

  int file_i = 0;

  tommy_uint32_t hashed_val = 0;

  tommy_hashlin* types = r_tommy_hashlin_new();
  tommy_hashlin* seq_types = r_tommy_hashlin_new();

  struct type_info_t* type_info = NULL;
  struct kv_t* kv = NULL;

  FILE* types_file = fopen(argv[1], "r");
  assert(types_file);

  gzFile seqs_file = gzopen(argv[1], "r");
  assert(seqs_file);

  seq = kseq_init(seqs_file);

  sprintf(buf, "%s.type_map", argv[1]);
  FILE* map_f = fopen(buf, "w");

  for (int i = 0; i < num_types_files; ++i) {
    while (fgets(line, 1000, types_files[i])) {
      tofree = string = strdup(line);
      header = strsep(&string, " ");
      type = strsep(&string, " ");

      if (strcmp(type, "type")) {
        hashed_val = tommy_strhash_u32(0, type);
        type_info = tommy_hashlin_search(types,
                                         type_info_compare,
                                         type,
                                         hashed_val);


        if (type_info) {
          type_info->count++;
        } else {
          type_info = type_info_new();
          type_info->count = 1;
          type_info->idx = num_types++;
          type_info->type = strdup(type);

          fprintf(map_f,
                  "type_%d %s\n",
                  type_info->idx,
                  type_info->type);

          hashed_val = tommy_strhash_u32(0, type_info->type);
          tommy_hashlin_insert(types,
                               &type_info->node,
                               type_info,
                               hashed_val);
        }

        kv = tommy_hashlin_search(seq_types,
                                  kv_compare,
                                  header,
                                  tommy_strhash_u32(0, header));

        if (kv) {
          fprintf(stderr,
                  "ERROR: Header '%s' was seen more than once\n",
                  header);

          exit(1);
        }

        kv = kv_new(header, type_info->idx);
        tommy_hashlin_insert(seq_types,
                             &kv->node,
                             kv,
                             tommy_strhash_u32(0, kv->key));

      }
      free(tofree);
    }
    fclose(types_files[i]);
  }
  free(line);
  fclose(map_f);
  free(types_files);

  FILE** outfiles = malloc(num_types * sizeof(FILE*));
  assert(outfiles != NULL);

  for (int i = 0; i < num_types; ++i) {
    sprintf(buf, "%s.type_%d", argv[1], i);
    outfiles[i] = fopen(buf, "w");
    assert(outfiles[i]);
  }

  while ((l = kseq_read(seq)) >= 0) {
    /* TODO this will break if the clustal api makes the names include
       things after the space */
    kv = tommy_hashlin_search(seq_types,
                              kv_compare,
                              seq->name.s,
                              tommy_strhash_u32(0, seq->name.s));

    if (kv) {
      file_i = kv->val;
      /* fprintf(stderr, "file_i: %d\n", file_i); */

      kseq_print(outfiles[file_i], seq);
    } else {
      fprintf(stderr, "WARN: no group info for '%s'\n", seq->name.s);
    }

    if (++num_seqs % 1000 == 0) {
      fprintf(stderr, "LOG -- splitting seq: %lu\r", num_seqs);
    }
  }

  for (int i = 0; i < num_types; ++i) {
    fclose(outfiles[i]);
  }


  gzclose(seqs_file);
  kseq_destroy(seq);

  tommy_hashlin_foreach(types, (tommy_foreach_func*)type_info_destroy);
  tommy_hashlin_done(types);
  free(types);

  tommy_hashlin_foreach(seq_types, (tommy_foreach_func*)kv_destroy);
  tommy_hashlin_done(seq_types);
  free(seq_types);


  free(outfiles);
  free(buf);

  return 0;
}
