#include <stdint.h>

int bar(int i)
{
  const int t[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  return t[i] / 3 - 1.4f;
}

void generate_image(int w, int h, uint8_t *pix)
{
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
}
