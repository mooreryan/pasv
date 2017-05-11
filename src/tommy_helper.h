#define INIT_HASHLIN(name)                      \
  do {                                          \
    name = malloc(sizeof *name);                \
    PANIC_MEM(name, stderr);                    \
    tommy_hashlin_init(name);                   \
  } while (0)

#define INIT_ARRAY(name)                        \
  do {                                          \
    name = malloc(sizeof *name);                \
    PANIC_MEM(name, stderr);                    \
    tommy_array_init(name);                     \
  } while (0)
