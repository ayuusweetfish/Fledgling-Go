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

static void read_regs(uc_engine *uc, void *x, int start, int count)
{
  static const int regids[] = {
    UC_ARM_REG_R0, UC_ARM_REG_R1, UC_ARM_REG_R2, UC_ARM_REG_R3,
    UC_ARM_REG_R4, UC_ARM_REG_R5, UC_ARM_REG_R6, UC_ARM_REG_R7,
    UC_ARM_REG_R8, UC_ARM_REG_R9, UC_ARM_REG_R10, UC_ARM_REG_R11,
    UC_ARM_REG_R12, UC_ARM_REG_R13, UC_ARM_REG_R14, UC_ARM_REG_R15,
    UC_ARM_REG_CPSR,

    UC_ARM_REG_S0, UC_ARM_REG_S1, UC_ARM_REG_S2, UC_ARM_REG_S3,
    UC_ARM_REG_S4, UC_ARM_REG_S5, UC_ARM_REG_S6, UC_ARM_REG_S7,
    UC_ARM_REG_S8, UC_ARM_REG_S9, UC_ARM_REG_S10, UC_ARM_REG_S11,
    UC_ARM_REG_S12, UC_ARM_REG_S13, UC_ARM_REG_S14, UC_ARM_REG_S15,
    UC_ARM_REG_S16, UC_ARM_REG_S17, UC_ARM_REG_S18, UC_ARM_REG_S19,
    UC_ARM_REG_S20, UC_ARM_REG_S21, UC_ARM_REG_S22, UC_ARM_REG_S23,
    UC_ARM_REG_S24, UC_ARM_REG_S25, UC_ARM_REG_S26, UC_ARM_REG_S27,
    UC_ARM_REG_S28, UC_ARM_REG_S29, UC_ARM_REG_S30, UC_ARM_REG_S31,
  };
  void *ptrs[count];
  for (int i = 0; i < count; i++) ptrs[i] = (uint8_t *)x + (i * 4);
  uc_expect(uc_reg_read_batch, uc, (int *)regids + start, ptrs, count);
}

static void *read_mem(uc_engine *uc, uint32_t addr, uint32_t sz)
{
  void *buf = malloc(sz == 0 ? 1 : sz);
  if (buf == NULL) syscall_panic("Cannot allocate buffer");
  uc_expect(uc_mem_read, uc, addr, buf, sz);
  return buf;
}

static void sys_probe_min(SYSCALL_ARGS)
{
  uint32_t regs[8];
  read_regs(uc, regs, 0, 8);

  syscall_log("\n "
    "r0 = " FMT_32x "  "
    "r1 = " FMT_32x "  "
    "r2 = " FMT_32x "  "
    "r3 = " FMT_32x "\n "
    "r4 = " FMT_32x "  "
    "r5 = " FMT_32x "  "
    "r6 = " FMT_32x "  "
    "r7 = " FMT_32x "\n"
    , regs[0], regs[1], regs[2], regs[3]
    , regs[4], regs[4], regs[6], regs[7]
  );
}

static void sys_probe(SYSCALL_ARGS)
{
  uint32_t regs[17];
  read_regs(uc, regs, 0, 17);

  syscall_log("\n"
#define _(_r)   _r " = " FMT_32d0 " (" FMT_32x ")"
    _(" r0") "  " _(" r8") "\n"
    _(" r1") "  " _(" r9") "\n"
    _(" r2") "  " _("r10") "\n"
    _(" r3") "  " _("r11") "\n"
    _(" r4") "  " _(" ip") "\n"
    _(" r5") "  " _(" sp") "\n"
    _(" r6") "  " _(" lr") "\n"
    _(" r7") "  " _(" pc") "\n"
    " cc = %c %c %c %c\n"
#undef _
#define _(_i)   , regs[_i], regs[_i]
    _( 0) _( 8) _( 1) _( 9) _( 2) _(10) _( 3) _(11)
    _( 4) _(12) _( 5) _(13) _( 6) _(14) _( 7) _(15)
#undef _
    , (regs[16] & (1 << 31)) ? 'N' : '-'
    , (regs[16] & (1 << 30)) ? 'Z' : '-'
    , (regs[16] & (1 << 29)) ? 'C' : '-'
    , (regs[16] & (1 << 28)) ? 'V' : '-'
  );
}

static inline float reinterpret_f32(uint32_t value)
{
  // return *(float *)&value;
  union {
    uint32_t u32;
    float f32;
  } x;
  x.u32 = value;
  return x.f32;
}

static void sys_probe_float(SYSCALL_ARGS)
{
  uint32_t regs[32];
  read_regs(uc, regs, 17, 32);

  syscall_log("\n"
#define _f(_i)  "s" #_i " = %11.4f (" FMT_32x ")"
#define _a(_i)  " " _f(_i) "  "
#define _b(_i)      _f(_i) "  "
#define _c(_i)      _f(_i) "\n"
    _a( 0) _c(16)   _a( 1) _c(17)   _a( 2) _c(18)   _a( 3) _c(19)
    _a( 4) _c(20)   _a( 5) _c(21)   _a( 6) _c(22)   _a( 7) _c(23)
    _a( 8) _c(24)   _a( 9) _c(25)   _b(10) _c(26)   _b(11) _c(27)
    _b(12) _c(28)   _b(13) _c(29)   _b(14) _c(30)   _b(15) _c(31)
#undef _fmt
#undef _a
#undef _b
#undef _c
#define _(_i)   , reinterpret_f32(regs[_i]), regs[_i]
    _( 0) _(16) _( 1) _(17) _( 2) _(18) _( 3) _(19)
    _( 4) _(20) _( 5) _(21) _( 6) _(22) _( 7) _(23)
    _( 8) _(24) _( 9) _(25) _(10) _(26) _(11) _(27)
    _(12) _(28) _(13) _(29) _(14) _(30) _(15) _(31)
#undef _
  );
}

