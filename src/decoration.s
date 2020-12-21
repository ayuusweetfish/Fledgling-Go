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
  ldr   r5, =extra_bg_count
  ldr   r5, [r5]
  mov   r4, #0
  ldr   r6, =extra_bg_list
extra_bg_loop:
  cmp   r4, r5
  bge   extra_bg_end
  ldm   r6, {r0-r1}
  bl    kx_image
  str   r0, [r6]
  add   r6, #8
  add   r4, #1
  b     extra_bg_loop
extra_bg_end:
  pop   {lr}
  bx    lr

drawDecorations:
  push  {lr}
  ldr   r7, =st_time
  vldr  s24, [r7] // s24是以拍为单位的时间
  ldr   r7, =map_deco
  ldr   r7, [r7]
  ldr   r6, =map_deco_len
  ldr   r6, [r6]
  ldr   r8, =decoration_list // r8是纹理id存储区域的地址
  ldr   r9, =extra_bg_list // r9是额外背景id存储区域的地址
  mov   r5, #0
drdeco_loop:
  cmp   r5, r6
  bge   drdeco_end
  ldr   r0, [r7], #4 // 是类别
  vldm  r7!, {s0-s4}
  // 判断种类是大于0还是小于0
  cmp   r0, #0
  blt   drdeco_bg
drdeco_normal:
  mov   r3, #8
  mul   r0, r3
  add   r0, r8
  ldr   r3, [r0] // 根据类别找到纹理id
  bl    coord_g2s_rect
  b     drdeco_draw
drdeco_bg:
  vadd.f32  s3, s0
  vcmpa.f32 s24, s0
  vcmpge.f32  s3, s24
  vmrsge      APSR_nzcv, FPSCR
  ble   drdeco_endloop
  neg   r0, r0
  mov   r3, #8
  mul   r0, r3
  add   r0, r9
  ldr   r3, [r0] // 根据类别找到纹理id
  vldrs s0, -1
  vldrs s1, 1
  vldrs s4, -1
  vldrs s5, -1
  vldrs s8, 1
  vldrs s9, 1
  b     drdeco_draw
drdeco_draw:
  bl    fillSWhenDrawFullTexture
  bl    draw_square // 画
drdeco_endloop:
  add   r5, #1
  b     drdeco_loop
drdeco_end:
  pop   {lr}
  bx    lr

.section .data
.align 2
decoration_count:
  .int 5
decoration_list:
  importres cloud_0_png
  importres cloud_1_png
  importres cloud_2_png
  importres cloud_3_png
  importres cloud_in_you_png
extra_bg_count:
  .int 10
extra_bg_list:
  importres cloud_0_png
  importres bg_rainbow_0_png
  importres bg_rainbow_1_png
  importres bg_rainbow_2_png
  importres bg_rainbow_3_png
  importres bg_rainbow_4_png
  importres bg_rainbow_5_png
  importres bg_rainbow_6_png
  importres bg_rainbow_7_png
  importres bg_rainbow_8_png
