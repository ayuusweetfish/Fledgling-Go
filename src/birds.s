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
  vldrs         s4, 0.5
  vcmpa.f32     s3, s4
  bge           no_gradual
  //有过渡
  vpush         {s1}
  vmov          s0, s2
  vldrs         s4, 2.0
  vmul.f32      s2, s3, s4
  bl            qerp
  vpop          {s1}
  b             ret_cby
no_gradual: // 无过渡，以整数y值作为最终答案
  vmov          s0, s1
ret_cby:
  pop           {lr}
  bx            lr

ANIM_LEN_PERFECT:
  .float  0.5
ANIM_LEN_GREAT:
  .float  0.5
ANIM_LEN_BUMP:
  .float  0.5

calMeY:
  // 更改s0-s15、r0-r3
  // 准备数据
  push  {r4-r8, lr}
  ldr   r0, =meCurStdY
  vldr  s14, [r0] // s14是当前标准y
  ldr   r7, =st_ago
  vldr  s15, [r7] // s15是当前的st_ago
  ldr   r7, =st_pose
  ldr   r7, [r7] // r7是当前的st_pose
  // 另外规定s13是当前动画的length
  ldr   r0, =mePrevAgo
  vldr  s0, [r0]
  vstr  s15, [r0]
  ldr   r1, =mePrevPose
  ldr   r0, [r1]
  str   r7, [r1] // 更新mePrev两个变量为新的值
  ldr   r1, =bttime
  vldr  s28, [r1] // s28是bttime
  // 先检查是不是发生了状态变化，标准是当前状态与prev状态不一致，或者是ago发生了时光倒流。
  mov   r8, #0 // r8为0表示状态没变，为1表示状态变了
  cmp   r7, r0
  movne r8, #1
  vcmpa.f32 s15, s0
  movne r8, #1
cmy_per_gre: // perfect和great的处理逻辑
  // 先根据st_pose具体是什么，判断插值起点（meCAnimY）应该要设置为什么
  cmp     r7, POSE_PERFECT
  vldreq  s13, ANIM_LEN_PERFECT
  vldrne  s13, ANIM_LEN_GREAT
  cmpne   r7, POSE_GREAT
  bne     cmy_bump // 不是的话就测试下一个pose了

  cmp     r8, #1 // if状态改变，则调用设置插值起点为curstdy、更新curstdy为音符序列值、更新动画时间
  bne     cmy_per_gre2
  ldr     r0, =meCAnimY
  vstr    s14, [r0]  // perfect、great，meCAnimY设置为curstdy当前的值
  bl      syncMeCurStdY
  bl      syncMeCAnimTime
  b       cmy_per_gre4
cmy_per_gre2: // else if状态没变但有动画，更新animTime和处理动画

  bl        syncMeCAnimTime
  vdiv.f32  s0, s0, s13 // s0是动画进行的百分比
  vldrs     s1, 1.0
  vcmpa.f32 s0, s1
  blge      clearCAnimTime // 如果百分比大于100%，则清除动画状态
  // 无论如何，这次插值一定是要做的



cmy_per_gre3:

  beq     cmy_on_anim_begin
  cmp     r7, POSE_BUMP
  bleq    getCollisionBeginY // 碰撞，按照既定规则设置
  beq     cmy_on_anim_begin
  // 否则继续
  b       cmy_main
cmy_on_anim_begin:
  bl    syncMeCurStdY // 根据插值目的地设置curstdy
  bl    syncMeCAnimTime
cmy_main:
  ldr   r0, =meCAnimTime
  vldr  s0, [r0]
  vcmpa.f32 s0, #0.0
  beq   cmy_not_in_anim
  // 如果正在进行动画的过程中

cmy_not_in_anim:

  pop   {r4-r8, lr}
  bx    lr

BIRD_NO_COLLISION_RANGE_HALF_HEIGHT:
  .float  0.25

getCollisionBeginY:
  // 碰撞时直接修改插值起点值。不改变任何寄存器.输入：s28 bttime
  push      {r0-r1, lr}
  vpush     {s0-s4}
  vmov      s0, s28
  bl        calBirdY
  vmov      s4, s0 // s4是按照音符序列，应该在的位置
  vldr      s3, BIRD_NO_COLLISION_RANGE_HALF_HEIGHT
  vsub.f32  s1, s4, s3
  vadd.f32  s2, s4, s3 // s1、s2是推算出的不发生碰撞的上下界
  ldr       r1, =meCurStdY
  vstr      s0, [r1]  // s0是当前位置
  bl        clamp  // 最终结果就取当前位置clamp在上下界之间
  ldr       r1, =meCAnimY
  vstr      s0, [r1] // 把最终结果存回去
  vpop      {s0-s4}
  pop       {r0-r1, lr}
  bx        lr


syncMeCurStdY:
  // 把meCurStdY设置为当前的拍数对应yList中的值，不改变任何寄存器
  push    {r0-r3, lr}
  vpush   {s0}
  bl      get_note // r2是当前窗口期的拍号整数
  mov     r0, r2
  bl      getBirdYByInt
  ldr     r1, =meCurStdY
  vstr    s0, [r1]
  vpop    {s0}
  pop     {r0-r3, lr}
  bx      lr

syncMeCAnimTime:
  // 根据当前的ago设置meCAnimTime的值，会改变r0和s0！！输入：s15 ago, s28 bttime
  // 返回s0是动画已进行的时长（其实就是s15的值）
  vldr      r0, =meCAnimTime
  vsub.f32  s0, s28, s15
  vstr      s0, [r0]
  vmov      s0, s15
  bx        lr

clearCAnimTime:
  // 设置meCAnimTime为0。不改变寄存器。
  push      {r0}
  vpush     {s0}
  vldr      r0, =meCAnimTime
  vldrs     s0, 0.0
  vstr      s0, [r0]
  vpop      {s0}
  pop       {r0}
  bx        lr


.section .data
mePrevPose:  // 前一个状态
  .int    POSE_NORMAL
mePrevAgo:
  .float  0.0
meCAnimTime: // 当前正在进行的动画，在道理上其的动作发生（插值起点）时刻。如果值为0，表示当前没在进行动画。
  .float  0.0
meCAnimY:   // 当前正在进行的动画，y数值的插值起点。
  .float  0.0
meCurStdY:  // 标准意义下的当前位置。始终是整数，并且往往对应于当前动画结束后鸟应该在的地方、经常等于窗口期的y值
            // 修改此值为与yBirdList指示的值保持一致的时机：在great、perfect、bump事件发生，和无anim、不在窗口期的情况
  .float  0.0


.section .bss
.comm   yBirdList   8000 // 足够放2000个float的空间，第i个位置是表示在第i拍开始的时刻鸟应该在的位置。
