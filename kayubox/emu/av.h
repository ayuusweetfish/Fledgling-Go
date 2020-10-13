#ifndef kayubox_emu__av_h
#define kayubox_emu__av_h

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

uint64_t av_time();
uint64_t av_rand();
bool av_key(uint32_t code);

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

void video_draw(uint32_t tex_id, const video_point p[3]);

void audio_init();
void audio_global_running(bool running);

uint32_t audio_snd_new(int32_t samples);
size_t audio_snd_size(uint32_t snd_id);
void audio_snd_pcm(uint32_t snd_id, const void *pcm_ptr);
void audio_snd_release(uint32_t snd_id);

void audio_play(uint32_t snd_id, uint32_t trk, int32_t offs, bool loop);
void audio_trk_config(uint32_t trk, uint32_t vol, uint32_t pan);
uint64_t audio_trk_tell(uint32_t trk);

#endif
