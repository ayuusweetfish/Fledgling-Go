#include "emulation.h"
#include "av.h"

#include "unicorn/unicorn.h"

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>

static inline const char *mem_type_str(uc_mem_type t)
{
  switch (t) {
    case UC_MEM_READ: return "read";
    case UC_MEM_WRITE: return "write";
    case UC_MEM_FETCH: return "fetch";
    case UC_MEM_READ_UNMAPPED: return "read unmapped";
    case UC_MEM_WRITE_UNMAPPED: return "write unmapped";
    case UC_MEM_FETCH_UNMAPPED: return "fetch unmapped";
    case UC_MEM_READ_PROT: return "read protected";
    case UC_MEM_WRITE_PROT: return "write protected";
    case UC_MEM_FETCH_PROT: return "fetch protected";
    default: return "--";
  }
}

static void handler_mem(
  uc_engine *uc, uc_mem_type type,
  uint64_t address, int size, int64_t value, void *user_data)
{
  if (type == UC_MEM_FETCH_UNMAPPED && address == 0) return;

  uint32_t pc;
  uc_expect(uc_reg_read, uc, UC_ARM_REG_PC, &pc);
  print_location(stderr, pc);
  fprintf(stderr, ": Invalid memory access 0x" FMT_32x " "
    "(type = %s, value = 0x" FMT_32x ")\n",
    (uint32_t)address, mem_type_str(type), (uint32_t)value);
}

static void handler_syscall(uc_engine *uc, uint32_t exc_index, void *user_data)
{
  static const int regids[] = {
    UC_ARM_REG_R0, UC_ARM_REG_R1, UC_ARM_REG_R2, UC_ARM_REG_R3,
    UC_ARM_REG_PC,
  };
  syscall_args args;
  void *ptrs[] = {
    &args.r0, &args.r1, &args.r2, &args.r3,
    &args.pc,
  };
  uc_expect(uc_reg_read_batch, uc, (int *)regids, ptrs, 5);

  uint32_t instr;
  uc_expect(uc_mem_read, uc, args.pc - 4, &instr, 4);

  uint32_t call_num = instr & 0xffffff;
  syscall_invoke(uc, call_num, &args);

  uc_expect(uc_reg_write_batch, uc, (int *)regids, ptrs, 4);
}

void *emu_thread_fn(void *uc)
{
  video_acquire_context();

  uc_expect(uc_emu_start, uc, PROG_ENTRY, 0, 0, 0);
  return NULL;
}

static const source_map_entry *map;
static int map_len;

void run_emulation(
  const char *program, long program_size,
  const source_map_entry *source_map)
{
  // Load source map
  map = source_map;
  for (map_len = 0; source_map[map_len].addr != 0; map_len++) { }

  // Initialize Unicorn
  uc_engine *uc;
  uc_expect(uc_open, UC_ARCH_ARM, UC_MODE_ARM | UC_MODE_ARM1176, &uc);

  // Enable VFP
  uint32_t val;
  uc_expect(uc_reg_read, uc, UC_ARM_REG_C1_C0_2, &val);
  val |= 0xf00000;  // Single & double precision
  uc_expect(uc_reg_write, uc, UC_ARM_REG_C1_C0_2, &val);
  val = 0x40000000; // Set EN bit
  uc_expect(uc_reg_write, uc, UC_ARM_REG_FPEXC, &val);

  // Add hooks
  uc_hook hook_mem, hook_syscall;
  uc_expect(uc_hook_add, uc, &hook_mem, UC_HOOK_MEM_INVALID, handler_mem, NULL, 1, 0);
  uc_expect(uc_hook_add, uc, &hook_syscall, UC_HOOK_INTR, handler_syscall, NULL, 1, 0);

  // Map memory
  void *user_mem = malloc(PROG_MEMSIZE);
  if (user_mem == NULL) {
    fprintf(stderr, "Cannot allocate enough memory (%d bytes)\n", PROG_MEMSIZE);
    exit(1);
  }
  uc_expect(uc_mem_map_ptr,
    uc, PROG_ENTRY, PROG_MEMSIZE,
    UC_PROT_READ | UC_PROT_WRITE | UC_PROT_EXEC, user_mem);

  // Copy program
  memcpy(user_mem, program, program_size);

  // Set up stack
  val = PROG_ENTRY + PROG_MEMSIZE;
  uc_expect(uc_reg_write, uc, UC_ARM_REG_SP, &val);

  video_init();
  audio_init();

  pthread_t emu_thread;
  int err;

  if ((err = pthread_create(&emu_thread, NULL, emu_thread_fn, uc)) != 0) {
    printf("pthread_create() returned error %d (%s)\n", err, strerror(err));
    exit(1);
  }
  if ((err = pthread_detach(emu_thread)) != 0) {
    printf("pthread_detach() returned error %d (%s)\n", err, strerror(err));
    exit(1);
  }

  video_loop();
}

void print_location(FILE *stream, uint32_t pc)
{
  int lo = -1, hi = map_len, mid;
  while (lo < hi - 1) {
    mid = (lo + hi) / 2;
    if (map[mid].addr <= pc) lo = mid;
    else hi = mid;
  }
  // TODO: DW_LNE_end_sequence should also be considered
  // when determining unknown locations
  if (lo == -1) {
    fprintf(stream, FMT_32x " (unknown source)", pc);
  } else {
    fprintf(stream, FMT_32x " (%s:%d)", pc, map[lo].file, map[lo].line);
  }
}
