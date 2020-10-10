#include <stdio.h>
#include <string.h>
#include <stddef.h>

int end;

static char buf[4 * 1024 * 1024];
static size_t cnt;

static void *my_malloc(size_t size)
{
  void *ret = buf + cnt;
  cnt += size;
  return ret;
}

static void *my_realloc(void *p, size_t old_size, size_t new_size)
{
  if (buf + cnt == p + old_size) {
    cnt += (new_size - old_size);
    return p;
  }
  if (new_size < old_size) return p;
  void *ret = buf + cnt;
  cnt += new_size;
  memcpy(ret, p, old_size);
  return ret;
}

#define STBI_NO_STDIO
#define STBI_ASSERT(x)
#define STBI_MAX_DIMENSIONS 2560

#define STBI_MALLOC(sz) my_malloc(sz)
#define STBI_FREE(p)
#define STBI_REALLOC_SIZED(p, oldsz, newsz) my_realloc(p, oldsz, newsz)

#define STBI_ONLY_PNG

#define STB_IMAGE_IMPLEMENTATION
#include "../../ext/stb/stb_image.h"

unsigned char *decode_image(unsigned char *enc, unsigned int len)
{
  char s[64];
  sprintf(s, "%p %u\n", enc, len);
  __asm__ __volatile__ (
    "mov  r0, %0\n"
    "svc  #0x0e\n"
    : : "r" (s) : "r0");
  cnt = 0;
  int w, h;
  unsigned char *pix = stbi_load_from_memory(enc, len, &w, &h, NULL, 4);
  __asm__ __volatile__ (
    "mov  r0, %0\n"
    "mov  r1, %1\n"
    "mov  r2, %2\n"
    : : "r"(pix), "r"(w), "r"(h)
    : "r0", "r1", "r2"
  );
}

#define STB_VORBIS_NO_STDIO

unsigned char *decode_ogg(unsigned char *enc, unsigned int len)
{
}
