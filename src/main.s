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

  // 播放音乐
  mov   r0, r1
  mov   r1, r2
  mov   r2, #0
  mov   r3, #1
  bl    kx_music

  ldr   r1, =stream
  str   r0, [r1]
  bl    kx_music_start

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
  // TODO 修改s0为从地图数据中读取
  vldrs s0, 128.0
  bl    game_time_to_tempo // 此时s0是拍号
  ldr   r0, =bttime
  vstr  s0, [r0]

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
  vcvt.f64.f32  d0, s2
  vmul.f64      d0, d0 // d0=2^32
  vmov          s2, s3, r0, r1
  vcvt.f64.u32  d1, s3
  vmul.f64      d0, d1 // d0=r1*2^32
  vcvt.f64.u32  d1, s2
  vadd.f64      d0, d1 // d0=r1*2^32+r0
  vldrs         s1, 1000000.0
  vcvt.f64.f32  d1, s1
  vcvt.f64.f32  d2, s0 // d2是bpm
  vldrs         s3, 60.0
  vcvt.f64.f32  d3, s3
  vdiv.f64      d0, d0, d1
  vmul.f64      d0, d0, d2
  vdiv.f64      d0, d0, d3 // d0此时是us/100000*bpm/60，就是拍数了
  vcvt.f32.f64  s0, d0
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
