#include <stdbool.h>

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

// stb_image

#define STBI_NO_STDIO
#define STBI_NO_THREAD_LOCALS
#define STBI_NO_FAILURE_STRINGS
#define STBI_ASSERT(x)
#define STBI_MAX_DIMENSIONS 2560

#define STBI_ONLY_PNG

#define STB_IMAGE_STATIC
#define STB_IMAGE_IMPLEMENTATION
#include "ext/stb/stb_image.h"

void kx_image(unsigned char *res, unsigned int len)
{
  int w, h;
  unsigned char *pix = stbi_load_from_memory(res, len, &w, &h, NULL, 4);
  int tex = tex_alloc(w, h);
  tex_image(tex, pix);
  free(pix);

  __asm__ __volatile__ (
    "mov  r0, %0\n"
    "mov  r1, %1\n"
    "mov  r2, %2\n"
    : : "r"(tex), "r"(w), "r"(h)
    : "r0", "r1", "r2"
  );
}

// stb_vorbis

#define STB_VORBIS_NO_STDIO
#define STB_VORBIS_NO_PUSHDATA_API
#define NDEBUG

#include "ext/stb/stb_vorbis.c"

#define BLOCK_LEN 8192
static short buf[BLOCK_LEN * 2];

typedef struct stream_s {
  stb_vorbis *v;
  int snd1, snd2;
  int trk1, trk2;
  bool running;
  int ptr;
} stream;

stream *kx_music(unsigned char *res, unsigned int len, int trk1, int trk2)
{
  stream *s = malloc(sizeof(stream));
  s->v = stb_vorbis_open_memory(res, len, NULL, NULL);
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

void kx_music_start(stream *s)
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

void kx_music_pause(stream *s)
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

void kx_music_update(stream *s)
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

void kx_music_release(stream *s)
{
  snd_release(s->snd1);
  snd_release(s->snd2);
  free(s);
}

// stb_truetype

#define STBTT_STATIC
#define STBTT_assert(x)

#define STB_TRUETYPE_IMPLEMENTATION
#include "ext/stb/stb_truetype.h"

#define FONTS_HASH_SIZE 19
static struct {
  void *ttf;
  stbtt_fontinfo font;
} fonts[FONTS_HASH_SIZE] = {{ 0 }};

typedef struct label_s {
  stbtt_fontinfo *font;
  int tex, w, h;
  unsigned char *pix;

  // Size in pixels of the last printed string
  float last_w, last_h;
  // Texture coordinates of the last printed string
  float range_x, range_y;
} label;

label *kx_label(void *ttf)
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

  label *l = malloc(sizeof(label));

  l->font = font;
  l->tex = -1;
  l->w = l->h = 0;
  l->pix = NULL;

  return l;
}

void kx_label_print(label *l, const char *text, float size)
{
  // Assumes left-to-right
  stbtt_fontinfo *font = l->font;

  float scale = stbtt_ScaleForPixelHeight(font, size);
  int ascent_t, descent_t, linegap_t;
  stbtt_GetFontVMetrics(font, &ascent_t, &descent_t, &linegap_t);

  float ascent = ascent_t * scale;
  float descent = descent_t * scale;
  float linegap = linegap_t * scale;

  float ox, oy, ox_max = 0;

  int tw, th;
  unsigned char *pix;

  for (int it = 0; it <= 1; it++) {
    if (it == 1) {
      tw = (int)ox_max + 1;
      th = (int)(oy - descent) + 1;
      if (l->w < tw || l->h < th) {
        l->w = tw;
        l->h = th;
        l->pix = pix = realloc(l->pix, tw * th * 4);
        if (l->tex != -1) tex_release(l->tex);
        l->tex = tex_alloc(tw, th);
      } else {
        tw = l->w;
        th = l->h;
        pix = l->pix;
      }

      for (int i = 0; i < tw * th; i++) {
        pix[i * 4 + 0] = pix[i * 4 + 1] = pix[i * 4 + 2] = 0xff;
        pix[i * 4 + 3] = 0;
      }
    }

    ox = 0;
    oy = ascent;

    for (const char *c = text; *c != '\0'; c++) {
      if (*c == '\n') {
        if (ox_max < ox) ox_max = ox;
        ox = 0;
        oy += (ascent - descent + linegap);
        continue;
      }

      int x0, y0, x1, y1;
      if (it == 1)
        stbtt_GetCodepointBitmapBoxSubpixel(font, *c, scale, scale,
          ox - (int)ox, oy - (int)oy, &x0, &y0, &x1, &y1);

      int advance_t, lsb_t;
      stbtt_GetCodepointHMetrics(font, *c, &advance_t, &lsb_t);

      if (it == 1) {
        int gw, gh;
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

        stbtt_FreeBitmap(glyph, NULL);
      }

      ox += scale * (advance_t +
        (c[1] == '\0' ? 0 : stbtt_GetCodepointKernAdvance(font, c[0], c[1]))
      );
    }

    if (ox_max < ox) ox_max = ox;
  }

  tex_image(l->tex, pix);

  l->last_w = ox_max;
  l->last_h = oy - descent;
  l->range_x = l->last_w / tw;
  l->range_y = l->last_h / th;
}

void kx_label_draw(label *l, unsigned colour, float x, float y, float xs, float ys)
{
  // w = last_w * xs
  // h = last_h * ys
  __asm__ __volatile__ (
    "vmul.f32 %0, %2\n"
    "vmul.f32 %1, %3\n"
    : "+t"(xs), "+t"(ys)
    : "t"(l->last_w), "t"(l->last_h)
  );

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

void kx_label_release(label *l)
{
  if (l->tex != -1) {
    tex_release(l->tex);
    free(l->pix);
  }
}
