/*
  地图加载

  音频数据：Ogg Vorbis 格式，可传给 kx_music
  音符序列数据：无论是否有音符，每拍占据恰好一字节，依序存放
    高 4 位：头鸟领先的拍数
    低 4 位：音符（0 - 无；1 - 上；2 - 下；3 - 拍翅膀）
  装饰物数据：每个装饰物占 24 字节
    + 0：32-bit 整数，类型
    + 4：32-bit 浮点，横坐标（1 = 一拍中行进的距离）
    + 8：32-bit 浮点，纵坐标（1 = 一次上下移动的距离）
    +12：32-bit 浮点，景深（暂时忽略，具体算法未定）
    +16：32-bit 浮点，宽
    +20：32-bit 浮点，高
*/

.equ  OFF_TITLE,    0
.equ  OFF_AUDIO,    4
.equ  OFF_AUDIO_LEN,8
.equ  OFF_TEMPO,    12
.equ  OFF_AUDOFF,   16
.equ  OFF_SEQ,      20
.equ  OFF_SEQ_LEN,  24
.equ  OFF_DECOR,    28
.equ  OFF_DECOR_CNT,32

/*
  in  r0 - 地图数据地址
  out r0 - 标题字符串地址
      r1, r2 - 音频数据起始地址/长度
      r3, r4 - 音符序列起始地址/长度
      r5, r6 - 装饰物信息起始地址/数量
      s0 - 速度 (BPM)
      s1 - 音频偏移 (s)
  其余寄存器均保存
*/
.global map_loader
map_loader:
  push  {r7}
  mov   r7, r0

  ldr   r0, [r7, #OFF_TEMPO]
  ldr   r0, [r7, r0]
  vmov  s0, r0
  ldr   r0, [r7, #OFF_AUDOFF]
  ldr   r0, [r7, r0]
  vmov  s1, r0

  ldr   r0, [r7, #OFF_TITLE]
  add   r0, r7

  ldr   r1, [r7, #OFF_AUDIO]
  add   r1, r7
  ldr   r2, [r7, #OFF_AUDIO_LEN]

  ldr   r3, [r7, #OFF_SEQ]
  add   r3, r7
  ldr   r4, [r7, #OFF_SEQ_LEN]

  ldr   r5, [r7, #OFF_DECOR]
  add   r5, r7
  ldr   r6, [r7, #OFF_DECOR_CNT]

  pop   {r7}
  bx    lr
