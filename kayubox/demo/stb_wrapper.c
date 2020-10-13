// stb_image

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

// stb_vorbis

#define STB_VORBIS_NO_STDIO
#define STB_VORBIS_NO_PUSHDATA_API
#define NDEBUG

#include "../../ext/stb/stb_vorbis.c"

#include <stdbool.h>

#define BLOCK_LEN 8192
static short buf[BLOCK_LEN * 2];

typedef struct stream_s {
  stb_vorbis *v;
  int snd1, snd2;
  int trk1, trk2;
  bool running;
  int ptr;
} stream;

#define def_syscall(_num, _name, ...) \
  __attribute__ ((naked)) \
  static int _name(__VA_ARGS__) \
  { \
    __asm__ __volatile__ ( \
      "svc  #" #_num "\n" \
      "bx   lr\n" \
      : : : "r0", "r1", "r2", "r3" \
    );  \
  }

def_syscall(0x200, snd_alloc, int len)
def_syscall(0x201, snd_pcm, int snd_id, const void *pcm_ptr)
def_syscall(0x20f, snd_release, int snd_id)
def_syscall(0x210, play, int snd_id, int trk, int offs, bool loop)
def_syscall(0x212, trk_tell, int trk)

stream *vorbis_stream(unsigned char *enc, unsigned int len, int trk1, int trk2)
{
  stream *s = malloc(sizeof(stream));
  s->v = stb_vorbis_open_memory(enc, len, NULL, NULL);
  s->snd1 = snd_alloc(BLOCK_LEN);
  s->snd2 = snd_alloc(BLOCK_LEN);
  s->trk1 = trk1;
  s->trk2 = trk2;
  s->running = false;
  s->ptr = 0;
  play(-1, trk1, 0, 0);
  play(-1, trk2, 0, 0);
  return s;
}

static inline void fill_buf(stb_vorbis *f)
{
  int n;
  if ((n = stb_vorbis_get_samples_short_interleaved(
      f, 2, buf, BLOCK_LEN * 2)) < BLOCK_LEN)
    memset(buf + n * 2, 0, sizeof(short) * (BLOCK_LEN - n) * 2);
}

void vorbis_stream_start(stream *s)
{
  if (s->running) return;
  s->running = true;

  stb_vorbis_seek(s->v, s->ptr);
  fill_buf(s->v);
  snd_pcm(s->snd1, buf);
  fill_buf(s->v);
  snd_pcm(s->snd2, buf);

  play(s->snd1, s->trk1, 0, false);
  play(s->snd2, s->trk2, -BLOCK_LEN, false);
}

void vorbis_stream_pause(stream *s)
{
  if (!s->running) return;
  s->running = false;

  int offs;
  trk_tell(s->trk2);
  __asm__ __volatile__ ("mov %0, r0\n" : "=r"(offs));
  s->ptr += (BLOCK_LEN + offs);

  play(-1, s->trk1, 0, 0);
  play(-1, s->trk2, 0, 0);
}

void vorbis_stream_update(stream *s)
{
  if (!s->running) return;

  int snd_id;
  trk_tell(s->trk1);
  __asm__ __volatile__ ("mov %0, r1\n" : "=r"(snd_id));

  if (snd_id == -1) {
    int swp;
    swp = s->snd1; s->snd1 = s->snd2; s->snd2 = swp;
    swp = s->trk1; s->trk1 = s->trk2; s->trk2 = swp;

    fill_buf(s->v);
    snd_pcm(s->snd2, buf);
    s->ptr += BLOCK_LEN;

    int offs;
    trk_tell(s->trk1);
    __asm__ __volatile__ ("mov %0, r0\n" : "=r"(offs));

    play(s->snd2, s->trk2, -BLOCK_LEN + offs, false);
  }
}
