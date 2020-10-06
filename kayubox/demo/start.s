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
  svc   #0x120  // Draw attributes
  ldr   r0, =0xffddddff
  vldrs s0, 0.0
  vldrs s1, 0.3
  svc   #0x121  // Draw
  ldr   r0, =0xffddddff
  vldrs s0, 0.6
  vldrs s1, 0.7
  svc   #0x121  // Draw
  ldr   r0, =0xffddddff
  add   r4, #1
  vmov          s4, r4
  vcvt.f32.u32  s4, s4
  vldrs         s0, 0.001
  vmul.f32      s4, s0
  vldrs         s0, 0.6
  vadd.f32      s0, s4
  vldrs         s1, -0.1
  svc   #0x121  // Draw

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
