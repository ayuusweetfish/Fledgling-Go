.include "common_macro.s"
.include "constants.s"

.global init_yBirdList
.global yBirdList
.global calBirdY

.section .text
init_yBirdList:
  // r0, r1 - 音符序列起始地址/长度
  // 不会修改任何寄存器
  push          {r1-r7}
  vpush         {s0}
  ldr           r6, =yBirdList // r6是dst的首地址
  mov           r7, #0 // r7是位置的整数
  mov           r2, #0
loop_iyb:
  cmp           r2, r1
  bge           end_iyb
  add           r4, r0, r2 // 要操作的音符byte的地址
  ldrb          r4, [r4]
  and           r4, #0xf // r4是地图值低4位
  cmp           r4, #1
  addeq         r7, #1
  cmp           r4, #2
  subeq         r7, #1
  lsl           r3, r2, #2
  add           r4, r6, r3 // 要写入的位置float地址
  vmov          s0, r7
  vcvt.f32.s32  s0, s0
  vstr          s0, [r4]
  add           r2, #1
  b             loop_iyb
end_iyb:
  // 为防止访问越界，把最后的r7值再在末尾多填充10次，以防lead鸟读取数组时候发生越界。
  add           r1, #10
loop2_iyb:
  cmp           r2, r1
  bge           end2_iyb
  lsl           r3, r2, #2
  add           r4, r6, r3 // 要写入的位置float地址
  vmov          s0, r7
  vcvt.f32.s32  s0, s0
  vstr          s0, [r4]
  add           r2, #1
  b             loop2_iyb
end2_iyb:
  vpop          {s0}
  pop           {r1-r7}
  bx            lr


getBirdYByInt:
  // 根据整数拍号获取其在birdYList中指定的数值。
  // 输入 r0 整数
  // 输出 s0 不改变其他寄存器，r0也不变
  push  {r0-r1}
  ldr   r1, =yBirdList
  lsl   r0, #2
  add   r0, r1
  vldr  s0, [r0] // s1是当前整数拍号的y坐标
  pop   {r0-r1}
  bx    lr

ANIM_LEN_NPC:
  .float  0.5
ANIM_LEN_PERFECT:
  .float  0.5
ANIM_LEN_GREAT:
  .float  0.5
ANIM_LEN_BUMP:
  .float  0.5


calBirdY:
  // 根据yBirdList算出在给定时刻的鸟应当处于的位置，内含0.5拍完成动作的qerp插值处理。
  // 计算规则是若在某拍的前0.5s则由上一拍位置过渡中，否则则完整呈现本拍位置
  // s0: 计算的基准时间点（拍）。如果是lead鸟，则应该传入一个比bttime大lead拍数的值；如果是落后鸟，则传入bttime减去相应的值。
  // return: s0: 当前时刻的带小数的y值， s1: 当前所处拍的整数的y值。
  // 更改s0-s4、r0-r1
  push          {lr}
  vldrs         s1, 0.0
  vcmpa.f32     s0, #0.0
  vmovlt        s0, s1
  bxlt          lr  // 如果时间值小于0，就直接返回0就好，

  bl            floor
  mov           s3, s1 // r0是当前拍号向下取整,s3是当前拍号的小数部分
  bl            getBirdYByInt
  vldr          s1, s0 // s1是当前整数拍号的y坐标

  cmp           r0, #0 // 如果在第0.x拍，则无过渡
  vmoveq        s2, s1
  subne         r1, #4 // 否则，取出上一拍坐标存进s2
  vldrne        s2, [r1]
  // 有过渡的条件：当前在本拍前0.5拍内，且本拍y值与上一拍不等
  vcmpa.f32     s2, s1
  beq           no_gradual
  vldr          s4, ANIM_LEN_NPC
  vcmpa.f32     s3, s4
  bge           no_gradual
  //有过渡
  vpush         {s1}
  vmov          s0, s2
  vldr          s4, ANIM_LEN_NPC
  vdiv.f32      s2, s3, s4
  bl            qerp
  vpop          {s1}
  b             ret_cby
no_gradual: // 无过渡，以整数y值作为最终答案
  vmov          s0, s1
ret_cby:
  pop           {lr}
  bx            lr

calMeY:
  push    {lr}
  ldr     r0, =st_pose
  vldr    s13, [r0] // s13是当前状态
  ldr     r0, =st_ago
  vldr    s13, [r0] // s12是st_ago
  bl      get_note
  mov     r0, r2
  bl      getBirdYByInt
  vmov    s15, s0 // s15是当前窗口期的y
  vldrs   s14, 0.0
  cmp     r0, #0
  subgt   r0, #1
  blgt    getBirdYByInt
  vmovgt  s14, s0  // s14是上一窗口期的y
cmy_pgb:
  // perfect\great\bump处理，因为目前都是从old插值到new，所以是等同的
  vldr      s3, ANIM_LEN_PERFECT
  cmp       s13, POSE_PERFECT
  vldrne    s3, ANIM_LEN_GREAT
  cmpne     s13, POSE_GREAT
  vldrne    s3, ANIM_LEN_BUMP
  cmpne     s13, POSE_BUMP
  bne       cmy_norplus
  vdiv.f32  s2, s12, s3
  mov       s0, s14
  mov       s1, s15
  bl        qerp
  mov       s1, s15
  b         cmy_end
cmy_norplus:
  // 其余所有状态，输出就是目标的位置即可
  mov       s0, s15
  mov       s1, s15
cmy_end:
  pop     {lr}
  bx      lr

.section .bss
.comm   yBirdList   8000 // 足够放2000个float的空间，第i个位置是表示在第i拍开始的时刻鸟应该在的位置。
