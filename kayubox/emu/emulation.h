#ifndef kayubox_emu__emulation_h
#define kayubox_emu__emulation_h

#include "unicorn/unicorn.h"
#include <inttypes.h>

#define PROG_ENTRY    0x80000000
#define PROG_MEMSIZE  0x100000 * 16

#define uc_expect(_fn, ...) do { \
  uc_err err; \
  if ((err = _fn(__VA_ARGS__)) != UC_ERR_OK) { \
    fprintf(stderr, __FILE__ ":%d: " #_fn "() returned error %s\n", \
      __LINE__, uc_strerror(err)); \
    return; \
  } \
} while (0)

#define FMT_32x   "%08" PRIx32
#define FMT_32u   "%" PRIu32

// Ensure that float is 32 bits
typedef char _ensure_float_32[sizeof(float) == 4 ? 1 : -1];

typedef struct syscall_args_s {
  uint32_t r0, r1, r2, r3, pc;
  float s0, s1, s2, s3;
} syscall_args;

void syscall_invoke(uc_engine *uc, uint32_t call_num, syscall_args *args);

#endif
