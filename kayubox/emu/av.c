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

static GLuint tex;

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

  int w = 32, h = 16;
  uint8_t *pix = (uint8_t *)malloc(w * h * 4);
  for (int r = 0; r < h; r++)
    for (int c = 0; c < w; c++) {
      int R, G, B, A;
      R = (uint8_t)((1 - (float)r / h) * 255.5f);
      G = 0x7f;
      B = (uint8_t)((1 - (float)c / w) * 255.5f);
      A = 0xff;
      if (r == 0 && c == 0) {
        R = G = B = 0x3f;
      } else if (((r ^ c) & 1) == 0) {
        A = 0;
      }
      pix[(r * w + c) * 4 + 0] = R;
      pix[(r * w + c) * 4 + 1] = G;
      pix[(r * w + c) * 4 + 2] = B;
      pix[(r * w + c) * 4 + 3] = A;
    }

  glGenTextures(1, &tex);
  glBindTexture(GL_TEXTURE_2D, tex);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, w, h, 0,
    GL_RGBA, GL_UNSIGNED_BYTE, pix);

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
  if (frame_cleared) glfwSwapBuffers(window);
  frame_cleared = false;
  draw_setup = false;
}

static video_point buf[3];
static int buf_ptr = 0;

void video_draw_setup()
{
  if (!frame_cleared) return;
  if (buf_ptr != 0) {
    fprintf(stderr, "Warning: %d points dropped\n", buf_ptr);
    buf_ptr = 0;
  }
  if (draw_setup) glEnd();

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
  glBindTexture(GL_TEXTURE_2D, tex);
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
