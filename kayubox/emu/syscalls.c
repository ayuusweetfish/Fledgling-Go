#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

#include "unicorn/unicorn.h"

#include "emulation.h"
#include "av.h"

#define _clobber_count(_0, _1, _2, _3, _n, ...) (_n)
#define _clobber_argc(...) _clobber_count(__VA_ARGS__, 4, 3, 2, 1, 0)
#define _clobber(_argc, _0, _1, _2, _3, ...) do { \
  if (_argc > 0) args->r##_0 = (uint32_t)av_rand(); \
  if (_argc > 1) args->r##_1 = (uint32_t)av_rand(); \
  if (_argc > 2) args->r##_2 = (uint32_t)av_rand(); \
  if (_argc > 3) args->r##_3 = (uint32_t)av_rand(); \
} while (0)
#define clobber(...) _clobber(_clobber_argc(__VA_ARGS__), __VA_ARGS__, 0, 0, 0, 0)

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

static void sys_time(SYSCALL_ARGS)
{
  uint64_t t = av_time();
  args->r0 = (uint32_t)(t & 0xffffffff);
  args->r1 = (uint32_t)((t >> 32) & 0xffffffff);
  clobber(2, 3);
}

static void sys_key(SYSCALL_ARGS)
{
  args->r0 = av_key(args->r0);
  args->r1 = av_key(args->r1);
  args->r2 = av_key(args->r2);
  args->r3 = av_key(args->r3);
}

static void sys_rand(SYSCALL_ARGS)
{
  uint64_t a = av_rand();
  uint64_t b = av_rand();
  args->r0 = (uint32_t)(a & 0xffffffff);
  args->r1 = (uint32_t)((a >> 32) & 0xffffffff);
  args->r2 = (uint32_t)(b & 0xffffffff);
  args->r3 = (uint32_t)((b >> 32) & 0xffffffff);
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
  clobber(0, 1, 2, 3);
}

static void sys_tex_new(SYSCALL_ARGS)
{
  uint32_t id = video_tex_new(args->r0, args->r1);
  args->r0 = id;
  clobber(1, 2, 3);
}

static void sys_tex_image(SYSCALL_ARGS)
{
  size_t sz = video_tex_size(args->r0);
  void *buf = (void *)malloc(sz);
  if (sz == 0 || buf == NULL) {
    // TODO: Error message
    return;
  }
  uc_expect(uc_mem_read, uc, args->r1, buf, sz);
  video_tex_image(args->r0, buf);
  clobber(0, 1, 2, 3);
}

static void sys_tex_release(SYSCALL_ARGS)
{
}

static void sys_draw(SYSCALL_ARGS)
{
  // Read s0-s11 registers
  float s[12];
  static const int regids[] = {
    UC_ARM_REG_S0, UC_ARM_REG_S1, UC_ARM_REG_S2, UC_ARM_REG_S3,
    UC_ARM_REG_S4, UC_ARM_REG_S5, UC_ARM_REG_S6, UC_ARM_REG_S7,
    UC_ARM_REG_S8, UC_ARM_REG_S9, UC_ARM_REG_S10, UC_ARM_REG_S11,
  };
  void *ptrs[] = {
    &s[0], &s[1], &s[2], &s[3],
    &s[4], &s[5], &s[6], &s[7],
    &s[8], &s[9], &s[10], &s[11],
  };
  uc_expect(uc_reg_read_batch, uc, (int *)regids, ptrs, 12);

  EXTRACT_COMPONENTS(args->r0, R0, G0, B0, A0);
  EXTRACT_COMPONENTS(args->r1, R1, G1, B1, A1);
  EXTRACT_COMPONENTS(args->r2, R2, G2, B2, A2);
  video_point p[3] = {{
    .r = R0, .g = G0, .b = B0, .a = A0,
    .x = s[0], .y = s[1],
    .u = s[2], .v = s[3],
  }, {
    .r = R1, .g = G1, .b = B1, .a = A1,
    .x = s[4], .y = s[5],
    .u = s[6], .v = s[7],
  }, {
    .r = R2, .g = G2, .b = B2, .a = A2,
    .x = s[8], .y = s[9],
    .u = s[10], .v = s[11],
  }};
  video_draw(args->r3, p);
}

static void sys_end_frame(SYSCALL_ARGS)
{
  video_end_frame();
}

// End of implementations

typedef void (*syscall_fn_t)(SYSCALL_ARGS);

static uint32_t pc, num;

void syscall_invoke(void *uc, uint32_t call_num, syscall_args *args)
{
  pc = args->pc - 4;
  num = call_num;

#define _(_num, _fn)  case (0x##_num): sys_##_fn(uc, args); return;
  switch (call_num) {
    _( 00, debug)
    _( 01, log)
    _( 0f, trap)
    _( 10, time)
    _( 11, key)
    _( 12, rand)

    _(100, clear_frame)
    _(10f, end_frame)
    _(110, tex_new)
    _(111, tex_image)
    _(11f, tex_release)
    _(120, draw)
  }
#undef _

  fprintf(stderr, FMT_32x ": Invalid syscall: " FMT_32xn "\n", pc, call_num);
}

void syscall_warn(const char *fmt, ...)
{
  fprintf(stderr, FMT_32x ": Syscall " FMT_32xn " warning: ", pc, num);

  va_list args;
  va_start(args, fmt);
  vfprintf(stderr, fmt, args);
  va_end(args);

  fputc('\n', stderr);
}

void syscall_panic(const char *fmt, ...)
{
  fprintf(stderr, FMT_32x ": Syscall " FMT_32xn " panicked: ", pc, num);

  va_list args;
  va_start(args, fmt);
  vfprintf(stderr, fmt, args);
  va_end(args);

  fputc('\n', stderr);
  exit(1);
}
