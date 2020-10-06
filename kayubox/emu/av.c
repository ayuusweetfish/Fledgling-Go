#include "av.h"

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

  glfwPollEvents();
  glfwMakeContextCurrent(NULL);
}

void video_loop()
{
  while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();
  }
}

void video_acquire_context()
{
  glfwMakeContextCurrent(window);
}

static bool frame_cleared = false;
static bool draw_setup = false;

void video_clear_frame(float R, float G, float B, float A)
{
  glClearColor(R, G, B, A);
  glClear(GL_COLOR_BUFFER_BIT);
  frame_cleared = true;
  draw_setup = false;
}

void video_end_frame()
{
  if (draw_setup) glEnd();
  video_test();
  if (frame_cleared) glfwSwapBuffers(window);
  frame_cleared = false;
  draw_setup = false;
}

#define MAX_TEXTURES  1024
static bool tex_used[MAX_TEXTURES] = { false };
static struct tex_record {
  GLuint id;
  uint32_t w, h;
} texs[MAX_TEXTURES];
static int tex_ptr = 0;

static int cur_tex = -1;
static video_point buf[3];
static int buf_ptr = 0;

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
  if (!tex_used[tex_id]) return 0;
  return texs[tex_id].w * texs[tex_id].h * 4;
}

void video_tex_image(uint32_t tex_id, const void *pix_ptr)
{
  if (!tex_used[tex_id]) return;

  glBindTexture(GL_TEXTURE_2D, texs[tex_id].id);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8,
    texs[tex_id].w, texs[tex_id].h,
    0, GL_RGBA, GL_UNSIGNED_BYTE, pix_ptr);
}

void video_tex_config(uint32_t tex_id, uint32_t flags)
{
  if (!tex_used[tex_id]) return;

  glBindTexture(GL_TEXTURE_2D, texs[tex_id].id);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
}

void video_tex_release(uint32_t tex_id)
{
  if (!tex_used[tex_id]) return;

  tex_used[tex_id] = false;
  glDeleteTextures(1, &texs[tex_id].id);
}

void video_draw_setup(uint32_t tex_id)
{
  if (!frame_cleared) return;
  if (buf_ptr != 0) {
    fprintf(stderr, "Warning: %d points dropped\n", buf_ptr);
    buf_ptr = 0;
  }
  if (draw_setup) glEnd();

  if (cur_tex != tex_id) {
    cur_tex = tex_id;

    if (tex_id == (uint32_t)-1) {
      glDisable(GL_TEXTURE_2D);
    } else {
      glEnable(GL_TEXTURE_2D);
      // TODO: Check texture validity
      glBindTexture(GL_TEXTURE_2D, texs[tex_id].id);
    }
  }

  glBegin(GL_TRIANGLES);
  draw_setup = true;
}

void video_draw(const video_point *p)
{
  if (!frame_cleared) return;
  buf[buf_ptr++] = *p;
  if (buf_ptr == 3) {
    for (int i = 0; i < 3; i++) {
      glColor4f(buf[i].r, buf[i].g, buf[i].b, buf[i].a);
      glVertex2f(buf[i].x, buf[i].y);
    }
    buf_ptr = 0;
  }
}

void video_test()
{
  glDisable(GL_TEXTURE_2D);
  glBegin(GL_TRIANGLES);
    glColor3f(1.0f, 0.7f, 0.3f);
    glVertex2f(0.0f, 0.0f);
    glVertex2f(0.25f + 0.08f * sin(glfwGetTime()), 0.5f);
    glVertex2f(0.5f, 0.0f);
    glColor3f(0.3f, 0.7f, 1.0f);
    glVertex2f(0.0f, 0.0f);
    glVertex2f(0.25f - 0.08f * sin(glfwGetTime()), -0.5f);
    glVertex2f(0.5f, 0.0f);
  glEnd();

  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, 1);
  glBegin(GL_TRIANGLES);
    glColor4f(1.0, 1.0, 1.0, 0.7);
    for (int i = 0; i < 2; i++) {
      glTexCoord2f(1.05, -0.05); glVertex2f(0.3, 0.3);
      glTexCoord2f(-0.05, 1.05); glVertex2f(-0.9, -0.9);
      glTexCoord2f(-0.05 + i * 1.1, -0.05 + i * 1.1);
      glVertex2f(0.3 + (-1 + i) * 1.2f, 0.3 - i * 1.2f);
    }
  glEnd();
}
