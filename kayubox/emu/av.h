#ifndef kayubox_emu__av_h
#define kayubox_emu__av_h

#include <stdbool.h>
#include <stdint.h>

void video_init();
void video_loop();

void video_acquire_context();

void video_clear_frame(float R, float G, float B, float A);
void video_end_frame();

typedef struct video_point_s {
  float r, g, b, a;
  float x, y, u, v;
} video_point;

void video_draw_setup();
void video_draw(const video_point *p);

void video_test();

#endif
