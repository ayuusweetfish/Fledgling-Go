.include "common_macro.s"
.include "constants.s"

.global bttime

.section .text.startup
  bl    _crt_init

  ldr   r0, =stray_bin
  bl    map_loader
  p   // 检查 r0-r6
  ps  // 检查 s0-s1
  l   // 输出标题

  push  {r0-r1}
  ldr   r0, =map_bpm
  vstr  s0, [r0]

  mov   r0, r3
  mov   r1, r4
  bl    init_yBirdList
  pop   {r0-r1}

  // 播放音乐
  mov   r0, r1
  mov   r1, r2
  mov   r2, #0
  mov   r3, #1
  bl    kx_music

  ldr   r1, =stream
  str   r0, [r1]
  bl    kx_music_start

  // 创建一只鸟，把纹理id保存好
  ldr   r0, =npcbird_png
  ldr   r1, =npcbird_png_size
  bl    kx_image
  ldr   r3, =idtx_npcbird
  str   r0, [r3]


main_loop:
  ldr   r0, =#0xffffeeff
  svc   #0x100

  svc   #0x10
  ldr   r4, =last_frame_systime
  ldrd  r2, r3, [r4]
  strd  r0, r1, [r4] // 取出上一帧时刻，并把当前时刻存回去
  // 如果有上一帧时刻，则计算差值
  subs  r0, r2
  sbc   r1, r3 // r1, r0是delta time
  cmp   r2, #0
  cmpeq r3, #0
  moveq r0, #0
  moveq r1, #0 // 如果r2、r3都是0，则说明无上一帧，应当令差值为0
  ldr   r4, =game_systime
  ldrd  r2, r3, [r4]
  adds  r2, r0
  adc   r3, r1 // 此时，r2、r3是游戏当前时间
  strd  r2, r3, [r4]
  mov   r0, r2
  mov   r1, r3
  ldr   r5, =map_bpm
  vldr  s0, [r5]
  bl    game_time_to_tempo
  ldr   r0, =bttime
  vstr  s0, [r0] // s24是拍号
  vmov  s24, s0

  // 示例代码：画出上面创建的唯一一支鸟
  // 计算鸟的y坐标
  vmov  s0, s24 // 直接拿拍号当作基准时间，玩家鸟
  bl    calBirdY
  vmov  s1, s0
  vmov  s0, s24
  vldrs s2, 0.0
  vldrs s3, 1.0
  vldrs s4, 1.0
  bl    coord_g2s_rect
  bl    fillSWhenDrawFullTexture
  ldr   r3, =idtx_npcbird
  ldr   r3, [r3]
  pm
  ps
  bl    draw_square

  // Update audio
  ldr   r1, =stream
  ldr   r0, [r1]
  bl    kx_music_update

  svc   #0x10f  // End frame
  b     main_loop


game_time_to_tempo:
  // r0, r1 game time, s0 地图的tempo（浮点）
  // return s0 当前的拍号（tempo）
  vldrs         s2, 65536.0
  vcvt.f64.f32  d2, s2
  vmul.f64      d2, d2 // d2=2^32
  vmov          s2, s3, r0, r1
  vcvt.f64.u32  d3, s3
  vmul.f64      d2, d3 // d2=r1*2^32
  vcvt.f64.u32  d3, s2
  vadd.f64      d2, d3 // d2=r1*2^32+r0

  vldrs         s1, 1000000.0
  vcvt.f64.f32  d3, s1
  vdiv.f64      d2, d2, d3 // 除以一百万，化为s
  vcvt.f64.f32  d3, s0
  vmul.f64      d2, d2, d3 // 乘以bpm
  vldrs         s1, 60.0
  vcvt.f64.f32  d3, s1
  vdiv.f64      d2, d2, d3 // d0此时是us/100000*bpm/60，就是拍数了
  vcvt.f32.f64  s0, d2
  bx            lr


.section .data
game_systime: // 游戏进行期间的时间戳。游戏进行期间会每帧增长累加
  .int  0 // 低32位
  .int  0 // 高32位
last_frame_systime: // 上一帧的时间戳。如果为0表示没有上一帧。
  .int  0 // 低32位
  .int  0 // 高32位
bttime: // 游戏当前的用拍号表示的时间
  .float  0
stream:
  .int  0
map_bpm:
  .float  0.0
idtx_npcbird:
  .int  0
