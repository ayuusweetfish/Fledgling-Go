# vim: set ft=asm:
.macro  vldrs reg, imm
  vldr  \reg, 0f
  b     1f
0: .float \imm
1:
.endm

.section .text.startup
  bl    _crt_init

  ldr   r0, =stray_bin
  bl    map_meta
  svc   #0x00
  svc   #0x02
  push  {r0-r3}
  svc   #0x0e
  pop   {r0-r3}

  // Play audio
  mov   r0, r1
  mov   r1, r2
  mov   r2, #0
  mov   r3, #1
  bl    kx_music

  ldr   r1, =stream
  str   r0, [r1]
  bl    kx_music_start

  // svc   #0x0f
  // b     (. - 4)
  //

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
  ldr   r1, =label_text_2
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
  str   r0, [r1]  // Store texture ID in memory //mov (r1), r0

  mov   r0, r4
  bl    free

  mov   r4, #0

main_loop:
  svc   #0x10
  ldr   r4, =last_frame_time
  ldrd  r2, r3, [r4]
  strd  r0, r1, [r4] // 取出上一帧时刻，并把当前时刻存回去
  // 如果有上一帧时刻，则计算差值
  subs  r0, r2
  sbc   r1, r3 // r1, r0是delta time
  cmp   r2, #0
  cmpeq r3, #0
  moveq r0, #0
  moveq r1, #0 // 如果r2、r3都是0，则说明无上一帧，应当令差值为0
  ldr   r4, =game_time
  ldrd  r2, r3, [r4]
  adds  r2, r0
  adc   r3, r1 // 此时，r2、r3是游戏当前时间
  strd  r2, r3, [r4]
  mov   r0, r2
  mov   r1, r3
  // TODO 修改s0为从地图数据中读取
  vldrs s0, 128.0
  bl    game_time_to_tempo // 此时s0是拍号

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
  vldrs s0, 0.0  //s0 <- 0.0
  vldrs s1, 0.3

  ldr   r1, =0xffddddff
  vldrs s4, 0.6
  vldrs s5, 0.7

  cmp   r3, #0  // Is space key down?
  addeq r4, #1  //条件指令  if true
  subne r4, #1  // if false
  ldreq r2, =0xffddddff
  ldrne r2, =0xffeeccff
  vmov          s15, r4  //32位
  vcvt.f32.s32  s15, s15  //显式类型转换
  vldrs         s14, 0.001
  vmul.f32      s15, s14   //set the first operator as the destination
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

.section .text
game_time_to_tempo:
  // r0, r1 game time, s0 地图的tempo（浮点）
  // return s0 当前的拍号（tempo）
  vldrs s2, 65536.0
  vcvt.f64.f32  d0, s2
  vmul.f64  d0, d0 // d0=2^32
  vmov  s2, s3, r0, r1
  vcvt.f64.u32  d1, s3
  vmul.f64  d0, d1 // d0=r1*2^32
  vcvt.f64.u32  d1, s2
  vadd.f64  d0, d1 // d0=r1*2^32+r0
  vldrs s1, 1000000.0
  vcvt.f64.f32  d1, s1
  vcvt.f64.f32  d2, s0 // d2是bpm
  vldrs s3, 60.0
  vcvt.f64.f32  d3, s3
  vdiv.f64  d0, d0, d1
  vmul.f64  d0, d0, d2
  vdiv.f64  d0, d0, d3 // d0此时是us/100000*bpm/60，就是拍数了
  vcvt.f32.f64  s0, d0
  bx lr


.section .data
game_time: // 游戏进行期间的时间戳。游戏进行期间会每帧增长累加
  .int  0 // 低32位
  .int  0 // 高32位
last_frame_time: // 上一帧的时间戳。如果为0表示没有上一帧。
  .int  0 // 低32位
  .int  0 // 高32位
tex_first:
  .int  0
stream:
  .int  0
label:
  .int  0
label_text_1:
  .ascii "qwq\nqwq\nqwq\nqwq\nqwq\nqwq\0"
label_text_2:
  .ascii "kerning: hjAVA\nLorem ipsum dolor\n(> ~ <)\0"
