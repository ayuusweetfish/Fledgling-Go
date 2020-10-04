#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

#include "unicorn/unicorn.h"

#include "emulation.h"

#define SYSCALL_ARGS \
  uc_engine *uc, syscall_args *args

static void debug(SYSCALL_ARGS)
{
  fprintf(stderr, FMT_32x " " FMT_32x " " FMT_32x " " FMT_32x "\n",
    args->r0, args->r1, args->r2, args->r3);
}

static void log(SYSCALL_ARGS)
{
  uint32_t addr = args->r0;
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
  exit(0);
}

static void point_at(SYSCALL_ARGS)
{
  printf("%f %f\n", args->s0, args->s1);
}

// End of implementations

typedef void (*syscall_fn_t)(SYSCALL_ARGS);

void syscall_invoke(uc_engine *uc, uint32_t call_num, syscall_args *args)
{
#define _(_num, _fn)  case (0x##_num): _fn(uc, args); return;
  switch (call_num) {
    _( 00, debug)
    _( 01, log)
    _( 0f, trap)

    _(121, point_at)
  }
#undef _

  fprintf(stderr, FMT_32x ": Invalid syscall: " FMT_32x " (" FMT_32u ")\n",
    args->pc - 4, call_num, call_num);
}
