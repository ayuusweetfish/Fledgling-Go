.include "common_macro.s"
.include "constants.s"

.global cal_one_animseq
.global init_all_animseqs

.global animseq_perfect_sign
.global animseq_great_sign
.global animseq_bad_sign

.section .text
init_one_animseq:
  // 初始化一个动画序列。r0：animseq的地址。
  push  {r4, lr}
  mov   r4, r0
ioas_loop1:
  ldm   r4!, {r0-r1}
  cmp   r1, #-1
  bne   ioas_loop1
ioas_loop2:
  ldm   r4, {r0-r1}
  cmp   r0, #0
  beq   ioas_end2
  bl    kx_image
  str   r0, [r4]
  add   r4, #8
  b     ioas_loop2
ioas_end2:
  pop   {r4, lr}
  bx    lr


cal_one_animseq:
  // 计算某一个动画序列在给定的动画时刻所应该显示的纹理id，或者如果不应显示此动画，r1返回-1。
  // 输入：r0 动画序列 s0 时刻
  // 输出：r0 纹理id r1 要显示的图片的index，如果为-1表示该动画已经播放结束。shi
  push          {r8, lr}
  mov           r8, r0 // r8是正在遍历的动画序列的当前位置
coas_loop1:
  ldm           r8, {r0-r3}
  // 循环继续条件：第一个时间段仍然有效（int不是-1），且第二个时间段不大于当前时间
  vmov          s1, r1
  vmov          s2, r2
  vcmpa.f32     s0, s2
  cmpge         r1, #0
  addge         r8, #8
  bge           coas_loop1
coas_end1:
  cmp           r1, #-1
  beq           coas_loop2 // 如果第一段是-1，超出后面界限，return
  vcmpa.f32     s0, s1 // 如果当前时刻小于段的起始时刻，说明超出前面界限，return -1
  movlt         r1, #-1
  blt           coas_loop2
  cmp           r3, #-1
  moveq         r3, r1
  cmp           r3, r1
  beq           coas_loop2

  vmov          s1, r0
  vsub.f32      s2, s1
  vsub.f32      s0, s1
  vdiv.f32      s0, s0, s2
  sub           r3, r1
  vmov          s2, r3
  vcvt.f32.s32  s2, s2
  vmul.f32  s0, s2
  bl            floor_f32
  cmp           r0, r3
  subge         r0, r3, #1 // 如果floor出来的r0大于等于r3，则就会发生访问越界了，应该强制避免
  add           r1, r0

  // 到此处，r1就是图片index了。接下来是找出r0。
  // 先让r8移动到第一个资源字节处
coas_loop2:
  ldm           r8!, {r2-r3}
  cmp           r3, #-1
  bne           coas_loop2
coas_end2:
  mov           r2, #8
  mul           r0, r1, r2
  add           r8, r0 // r8是实际的texture id所在位置的地址
  ldr           r0, [r8]
  pop           {r8, lr}
  bx            lr


init_all_animseqs:
  push    {lr}
  // 在这里依次把每个animseq的地址放进r0里后调用init_one_animseq
  ldr     r0, =animseq_upset
  bl      init_one_animseq
  ldr     r0, =animseq_flap
  bl      init_one_animseq
  ldr     r0, =animseq_flap_ready
  bl      init_one_animseq
  ldr     r0, =animseq_bump
  bl      init_one_animseq
  ldr     r0, =animseq_lean
  bl      init_one_animseq
  ldr     r0, =animseq_perfect_sign
  bl      init_one_animseq
  ldr     r0, =animseq_great_sign
  bl      init_one_animseq
  ldr     r0, =animseq_bad_sign
  bl      init_one_animseq
  pop     {lr}
  bx      lr

.global animseq_upset
.global animseq_bump
.global animseq_flap_ready
.global animseq_flap
.global animseq_lean

.section .data
// 每一个动画由一组数据表示，其中的每一个数据都是时间点和序列帧id构成的。
// 序列中每个元素的时间点必须保持单调严格增（除了最后一个与-1之间）。
// 具体某一时刻显示的序列帧，将取决于那一时刻前后的两个节点做插值来得到。
// 任何一个序列必须以帧id -1来结束！！在那之后，跟上若干的成对int，是资源的地址和size。
// 最后一个资源后面必须跟着.int 0表示结束。
animseq_upset:
  .float  0.0 // 时间点
  .int    0   // 帧id
  .float  0.5
  .int    -1  // 表示结束
  importres upset_0_png
  .int    0  // 表示结束

animseq_bump:
  .float  0.0 // 时间点
  .int    0   // 帧id
  .float  0.5
  .int    -1  // 表示结束
  importres bump_0_png
  .int    0  // 表示结束

animseq_flap:
  .float  0.0 // 时间点
  .int    0   // 帧id
  .float  0.5
  .int    5
  .float  0.5
  .int    -1  // 表示结束
  importres flap_0_png
  importres flap_1_png
  importres flap_2_png
  importres flap_3_png
  importres flap_4_png
  .int    0  // 表示结束

animseq_flap_ready:
  .float  0.0 // 时间点
  .int    0   // 帧id
  .float  0.5
  .int    -1  // 表示结束
  importres flap_ready_0_png
  .int    0  // 表示结束

animseq_lean:
  .float  0.0 // 时间点
  .int    0   // 帧id
  .float  0.5
  .int    -1  // 表示结束
  importres lean_0_png
  .int    0  // 表示结束

animseq_perfect_sign:
  .float  0.0 // 时间点
  .int    0   // 帧id
  .float  0.6
  .int    6
  .float  0.6
  .int    -1  // 表示结束
  importres perfectanim_0_png
  importres perfectanim_1_png
  importres perfectanim_0_png
  importres perfectanim_1_png
  importres perfectanim_0_png
  importres perfectanim_1_png
  .int    0  // 表示结束

animseq_great_sign:
  .float  0.0 // 时间点
  .int    0   // 帧id
  .float  0.6
  .int    6
  .float  0.6
  .int    -1  // 表示结束
  importres greatanim_0_png
  importres greatanim_1_png
  importres greatanim_0_png
  importres greatanim_1_png
  importres greatanim_0_png
  importres greatanim_1_png
  .int    0  // 表示结束

animseq_bad_sign:
  .float  0.0 // 时间点
  .int    0   // 帧id
  .float  0.5
  .int    -1  // 表示结束
  importres _32573487_png
  .int    0  // 表示结束

