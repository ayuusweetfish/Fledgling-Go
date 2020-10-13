#define STBI_NO_STDIO
#define STBI_ASSERT(x)
#define STBI_MAX_DIMENSIONS 2560

#define STBI_ONLY_PNG

#define STB_IMAGE_STATIC
#define STB_IMAGE_IMPLEMENTATION
#include "../../ext/stb/stb_image.h"

void decode_image(unsigned char *enc, unsigned int len)
{
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

