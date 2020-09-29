#include <stdint.h>
#include <stdio.h>

#include "unicorn/unicorn.h"

#include "emulation.h"

#define SYSCALL_ARGS \
  uc_engine *uc, uint32_t *r0, uint32_t *r1, uint32_t *r2, uint32_t *r3

void debug(SYSCALL_ARGS)
{
  fprintf(stderr, FMT_32x " " FMT_32x " " FMT_32x " " FMT_32x "\n",
    *r0, *r1, *r2, *r3);
}

void print(SYSCALL_ARGS)
{
  fprintf(stderr, "Hello, world\n");
}

// End of implementations

typedef void (*syscall_fn_t)(SYSCALL_ARGS);

static const syscall_fn_t table[] = {
  debug,
  print,
};

void syscall_invoke(uc_engine *uc, uint32_t call_num,
  uint32_t *r0, uint32_t *r1, uint32_t *r2, uint32_t *r3)
{
  if (call_num >= sizeof table / sizeof table[0]) {
    uint32_t pc;
    uc_expect(uc_reg_read, uc, UC_ARM_REG_PC, &pc);
    fprintf(stderr, FMT_32x ": Invalid syscall: " FMT_32x " (" FMT_32u ")\n",
      pc - 4, call_num, call_num);
    return;
  }

  (*table[call_num])(uc, r0, r1, r2, r3);
}
