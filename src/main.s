.include "common_macro.s"
.include "constants.s"

.global map_seq
.global map_bpm
.global map_deco
.global map_deco_len

.section .text.startup
  bl    _crt_init

  ldr   r0, =stray_bin
  bl    map_loader

  push  {r0-r1}
  ldr   r0, =map_bpm
  vstr  s0, [r0]
  ldr   r0, =map_audio_offset
  vstr  s1, [r0]
  ldr   r0, =map_seq
  str  r3, [r0]
  ldr   r0, =map_seq_len
  str  r4, [r0]
  ldr   r0, =map_deco
  str  r5, [r0]
  ldr   r0, =map_deco_len
  str  r6, [r0]

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

  // 设置音量
  ldr   r0, =0
  ldr   r1, =0x40000000
  ldr   r2, =0
  svc   #0x211  // trk_config
  ldr   r0, =1
  ldr   r1, =0x40000000
  ldr   r2, =0
  svc   #0x211  // trk_config

  bl    sfx_init

  // 创建鸟们
  bl    init_birdTexture
  bl    init_all_animseqs
  bl    init_decorations
  bl    init_birdPlus
  bl    init_label

main_loop:
  ldr   r0, =#0xffffeeff
  svc   #0x100

  // NOTE (lsq 11.07): debug use only
  // bl    get_input
  // pm
  // bl    get_note
  // pm

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
  ldr   r5, =map_audio_offset
  vldr  s1, [r5]
  bl    game_time_to_tempo
  ldr   r0, =st_time
  vstr  s0, [r0]
  vmov  s24, s0  // s24是以拍为单位的时间

  bl    state_update

  // NOTE (zyn 11.07): debug查看输出状态
/*
  ldr r4, =st_pose
  ldr r4, [r4]
  ldr r1, =st_ago
  vldr s0, [r1]
  ldr r1, =st_upset
  vldr s1, [r1]
  ps  // s0 = ago, s1 = upset
  vcmpa.f32 s1, #0
  svclt #0xf
  bl get_note
*/
  // NOTE: 有声音时输出寄存器，r0-r4 表示声音
  ldr r0, =st_s_perfect
  ldrb r0, [r0]
  ldr r1, =st_s_great
  ldrb r1, [r1]
  ldr r2, =st_s_bump
  ldrb r2, [r2]
  ldr r3, =st_s_upset
  ldrb r3, [r3]
  ldr r4, =st_s_flap
  ldrb r4, [r4]
  mov r6, r0
  orr r6, r1
  orr r6, r2
  orr r6, r3
  orr r6, r4
  cmp r6, #0
  svcne #0x0

  bl    sfx_update

  bl    tryPlayStarAccordingToStSound

  // 画装饰物
  bl    drawDecorations

  bl    cam_move_update

  bl    drawReminder

  // 画鸟们
  bl    drawBirds

  bl    drawStar

  bl    drawSign

  bl    drawLabel

  // Update audio
  ldr   r1, =stream
  ldr   r0, [r1]
  bl    kx_music_update

  svc   #0x10f  // End frame

vldrs   s23, 0.3
vcmpa.f32 s24, s23
//svcge   #0x0f

  b     main_loop


game_time_to_tempo:
  // r0, r1 game time, s0 地图的tempo（浮点）, s1 音频偏移
  // return s0 当前的拍号（tempo）
  vldrs         s2, 65536.0
  vcvt.f64.f32  d2, s2
  vmul.f64      d2, d2 // d2=2^32
  vmov          s2, s3, r0, r1
  vcvt.f64.u32  d3, s3
  vmul.f64      d2, d3 // d2=r1*2^32
  vcvt.f64.u32  d3, s2
  vadd.f64      d2, d3 // d2=r1*2^32+r0

  vldrs         s2, 1000000.0
  vcvt.f64.f32  d3, s2
  vdiv.f64      d2, d2, d3 // 除以一百万，化为s
  vcvt.f64.f32  d3, s0
  vcvt.f64.f32  d4, s1
  vsub.f64      d2, d4     // 减去偏移
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
stream:
  .int  0
map_bpm:
  .float  0.0
map_audio_offset:
  .float  0.0
map_seq: // 音符序列的首地址
  .int 0
map_seq_len: // 音符序列的长度，也就对应于全曲拍数。
  .int 0
map_deco:
  .int 0
map_deco_len:
  .int 0

