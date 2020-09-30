#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

#include "unicorn/unicorn.h"

#include "emulation.h"

#define SYSCALL_ARGS \
  uc_engine *uc, uint32_t *r0, uint32_t *r1, uint32_t *r2, uint32_t *r3

static void debug(SYSCALL_ARGS)
{
  fprintf(stderr, FMT_32x " " FMT_32x " " FMT_32x " " FMT_32x "\n",
    *r0, *r1, *r2, *r3);
}

static void log(SYSCALL_ARGS)
{
  uint32_t addr = *r0;
  char ch;
  while (1) {
    uc_expect(uc_mem_read, uc, addr++, &ch, 1);
    if (ch == 0) break;
    putchar(ch);
  }
  putchar('\n');
}

static void trap(SYSCALL_ARGS)
{
  // while (1) usleep(1000000);
}

// End of implementations

typedef void (*syscall_fn_t)(SYSCALL_ARGS);

void syscall_invoke(uc_engine *uc, uint32_t call_num,
  uint32_t *r0, uint32_t *r1, uint32_t *r2, uint32_t *r3)
{
#define _(_num, _fn)  case (0x##_num): _fn(uc, r0, r1, r2, r3); return;
  switch (call_num) {
    _(  0, debug)
    _(  1, log)
    _(  f, trap)
  }
#undef _

  uint32_t pc;
  uc_expect(uc_reg_read, uc, UC_ARM_REG_PC, &pc);
  fprintf(stderr, FMT_32x ": Invalid syscall: " FMT_32x " (" FMT_32u ")\n",
    pc - 4, call_num, call_num);
}
