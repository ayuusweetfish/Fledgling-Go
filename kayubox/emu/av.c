#if _WIN32
#define _CRT_RAND_S
#include <stdlib.h>
#endif

#include "av.h"
#include "emulation.h"

#define GL_SILENCE_DEPRECATION
#include "GLFW/glfw3.h"

#if _WIN32
#include <GL/glext.h>
#endif

#include "miniaudio.h"

#include <errno.h>
#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

// Time

uint64_t av_time()
{
  double t = glfwGetTime();
  return (uint64_t)(t * 1000000);
}

// Random

#define LCG_DURABILITY  100000
static uint64_t lcg;
static int lcg_count = LCG_DURABILITY - 1;

static void reinit_rng()
{
#if _WIN32
  unsigned int a, b;
  if (rand_s(&a) != 0 || rand_s(&b) != 0)
    fprintf(stderr, "rand_s() failed. "
      "Random numbers will be based on current time.\n");
  lcg = ((uint64_t)a << 32) | (uint64_t)b;
#else
  FILE *fp_random;
  if ((fp_random = fopen("/dev/urandom", "r")) == NULL ||
      fread(&lcg, 8, 1, fp_random) < 1)
    fprintf(stderr, "Cannot read from /dev/urandom. "
      "Random numbers will be based on current time.\n");
  if (fp_random) fclose(fp_random);
#endif

  lcg += ((uint64_t)time(NULL) ^ av_time());
}

uint64_t av_rand()
{
  if (++lcg_count >= LCG_DURABILITY) {
    reinit_rng();
    lcg_count = 0;
  }
  // Newlib/Musl LCG implementation
  uint64_t ret;
  lcg = (lcg * 6364136223846793005LL + 1);
  ret = (lcg >> 32) << 32;
  lcg = (lcg * 6364136223846793005LL + 1);
  ret = ret | (lcg >> 32);
  return ret;
}

// Video

static GLFWwindow *window;

void video_init()
{
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 1);

  if (!glfwInit()) {
    fprintf(stderr, "glfwInit() failed\n");
    exit(1);
  }

  window = glfwCreateWindow(800, 480, "kayubox emulator", NULL, NULL);
  if (window == NULL) {
    fprintf(stderr, "glfwCreateWindow() failed\n");
    exit(1);
  }

  glfwMakeContextCurrent(window);
  glfwSwapInterval(1);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_COLOR_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glfwMakeContextCurrent(NULL);
}

void video_loop()
{
  while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();
    usleep(2500);
  }
}

void video_acquire_context()
{
  glfwMakeContextCurrent(window);
}

bool av_key(uint32_t code)
{
  return glfwGetKey(window, (int)code);
}

// State variables

#define MAX_TEXTURES  1024
static bool tex_used[MAX_TEXTURES] = { false };
static struct tex_record {
  GLuint id;
  uint32_t w, h;
} texs[MAX_TEXTURES];
static int tex_ptr = 0;

static uint32_t using_tex;

#define PBUF_SIZE (4096 * 3)
static video_point pbuf[PBUF_SIZE];
static int pbuf_ptr;

static void ensure_tex_valid(uint32_t tex_id)
{
  if (tex_id >= MAX_TEXTURES || !tex_used[tex_id])
    syscall_panic("Invalid texture ID " FMT_32u, tex_id);
}

static void submit_calls()
{
  if (pbuf_ptr == 0) return;

  glVertexPointer(2, GL_FLOAT, sizeof(video_point), &pbuf[0].x);
  glColorPointer(4, GL_FLOAT, sizeof(video_point), &pbuf[0].r);

  if (using_tex != (uint32_t)-1) {
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, texs[using_tex].id);
    glTexCoordPointer(2, GL_FLOAT, sizeof(video_point), &pbuf[0].u);
  } else {
    glDisable(GL_TEXTURE_2D);
  }

  glDrawArrays(GL_TRIANGLES, 0, pbuf_ptr);
  pbuf_ptr = 0;
}

// Interface implementations

void video_clear_frame(float R, float G, float B, float A)
{
  submit_calls();

  glClearColor(R, G, B, A);
  glClear(GL_COLOR_BUFFER_BIT);

  using_tex = (uint32_t)-1;
  glDisable(GL_TEXTURE_2D);
  pbuf_ptr = 0;
}

void video_end_frame()
{
  submit_calls();
  glfwSwapBuffers(window);
}

