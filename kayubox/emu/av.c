#include "av.h"
#include "emulation.h"

#define GL_SILENCE_DEPRECATION
#include "GLFW/glfw3.h"

#if _WIN32
#include <GL/glext.h>
#endif

#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

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

// State variables

#define MAX_TEXTURES  1024
static bool tex_used[MAX_TEXTURES] = { false };
static struct tex_record {
  GLuint id;
  uint32_t w, h;
} texs[MAX_TEXTURES];
static int tex_ptr = 0;

static uint32_t cur_tex;
static bool gl_began;

static video_point buf[3];
static int buf_ptr = 0;

static void ensure_tex_valid(uint32_t tex_id)
{
  if (tex_id >= MAX_TEXTURES || !tex_used[tex_id])
    syscall_panic("Invalid texture ID " FMT_32u, tex_id);
}

static void drop_buffered_points()
{
  if (buf_ptr != 0) {
    syscall_warn("%d points dropped\n", buf_ptr);
    buf_ptr = 0;
  }
  if (gl_began) {
    glEnd();
    gl_began = false;
  }
}

// Interface implementations

void video_clear_frame(float R, float G, float B, float A)
{
  drop_buffered_points();

  glClearColor(R, G, B, A);
  glClear(GL_COLOR_BUFFER_BIT);

  gl_began = false;
  video_draw_config((uint32_t)-1);
}

void video_end_frame()
{
  drop_buffered_points();
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

  return tex_ptr++;
}

size_t video_tex_size(uint32_t tex_id)
{
  ensure_tex_valid(tex_id);
  return texs[tex_id].w * texs[tex_id].h * 4;
}

void video_tex_image(uint32_t tex_id, const void *pix_ptr)
{
  ensure_tex_valid(tex_id);
  drop_buffered_points();

  glBindTexture(GL_TEXTURE_2D, texs[tex_id].id);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8,
    texs[tex_id].w, texs[tex_id].h,
    0, GL_RGBA, GL_UNSIGNED_BYTE, pix_ptr);
}

void video_tex_config(uint32_t tex_id, uint32_t flags)
{
  ensure_tex_valid(tex_id);
  drop_buffered_points();

  glBindTexture(GL_TEXTURE_2D, texs[tex_id].id);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
}

void video_tex_release(uint32_t tex_id)
{
  ensure_tex_valid(tex_id);
  drop_buffered_points();

  tex_used[tex_id] = false;
  glDeleteTextures(1, &texs[tex_id].id);
}

void video_draw_config(uint32_t tex_id)
{
  if (tex_id != (uint32_t)-1) ensure_tex_valid(tex_id);
  drop_buffered_points();

  cur_tex = tex_id;
}

void video_draw(const video_point *p)
{
  buf[buf_ptr++] = *p;
  if (buf_ptr == 3) {
    if (!gl_began) {
      // Set up and call glBegin()
      if (cur_tex == (uint32_t)-1) {
        glDisable(GL_TEXTURE_2D);
      } else {
        ensure_tex_valid(cur_tex);
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, texs[cur_tex].id);
      }
      glBegin(GL_TRIANGLES);
      gl_began = true;
    }
    for (int i = 0; i < 3; i++) {
      glColor4f(buf[i].r, buf[i].g, buf[i].b, buf[i].a);
      if (cur_tex != (uint32_t)-1)
        glTexCoord2f(buf[i].u, buf[i].v);
      glVertex2f(buf[i].x, buf[i].y);
    }
    buf_ptr = 0;
  }
}
