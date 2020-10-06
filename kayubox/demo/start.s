# vim: set ft=asm:
.macro  vldrs reg, imm
  vldr  \reg, 0f
  b     1f
0: .float \imm
1:
.endm

.section .text.startup
  bl    foo
  mov   r3, #63
  svc   #2018   // Invalid
  svc   #0x00   // r0=79, r1=435, r2=2020, r3=63
  adr   r0, text
  svc   #0x01

  svc   #0x10   // Time
  svc   #0x00
  svc   #0x12   // Random
  svc   #0x00

  // Create texture
  mov   r0, #32
  mov   r1, #16
  svc   #0x110
  ldr   r1, =tex_first
  str   r0, [r1]

  mov   r0, #32
  mov   r1, #16
  svc   #0x110
  ldr   r1, =tex_second
  str   r0, [r1]

  // Generate image
  mov   r0, #32
  mov   r1, #16
  ldr   r2, =image
  blx   generate_image

  // Buffer
  ldr   r1, =tex_first
  ldr   r0, [r1]
  ldr   r1, =image
  svc   #0x111

  mov   r4, #0

main_loop:
  ldr   r0, =#0xffffeeff
  svc   #0x100  // Clear frame

  // Draw a triangle
  mov   r0, #-1
  svc   #0x120  // Draw config
  ldr   r0, =0xffddddff
  vldrs s0, 0.0
  vldrs s1, 0.3
  svc   #0x121  // Draw
  ldr   r0, =0xffddddff
  vldrs s0, 0.6
  vldrs s1, 0.7
  svc   #0x121  // Draw

  mov   r0, #32 // Space key
  svc   #0x11   // Key
  cmp   r0, #0
  addeq r4, #1
  subne r4, #1
  ldreq r0, =0xffddddff
  ldrne r0, =0xffeeccff
  vmov          s4, r4
  vcvt.f32.s32  s4, s4
  vldrs         s0, 0.001
  vmul.f32      s4, s0
  vldrs         s0, 0.6
  vadd.f32      s0, s4
  vldrs         s1, -0.1
  svc   #0x121  // Draw

  tst   r4, #63
  bne   8f

  ldr   r1, =image
  tst   r4, #64
  ldreq r0, =0xffeeddff
  ldrne r0, =0xffddffff
  strb  r0, [r1, #3]
  ror   r0, #8
  strb  r0, [r1, #2]
  ror   r0, #8
  strb  r0, [r1, #1]
  ror   r0, #8
  strb  r0, [r1, #0]
  ldr   r0, =tex_first
  ldr   r0, [r0]
  svc   #0x111

8:
  // Draw a checkboard
  ldr   r0, =tex_first
  ldr   r0, [r0]
  svc   #0x120  // Draw config

  mov   r5, #0
9:
  ldr   r0, =0xffffffff
  vldrs s0,  0.3
  vldrs s1,  0.3
  vldrs s2,  1.05
  vldrs s3, -0.05
  svc   #0x121  // Draw
  ldr   r0, =0xffffffff
  vldrs s0, -0.9
  vldrs s1, -0.9
  vldrs s2, -0.05
  vldrs s3,  1.05
  svc   #0x121  // Draw
  ldr   r0, =0xffffffff
  // s0 = -0.9 + 1.2 * i
  // s1 =  0.3 - 1.2 * i
  // s2 = s3 = -0.05 + 1.1 * i
  vldrs s0, -0.9
  vldrs s1,  0.3
  vldrs s2, -0.05
  vldrs s4,  1.2
  vldrs s5,  1.1
  cmp   r5, #0
  vaddne.f32  s0, s4
  vsubne.f32  s1, s4
  vaddne.f32  s2, s5
  vmov  s3, s2
  svc   #0x121  // Draw

  add   r5, #1
  cmp   r5, #2
  bne   9b

  svc   #0x10f  // End frame
  b     main_loop

  svc   #0x0f

text:
  .ascii "hello world"
  .byte 0

.section .data
tex_first:
  .int  0
tex_second:
  .int  0
image:
  .space  32 * 16 * 4