uint32_t video_tex_new(uint32_t w, uint32_t h)
{
  while (tex_used[tex_ptr])
    tex_ptr = (tex_ptr + 1) % MAX_TEXTURES;

  GLuint id;
  glGenTextures(1, &id);

  tex_used[tex_ptr] = true;
  texs[tex_ptr].w = w;
  texs[tex_ptr].h = h;
  texs[tex_ptr].id = id;

  video_tex_config(tex_ptr, 0);

  return tex_ptr;
}

size_t video_tex_size(uint32_t tex_id)
{
  ensure_tex_valid(tex_id);
  return texs[tex_id].w * texs[tex_id].h * 4;
}

void video_tex_image(uint32_t tex_id, const void *pix_ptr)
{
  ensure_tex_valid(tex_id);
  submit_calls();

  glBindTexture(GL_TEXTURE_2D, texs[tex_id].id);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
    texs[tex_id].w, texs[tex_id].h,
    0, GL_RGBA, GL_UNSIGNED_BYTE, pix_ptr);
}

void video_tex_config(uint32_t tex_id, uint32_t flags)
{
  ensure_tex_valid(tex_id);
  submit_calls();

  glBindTexture(GL_TEXTURE_2D, texs[tex_id].id);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
}

void video_tex_release(uint32_t tex_id)
{
  ensure_tex_valid(tex_id);
  submit_calls();

  tex_used[tex_id] = false;
  glDeleteTextures(1, &texs[tex_id].id);
}

void video_draw(uint32_t tex_id, const video_point p[3])
{
  if (tex_id != (uint32_t)-1) ensure_tex_valid(tex_id);

  if (pbuf_ptr >= PBUF_SIZE || tex_id != using_tex)
    submit_calls();

  using_tex = tex_id;

  memcpy(&pbuf[pbuf_ptr], p, 3 * sizeof(video_point));
  pbuf_ptr += 3;
}

// Audio

static void audio_data_callback(
  ma_device *device, int16_t *output, const void *_input, ma_uint32 nframes);

static ma_device audio_device;

static bool snd_running = true;

void audio_init()
{
  ma_device_config dev_config = ma_device_config_init(ma_device_type_playback);
  dev_config.playback.format = ma_format_s16;
  dev_config.playback.channels = 2;
  dev_config.sampleRate = 44100;
  dev_config.dataCallback = (ma_device_callback_proc)audio_data_callback;

  if (ma_device_init(NULL, &dev_config, &audio_device) != MA_SUCCESS ||
      ma_device_start(&audio_device) != MA_SUCCESS)
  {
    fprintf(stderr, "Cannot initialize audio\n");
    exit(1);
  }
}

void audio_global_running(bool running)
{
  snd_running = running;
}

#define MAX_SOUNDS        1024
#define MAX_TOTAL_SAMPLES (44100 * 60)
static bool snd_used[MAX_SOUNDS] = { false };
static struct snd_record {
  int32_t samples;  // Number of stereo samples
  int16_t *pcm;
} snds[MAX_SOUNDS];
static int snd_ptr = 0;
static uint32_t total_samples = 0;

#define NUM_CHANNELS      16
static struct ch_record {
  bool running;
  uint32_t snd_id;
  int32_t offset;
  bool loop;
  uint32_t vol;
  uint32_t pan;
} channels[NUM_CHANNELS] = {{ 0 }};

static void ensure_snd_valid(uint32_t snd_id)
{
  if (snd_id >= MAX_SOUNDS || !snd_used[snd_id])
    syscall_panic("Invalid sound ID " FMT_32u, snd_id);
}

static void ensure_ch_valid(uint32_t ch)
{
  if (ch >= NUM_CHANNELS)
    syscall_panic("Channel index " FMT_32u " out of range", ch);
}

#define AUDIO_LOCK()    ma_mutex_lock(&audio_device.lock)
#define AUDIO_UNLOCK()  ma_mutex_unlock(&audio_device.lock)

static inline int16_t sat_16(float x)
{
  return x < INT16_MIN ? INT16_MIN :
    x > INT16_MAX ? INT16_MAX : (int16_t)(x + 0.5f);
}

