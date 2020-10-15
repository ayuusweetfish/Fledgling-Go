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

def_syscall(0x110, tex_alloc, int w, int h)
def_syscall(0x111, tex_image, int tex_id, const void *pix_ptr)
def_syscall(0x11f, tex_release, int tex_id)

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

// stb_truetype

#define STBTT_STATIC
#define STBTT_assert(x)

#define STB_TRUETYPE_IMPLEMENTATION
#include "../../ext/stb/stb_truetype.h"

#define FONTS_HASH_SIZE 19
static struct {
  void *ttf;
  stbtt_fontinfo font;
} fonts[FONTS_HASH_SIZE] = {{ 0 }};

typedef struct label_s {
  stbtt_fontinfo *font;
  int tex, w, h;
  unsigned char *pix;

  float range_x, range_y;
} label;

label *label_new(void *ttf, int max_w, int max_h)
{
  stbtt_fontinfo *font = NULL;

  // Find font in hash table
  int start_index = (int)ttf % FONTS_HASH_SIZE;
  for (int index = start_index; ; index = (index + 1) % FONTS_HASH_SIZE)
    if (fonts[index].ttf == ttf)
      font = &fonts[index].font;
    else if (fonts[index].ttf == NULL) break;

  if (font == NULL) {
    // Add to hash table
    for (int index = start_index; ; index = (index + 1) % FONTS_HASH_SIZE)
      if (fonts[index].ttf == NULL) {
        fonts[index].ttf = ttf;
        font = &fonts[index].font;
        stbtt_InitFont(font, ttf, 0);
        break;
      }
  }

  int tex = tex_alloc(max_w, max_h);
  unsigned char *pix = malloc(max_w * max_h * 4);

  label *l = malloc(sizeof(label));

  l->font = font;
  l->tex = tex;
  l->w = max_w;
  l->h = max_h;
  l->pix = pix;
  l->range_x = l->range_y = 0;

  return l;
}

void label_print(label *l, const char *text, float size)
{
  stbtt_fontinfo *font = l->font;
  int tw = l->w;
  int th = l->h;
  unsigned char *pix = l->pix;

  float scale = stbtt_ScaleForPixelHeight(font, size);
  int ascent_t, descent_t, linegap_t;
  stbtt_GetFontVMetrics(font, &ascent_t, &descent_t, &linegap_t);

  float ascent = ascent_t * scale;
  float descent = descent_t * scale;
  float linegap = linegap_t * scale;

  for (int i = 0; i < tw * th; i++) {
    pix[i * 4 + 0] = pix[i * 4 + 1] = pix[i * 4 + 2] = 0xff;
    pix[i * 4 + 3] = 0;
  }

  float ox = 0, oy = ascent;
  float ox_max = 0;

  for (const char *c = text; *c != '\0'; c++) {
    if (*c == '\n') {
      if (ox_max < ox) ox_max = ox;
      ox = 0;
      oy += (ascent - descent + linegap);
      continue;
    }

    int x0, y0, x1, y1;
    stbtt_GetCodepointBitmapBoxSubpixel(font, *c, scale, scale,
      ox - (int)ox, oy - (int)oy, &x0, &y0, &x1, &y1);

    int advance_t, lsb_t;
    stbtt_GetCodepointHMetrics(font, *c, &advance_t, &lsb_t);
    float advance = advance_t * scale;
    float lsb = lsb_t * scale;

    int gw, gh, xoff, yoff;
    unsigned char *glyph = stbtt_GetCodepointBitmapSubpixel(
      font, scale, scale, ox - (int)ox, oy - (int)oy,
      *c, &gw, &gh, NULL, NULL);

    for (int y = 0; y < gh; y++)
      for (int x = 0; x < gw; x++) {
        int bitmap_x = (int)ox + x + x0;
        int bitmap_y = (int)oy + y + y0;
        if (bitmap_x >= 0 && bitmap_x < tw &&
            bitmap_y >= 0 && bitmap_y < th) {
          int bitmap_index = bitmap_y * tw + bitmap_x;
          pix[bitmap_index * 4 + 3] += glyph[y * gw + x];
        }
      }

    ox += scale * (advance_t +
      (c[1] == '\0' ? 0 : stbtt_GetCodepointKernAdvance(font, c[0], c[1]))
    );

    stbtt_FreeBitmap(glyph, NULL);
  }

  tex_image(l->tex, pix);

  if (ox_max < ox) ox_max = ox;
  l->range_x = ox_max / tw;
  l->range_y = (oy - descent) / th;
}

void label_draw(label *l, unsigned colour, float x, float y, float w, float h)
{
  // A = (x, y)     (0, 0)
  // B = (x+w, y-h) (rx, ry)
  // C1 = (x+w, y)  (rx, 0)
  // C2 = (x, y-h)  (0, ry)
  __asm__ __volatile__ (
    "vmov     s4, s0\n"
    "vadd.f32 s4, s2\n" // s4 = x+w
    "vmov     s5, s1\n"
    "vsub.f32 s5, s3\n" // s5 = y-h

    // s2 = s3 = 0
    // s6 = rx
    // s7 = ry
    "vldr     s2, =0\n"
    "vmov     s3, s2\n"
    "vldr     s6, %0\n"
    "vldr     s7, %1\n"
    : : "m"(l->range_x), "m"(l->range_y)
  );

  __asm__ __volatile__ (
    // Vertex C1
    "vmov     s8, s4\n"   // s8 = x+w
    "vmov     s9, s1\n"   // s9 = y
    "vmov     s10, s6\n"  // s10 = rx
    "vmov     s11, s3\n"  // s11 = 0

    "mov  r0, %0\n"
    "mov  r1, %0\n"
    "mov  r2, %0\n"
    "mov  r3, %1\n"
    "svc  #0x120\n"
    : : "r"(colour), "r"(l->tex)
    : "r0", "r1", "r2", "r3"
  );
  __asm__ __volatile__ (
    // Vertex C2
    "vmov     s8, s0\n"   // s8 = x
    "vmov     s9, s5\n"   // s9 = y-h
    "vmov     s10, s2\n"  // s10 = 0
    "vmov     s11, s7\n"  // s11 = ry

    "mov  r0, %0\n"
    "mov  r1, %0\n"
    "mov  r2, %0\n"
    "mov  r3, %1\n"
    "svc  #0x120\n"
    : : "r"(colour), "r"(l->tex)
    : "r0", "r1", "r2", "r3"
  );
}
