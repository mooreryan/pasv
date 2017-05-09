#ifndef ERR_CODES_H
#define ERR_CODES_H

/* NOTE when calling kseq_init, kseq calls ks_init which does NOT
   check the calloc calls. */

#define SUCESS     0

#define ARG_ERR    2
#define FILE_ERR   3
#define KSEQ_ERR   5
#define MEM_ERR    6
#define STD_ERR    1
#define THREAD_ERR 4

#define FILE_ERR_MSG "could not open '%s' for %s"
#define KSEQ_ERR_MSG "could not init kseq on '%s'"
#define MEM_ERR_MSG  "memory error while allocating"
#define STD_ERR_MSG  "an error occured"

#define PANIC_IF(test, err_type, fp, msg, ...)  \
  do {                                          \
    if (test) {                                 \
      fprintf(fp,                               \
              "FATAL -- %s:%d -- " msg "\n",    \
              __FILE__,                         \
              __LINE__,                         \
              ##__VA_ARGS__);                   \
      exit(err_type);                           \
    }                                           \
  } while (0)

#define PANIC_UNLESS(test, err_type, fp, msg, ...)      \
  do {                                                  \
    if (!test) {                                        \
      fprintf(fp,                                       \
              "FATAL -- %s:%d -- " msg "\n",            \
              __FILE__,                                 \
              __LINE__,                                 \
              ##__VA_ARGS__);                           \
      exit(err_type);                                   \
    }                                                   \
  } while (0)

#define PANIC_MEM(var, fp)                                      \
  do {                                                          \
    if (var == NULL) {                                          \
      fprintf(fp,                                               \
              "FATAL -- %s:%d -- " MEM_ERR_MSG " " #var " \n",  \
              __FILE__,                                         \
              __LINE__);                                        \
      exit(MEM_ERR);                                            \
    }                                                           \
  } while (0)

#endif