static void audio_data_callback(
  ma_device *device, int16_t *output, const void *_input, ma_uint32 nframes)
{
  ma_zero_pcm_frames(output, nframes, ma_format_s16, 2);
  if (!snd_running) return;

  AUDIO_LOCK();

  for (int ch = 0; ch < NUM_CHANNELS; ch++) if (channels[ch].running) {
    int32_t  snd_samples = snds[channels[ch].snd_id].samples;
    int16_t     *snd_pcm = snds[channels[ch].snd_id].pcm;
    int32_t offs = channels[ch].offset;

    bool mod = false;
    float gain_l = 1.0f, gain_r = 1.0f;
    if (channels[ch].vol != 0) {
      mod = true;
      float v = (float)channels[ch].vol / 0x80000000;
      gain_l = v;
      gain_r = v;
    }
    if (channels[ch].pan != 0) {
      mod = true;
      gain_l *= cos(0.5f * M_PI * (channels[ch].pan - 1) / 0xfffffffe) * M_SQRT2;
      gain_r *= sin(0.5f * M_PI * (channels[ch].pan - 1) / 0xfffffffe) * M_SQRT2;
    }

    for (int i = 0; i < nframes; i++)
      if ((offs += 1) >= 0 && offs < snd_samples) {
        if (mod) {
          output[i * 2 + 0] += sat_16((float)snd_pcm[offs * 2 + 0] * gain_l);
          output[i * 2 + 1] += sat_16((float)snd_pcm[offs * 2 + 1] * gain_r);
        } else {
          output[i * 2 + 0] += snd_pcm[offs * 2 + 0];
          output[i * 2 + 1] += snd_pcm[offs * 2 + 1];
        }
      } else if (offs == snd_samples) {
        // The end has been reached
        if (channels[ch].loop) {
          offs = -1;
          i--;
          continue;
        } else {
          channels[ch].running = false;
          break;
        }
      }
    channels[ch].offset = offs;
  }

  AUDIO_UNLOCK();
}

uint32_t audio_snd_new(int32_t samples)
{
  while (snd_used[snd_ptr])
    snd_ptr = (snd_ptr + 1) % MAX_SOUNDS;

  snd_used[snd_ptr] = true;
  snds[snd_ptr].samples = samples;

  if (samples > MAX_TOTAL_SAMPLES ||
      (total_samples += samples) > MAX_TOTAL_SAMPLES)
    syscall_panic("Too many samples in total (%d allowed)", MAX_TOTAL_SAMPLES);

  size_t num_bytes = samples * 4;
  int16_t *buf = malloc(num_bytes);
  snds[snd_ptr].pcm = buf;

  return snd_ptr;
}

void audio_snd_pcm(uint32_t snd_id, const void *pcm_ptr)
{
  ensure_snd_valid(snd_id);
  AUDIO_LOCK();

  memcpy(snds[snd_id].pcm, pcm_ptr, snds[snd_id].samples * 4);

  AUDIO_UNLOCK();
}

void audio_snd_release(uint32_t snd_id)
{
  ensure_snd_valid(snd_id);
  AUDIO_LOCK();

  for (int ch = 0; ch < NUM_CHANNELS; ch++)
    if (channels[ch].snd_id == snd_id)
      channels[ch].running = false;

  snd_used[snd_id] = false;
  free(snds[snd_id].pcm);

  AUDIO_UNLOCK();
}

void audio_play(uint32_t snd_id, uint32_t ch, int32_t offs, bool loop)
{
  ensure_ch_valid(ch);
  ensure_snd_valid(snd_id);
  AUDIO_LOCK();

  channels[ch].running = true;
  channels[ch].snd_id = snd_id;
  channels[ch].offset = offs;
  channels[ch].loop = loop;

  AUDIO_UNLOCK();
}

void audio_ch_config(uint32_t ch, uint32_t vol, uint32_t pan)
{
  ensure_ch_valid(ch);
  AUDIO_LOCK();

  channels[ch].vol = vol;
  channels[ch].pan = pan;

  AUDIO_UNLOCK();
}

uint64_t audio_ch_tell(uint32_t ch)
{
  ensure_ch_valid(ch);
  AUDIO_LOCK();

  uint64_t ret;
  if (channels[ch].running) {
    uint32_t snd_id = channels[ch].snd_id;
    int32_t offs = channels[ch].offset;
    ret = ((uint64_t)snd_id << 32) | offs;
  } else {
    ret = (uint64_t)-1ll;
  }

  AUDIO_UNLOCK();
  return ret;
}