static void sys_probe_mem(SYSCALL_ARGS)
{
  uint32_t regs[16];
  read_regs(uc, regs, 0, 16);

  char buf[2048];
  char *buf_p = buf;
  buf[0] = '\0';

  static const char *r_names[] = {
    " r0", " r1", " r2", " r3",
    " r4", " r5", " r6", " r7",
    " r8", " r9", "r10", "r11",
    " ip", " sp", " lr", " pc",
  };

  for (int i = 0; i < 16; i++)
    if (regs[i] >= PROG_ENTRY && regs[i] < PROG_ENTRY + PROG_MEMSIZE) {
      buf_p += sprintf(buf_p, "%s = 0x" FMT_32x "\n", r_names[i], regs[i]);
      uint32_t addr = regs[i] & ~15;
      for (uint32_t a = addr - 16; a != addr + 32; a += 16)
        if (a >= PROG_ENTRY && a < PROG_ENTRY + PROG_MEMSIZE) {
          // Read
          unsigned char buf[16];
          uc_expect(uc_mem_read, uc, a, buf, 16);
          // Print
          buf_p += sprintf(buf_p, "  " FMT_32x " | ", a);
          for (uint32_t i = 0; i < 16; i++)
            buf_p += sprintf(buf_p, "%02x%c", (unsigned int)buf[i],
              i == 7 ? '-' : (i == 15 ? '\n' : ' '));
        }
    }

  syscall_log("\n%s", buf);
}

static void sys_log(SYSCALL_ARGS)
{
  uint32_t addr = args->r0;
  size_t cap = 4, ptr = 0;
  char *s = malloc(cap);
  while (1) {
    if (ptr >= cap) {
      cap <<= 1;
      s = realloc(s, cap);
    }
    uc_expect(uc_mem_read, uc, addr++, &s[ptr], 1);
    if (s[ptr] == 0) break;
    ptr++;
  }
  syscall_log("%s", s);
  free(s);
  clobber(0, 1, 2, 3);
}

static void sys_debug(SYSCALL_ARGS)
{
  audio_global_running(false);
  syscall_log("Program paused, press Enter to continue");
  while (fgetc(stdin) != '\n') { }
  audio_global_running(true);
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

static void sys_tex_alloc(SYSCALL_ARGS)
{
  args->r0 = video_tex_new(args->r0, args->r1);
  clobber(1, 2, 3);
}

static void sys_tex_image(SYSCALL_ARGS)
{
  void *buf = read_mem(uc, args->r1, video_tex_size(args->r0));
  video_tex_image(args->r0, buf);
  free(buf);
  clobber(0, 1, 2, 3);
}

static void sys_tex_release(SYSCALL_ARGS)
{
  video_tex_release(args->r0);
  clobber(0, 1, 2, 3);
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

  clobber(0, 1, 2, 3);
}

static void sys_end_frame(SYSCALL_ARGS)
{
  video_end_frame();
  clobber(0, 1, 2, 3);
}

static void sys_snd_alloc(SYSCALL_ARGS)
{
  args->r0 = audio_snd_new(args->r0);
  clobber(1, 2, 3);
}

static void sys_snd_pcm(SYSCALL_ARGS)
{
  void *buf = read_mem(uc, args->r1, audio_snd_size(args->r0));
  audio_snd_pcm(args->r0, buf);
  free(buf);
  clobber(0, 1, 2, 3);
}

static void sys_snd_release(SYSCALL_ARGS)
{
  audio_snd_release(args->r0);
  clobber(0, 1, 2, 3);
}

static void sys_play(SYSCALL_ARGS)
{
  audio_play(args->r0, args->r1, (int32_t)args->r2, (bool)args->r3);
  clobber(0, 1, 2, 3);
}

static void sys_trk_config(SYSCALL_ARGS)
{
  audio_trk_config(args->r0, args->r1, args->r2);
  clobber(0, 1, 2, 3);
}

static void sys_trk_tell(SYSCALL_ARGS)
{
  uint64_t ret = audio_trk_tell(args->r0);
  args->r0 = (uint32_t)(ret & 0xffffffff);
  args->r1 = (uint32_t)(ret >> 32);
  clobber(2, 3);
}

// End of implementations

typedef void (*syscall_fn_t)(SYSCALL_ARGS);

static uint32_t pc, num;

void syscall_invoke(void *uc, uint32_t call_num, syscall_args *args)
{
  pc = args->pc - 4;
  num = call_num;

  switch (call_num) {
    #define _(_num, _fn)  case (0x##_num): sys_##_fn(uc, args); return;
    #include "syscall_list.inc"
    #undef _
  }

  print_location(stderr, pc);
  fprintf(stderr, ": Invalid syscall: " FMT_32xn "\n", call_num);
}

static const char *syscall_name(uint32_t call_num)
{
  switch (call_num) {
    #define _(_num, _fn)  case (0x##_num): return #_fn;
    #include "syscall_list.inc"
    #undef _
  }
  return NULL;
}

#define syscall_vprintf(_word, ...) do { \
  print_location(stderr, pc); \
  fprintf(stderr, ": [%s] " _word, syscall_name(num)); \
  va_list args; \
  va_start(args, fmt); \
  vfprintf(stderr, fmt, args); \
  va_end(args); \
  fputc('\n', stderr); \
} while (0)

void syscall_log(const char *fmt, ...)
{
  syscall_vprintf("");
}

void syscall_warn(const char *fmt, ...)
{
  syscall_vprintf("warning: ");
}

void syscall_panic(const char *fmt, ...)
{
  syscall_vprintf("panic: ");
  exit(1);
}
