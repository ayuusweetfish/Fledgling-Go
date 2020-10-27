# vim: set ft=asm:
.macro  vldrs reg: req, imm: req
  vldr  \reg, _vldrs\@_imm
  b     _vldrs\@_after
_vldrs\@_imm: .float \imm
_vldrs\@_after:
.endm

.section .text.startup
  bl    _crt_init

  ldr   r0, =Mali_Regular_ttf
  mov   r1, r1
  mov   r1, r1
  bl    kx_label
  ldr   r1, =label
  str   r0, [r1]

  ldr   r1, =label_text_1
  vldrs s0, 79.5
  bl    kx_label_print

  ldr   r0, =label
  ldr   r0, [r0]
  ldr   r1, =qwq_txt
  vldrs s0, 79.5
  bl    kx_label_print

  // Load image
  // See res.s
  ldr   r0, =_32573493_png
  ldr   r1, =_32573493_png_size
  blx   kx_image
  svc   #0x01
  // r0 - texture ID
  // r1 - width in pixels
  // r2 - height in pixels

  ldr   r1, =tex_first
  str   r0, [r1]  // Store texture ID in memory

  mov   r0, r4
  bl    free

  // Play audio
  ldr   r0, =copycat_ogg
  ldr   r1, =copycat_ogg_size
  mov   r2, #0
  mov   r3, #1
  bl    kx_music

  ldr   r1, =stream
  str   r0, [r1]
  bl    kx_music_start

  mov   r4, #0

main_loop:
  mov   r3, #46 // Period key
  svc   #0x11
  mov   r5, r3

  ldr   r1, =stream
  ldr   r0, [r1]
  cmp   r5, #0
  bleq  kx_music_start
  cmp   r5, #0
  blne  kx_music_pause

  // Update audio
  ldr   r1, =stream
  ldr   r0, [r1]
  bl    kx_music_update

  ldr   r0, =#0xffffeeff
  svc   #0x100  // Clear frame

  mov   r3, #32 // Space key
  svc   #0x11   // Key

  // Draw a triangle
  ldr   r0, =0xffddddff
  vldrs s0, 0.0
  vldrs s1, 0.3

  ldr   r1, =0xffddddff
  vldrs s4, 0.6
  vldrs s5, 0.7

  cmp   r3, #0  // Is space key down?
  addeq r4, #1
  subne r4, #1
  ldreq r2, =0xffddddff
  ldrne r2, =0xffeeccff
  vmov          s15, r4
  vcvt.f32.s32  s15, s15
  vldrs         s14, 0.001
  vmul.f32      s15, s14
  vldrs         s8, 0.6
  vadd.f32      s8, s15
  vldrs         s9, -0.1

  mov   r3, #-1
  svc   #0x120  // Draw

  cmp   r4, #300
  svceq #0x0f   // Debug

  // Draw the image
  mov   r5, #0

9:
  ldr   r0, =0xffffffff
  vldrs s0,  0.3
  vldrs s1,  0.3
  vldrs s2,  1.05
  vldrs s3, -0.05

  ldr   r1, =0xffffffff
  vldrs s4, -0.9
  vldrs s5, -0.9
  vldrs s6, -0.05
  vldrs s7,  1.05

  ldr   r2, =0xffffffff
  // s8 = -0.9 + 1.2 * i
  // s9 =  0.3 - 1.2 * i
  // s10 = s11 = -0.05 + 1.1 * i
  vldrs s8, -0.9
  vldrs s9,  0.3
  vldrs s10, -0.05
  vldrs s14,  1.2
  vldrs s15,  1.1
  cmp   r5, #0
  vaddne.f32  s8, s14
  vsubne.f32  s9, s14
  vaddne.f32  s10, s15
  vmov  s11, s10

  ldr   r3, =tex_first
  ldr   r3, [r3]
  svc   #0x120  // Draw

  add   r5, #1
  cmp   r5, #2
  bne   9b

  // Draw the label
  ldr   r0, =label
  ldr   r0, [r0]
  ldr   r1, =0xffccaaff
  vldrs s0, -0.4
  vldrs s1, 0.9
  vldrs s2, 0.00125
  vldrs s3, 0.0020833333
  bl    kx_label_draw

  svc   #0x10f  // End frame
  b     main_loop

.section .data
tex_first:
  .int  0
stream:
  .int  0
label:
  .int  0
label_text_1:
  .asciz "qwq\nqwq\nqwq\nqwq\nqwq\nqwq"
