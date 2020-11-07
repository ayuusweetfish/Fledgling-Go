.include "common_macro.s"
.include "constants.s"

.global init_decorations
.global drawDecorations

.section .text
init_decorations:
  push  {lr}
  ldr   r5, =decoration_count
  ldr   r5, [r5]
  mov   r4, #0
  ldr   r6, =decoration_list
indeco_loop:
  cmp   r4, r5
  bge   indeco_end
  ldm   r6, {r0-r1}
  bl    kx_image
  str   r0, [r6]
  add   r6, #8
  add   r4, #1
  b     indeco_loop
indeco_end:
  pop   {lr}
  bx    lr

drawDecorations:
  push  {lr}
  ldr   r7, =map_deco
  ldr   r7, [r7]
  ldr   r6, =map_deco_len
  ldr   r6, [r6]
  ldr   r8, =decoration_list // r8是纹理id存储区域的地址
  mov   r5, #0
drdeco_loop:
  cmp   r5, r6
  bge   drdeco_end
  ldr   r0, [r7], #4 // 是类别
  vldm  r7!, {s0-s4}
  mov   r3, #8
  mul   r0, r3
  add   r0, r8
  ldr   r3, [r8] // 根据类别找到纹理id
  bl    coord_g2s_rect
  bl    fillSWhenDrawFullTexture
  bl    draw_square // 画
  add   r5, #1
  b     drdeco_loop
drdeco_end:
  pop   {lr}
  bx    lr

.section .data
decoration_count:
  .int 3
decoration_list:
  importres _32573502_png
  importres _32573502_png
  importres _32573503_png
