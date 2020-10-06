#ifndef kayubox_emu__av_h
#define kayubox_emu__av_h

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

void video_init();
void video_loop();

void video_acquire_context();

void video_clear_frame(float R, float G, float B, float A);
void video_end_frame();

uint32_t video_tex_new(uint32_t w, uint32_t h);
size_t video_tex_size(uint32_t tex_id);
void video_tex_image(uint32_t tex_id, const void *pix_ptr);
void video_tex_config(uint32_t tex_id, uint32_t flags);
void video_tex_release(uint32_t tex_id);

typedef struct video_point_s {
  float r, g, b, a;
  float x, y, u, v;
} video_point;

void video_draw_setup(uint32_t tex_id);
void video_draw(const video_point *p);

void video_test();

#endif
