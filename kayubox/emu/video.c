#include "video.h"

#define GL_SILENCE_DEPRECATION
#include "GLFW/glfw3.h"

#include <math.h>
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
}

bool video_running()
{
  return !glfwWindowShouldClose(window);
}

void video_flush()
{
  glfwPollEvents();
}

void video_test()
{
  glClearColor(0.95f, 0.9f, 0.9f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);

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

  glfwSwapBuffers(window);
}
