#include <stdio.h>
#include <string.h>
#include <stddef.h>

extern char _bss_begin;
extern char _bss_end;
void _crt_init()
{
  memset(&_bss_begin, 0, &_bss_end - &_bss_begin);
}

extern char _initial_brk;
void *_sbrk(intptr_t increment)
{
  static intptr_t brkdiff = 0;
  void *ret = &_initial_brk + brkdiff;
  if ((brkdiff += increment) < 0) brkdiff = 0;
  static char s[64];
  sprintf(s, "sbrk: %08x %d", (int)brkdiff, (int)increment);
  __asm__ __volatile__ (
    "mov  r0, %0\n"
    "svc  #0x0e\n"
    : : "r" (s) : "r0");
  return ret;
}
void _exit() { }
void _kill() { }
void _getpid() { }
