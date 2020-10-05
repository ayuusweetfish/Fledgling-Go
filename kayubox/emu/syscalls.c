#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

#include "unicorn/unicorn.h"

#include "emulation.h"
#include "av.h"

#define SYSCALL_ARGS \
  uc_engine *uc, syscall_args *args

static void sys_debug(SYSCALL_ARGS)
{
  fprintf(stderr, FMT_32x " " FMT_32x " " FMT_32x " " FMT_32x "\n",
    args->r0, args->r1, args->r2, args->r3);
}

static void sys_log(SYSCALL_ARGS)
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

static void sys_trap(SYSCALL_ARGS)
{
  // while (1) usleep(1000000);
  exit(0);
}

#define EXTRACT_COMPONENTS(_c, _r, _g, _b, _a) \
  float _r = (((_c) >> 24) & 0xff) / 255.0f; \
  float _g = (((_c) >> 16) & 0xff) / 255.0f; \
  float _b = (((_c) >>  8) & 0xff) / 255.0f; \
  float _a = (((_c) >>  0) & 0xff) / 255.0f;

static void sys_clear_frame(SYSCALL_ARGS)
{
  EXTRACT_COMPONENTS(args->r0, R, G, B, A);
  video_clear_frame(R, G, B, A);
}

static void sys_draw_setup(SYSCALL_ARGS)
{
  video_draw_setup();
}

static void sys_draw(SYSCALL_ARGS)
{
  EXTRACT_COMPONENTS(args->r0, R, G, B, A);
  video_draw(&(video_point) {
    .r = R, .g = G, .b = B, .a = A,
    .x = args->s0, .y = args->s1,
    .u = args->s2, .v = args->s3,
  });
}

static void sys_end_frame(SYSCALL_ARGS)
{
  video_end_frame();
}

// End of implementations

typedef void (*syscall_fn_t)(SYSCALL_ARGS);

void syscall_invoke(void *uc, uint32_t call_num, syscall_args *args)
{
#define _(_num, _fn)  case (0x##_num): sys_##_fn(uc, args); return;
  switch (call_num) {
    _( 00, debug)
    _( 01, log)
    _( 0f, trap)

    _(100, clear_frame)
    _(10f, end_frame)
    _(120, draw_setup)
    _(121, draw)
  }
#undef _

  fprintf(stderr, FMT_32x ": Invalid syscall: " FMT_32x " (" FMT_32u ")\n",
    args->pc - 4, call_num, call_num);
}
