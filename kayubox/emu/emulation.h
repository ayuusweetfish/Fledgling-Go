#ifndef kayubox_emu__emulation_h
#define kayubox_emu__emulation_h

#include <inttypes.h>
#include <stdint.h>
#include <stdlib.h>

#define PROG_ENTRY    0x80000000
#define PROG_MEMSIZE  0x100000 * 16

#define uc_expect(_fn, ...) do { \
  uc_err err; \
  if ((err = _fn(__VA_ARGS__)) != UC_ERR_OK) { \
    fprintf(stderr, __FILE__ ":%d: " #_fn "() returned error %s\n", \
      __LINE__, uc_strerror(err)); \
    exit(1); \
  } \
} while (0)

#define FMT_32x   "%08" PRIx32
#define FMT_32xn  "0x%" PRIx32
#define FMT_32u   "%" PRIu32
#define FMT_32d0  "%11" PRId32

// Ensure that float is 32 bits
typedef char _ensure_float_32[sizeof(float) == 4 ? 1 : -1];

typedef struct syscall_args_s {
  uint32_t r0, r1, r2, r3;
  uint32_t pc;
} syscall_args;

void syscall_invoke(void *uc, uint32_t call_num, syscall_args *args);
void syscall_print(const char *fmt, ...);
void syscall_log(const char *fmt, ...);
void syscall_warn(const char *fmt, ...);
void syscall_panic(const char *fmt, ...);

#endif
