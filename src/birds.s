.include "common_macro.s"
.include "constants.s"

.global init_yBirdList
.global yBirdList
.global calBirdY
.global drawBirds
.global init_birdTexture
.global getBirdYByInt
.global curLead
.global curSeqY
.global curNpcY
.global curMeY

.section .text
init_yBirdList:
  // r0, r1 - 音符序列起始地址/长度
  // 不会修改任何寄存器
  push          {r1-r7}
  vpush         {s0}
  ldr           r6, =yBirdList // r6是dst的首地址
  mov           r7, #0 // r7是位置的整数
  mov           r2, #0
  //把初始的lead填入curLead
  ldrb          r4, [r0]
  lsr           r4, #4 // 右移4位就是领先数量了
  vmov          s0, r4
  vcvt.f32.s32  s0, s0
  ldr           r4, =curLead
  vstr          s0, [r4]
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
  // 规定负数区间坐标为0
  // 输入 r0 整数
  // 输出 s0 不改变其他寄存器，r0也不变
  cmp   r0, #0
  vldrs s0, 0.0
  bxlt  lr // 如果是负数，返回坐标0.0
  push  {r0-r1}
  cmp   r0, #0
  movlt r0, #0
  ldr   r1, =yBirdList
  lsl   r0, #2
  add   r0, r1
  vldr  s0, [r0] // s1是当前整数拍号的y坐标
  pop   {r0-r1}
  bx    lr


init_birdTexture:
  // 创建纹理
  push  {lr}
  ldr   r0, =otherbirds_0_png
  ldr   r1, =otherbirds_0_png_size
  bl    kx_image
  ldr   r3, =idtx_otherbird0
  str   r0, [r3]
  ldr   r0, =otherbirds_1_png
  ldr   r1, =otherbirds_1_png_size
  bl    kx_image
  ldr   r3, =idtx_otherbird1
  str   r0, [r3]
  ldr   r0, =otherbirds_2_png
  ldr   r1, =otherbirds_2_png_size
  bl    kx_image
  ldr   r3, =idtx_otherbird2
  str   r0, [r3]
  ldr   r0, =normal_0_png
  ldr   r1, =normal_0_png_size
  bl    kx_image
  ldr   r3, =idtx_mebird0
  str   r0, [r3]
  ldr   r0, =normal_1_png
  ldr   r1, =normal_1_png_size
  bl    kx_image
  ldr   r3, =idtx_mebird1
  str   r0, [r3]
  pop   {lr}
  bx    lr

hereBirdIdxMe:
  push  {lr}
  vpush {s0-s1}
  ldr   r0, =st_time
  vldr  s0, [r0]
  vldrs s1, 4.0
  vdiv.f32  s0, s0, s1
  bl    floor_f32
  vldrs s0, 0.5
  vcmpa.f32 s1, s0
  movle r0, #0
  movgt r0, #1
  vpop  {s0-s1}
  pop   {lr}
  bx    lr

hereBirdIdxOther:
  push  {lr}
  vpush {s0-s1}
  ldr   r0, =st_time
  vldr  s0, [r0]
  vldrs s1, 4.0
  vdiv.f32  s0, s0, s1
  bl    floor_f32
  vldrs s0, 0.3333
  vcmpa.f32 s1, s0
  movle r0, #0
  ble   hbio_ret
  vldrs s0, 0.6667
  vcmpa.f32 s1, s0
  movle r0, #1
  movgt r0, #2
hbio_ret:
  vpop  {s0-s1}
  pop   {lr}
  bx    lr

getBirdTexture:
  // 对于一只给定的鸟，根据当前的状态计算其的纹理。
  // r0-r3分别表示类别 x offset、y offset、mode
  // 返回r0:纹理id。s0 s1 图片偏移 s2 s3 图片缩放。保证不改变除了r0和s0-s3的任何寄存器，包括r1-r3也维持其输入值。
  vpush   {s4-s7}
  vpush   {s14-s15}
  push    {r1-r9, lr} //sp是x，sp+4是y，sp+8是mode， 即分别是r1-r3
  ldr     r9, =st_ago
  vldr    s15, [r9] // s15是st_ago
  ldr     r9, =st_upset
  vldr    s14, [r9] // s14是st_upset
  ldr     r9, =st_pose
  ldr     r9, [r9] // r9是st_pose
  mov     r8, r0 // r8是种类
  bl      get_note
  mov     r7, r0 // r7是音符
  mov     r6, #-1 // r6承接最终返回值
  // s4-s7对应于最终返回值的s0-s3
// 自己鸟的部分
gbdtx_me:
  cmp     r8, #BIRD_TYPE_ME
  bne     gbdtx_npc
gbdtx_me_upset:
  ldr     r0, =animseq_upset // 考虑upset
  vmov    s0, s14
  bl      cal_one_animseq
  cmp     r1, #-1
  movne   r6, r0
  bne     gbdtx_end
gbdtx_me_bump:
  cmp     r9, #POSE_BUMP // 考虑bump
  bne     gbdtx_me_ready
  ldr     r0, =animseq_bump
  vmov    s0, s15
  bl      cal_one_animseq
  cmp     r1, #-1
  movne   r6, r0
  bne     gbdtx_end
  b       gbdtx_me_default
gbdtx_me_ready:
  cmp     r9, #POSE_READY_UP // 考虑READY
  cmpne   r9, #POSE_READY_DOWN
  bne     gbdtx_me_flap_perfect
  ldr     r0, =animseq_flap_ready
  vmov    s0, s15
  bl      cal_one_animseq
  cmp     r1, #-1
  movne   r6, r0
  bne     gbdtx_end
  b       gbdtx_me_default
gbdtx_me_flap_perfect:
  cmp     r9, #POSE_FLAP_PERFECT // 考虑PERFECT
  bne     gbdtx_me_flap_great
  ldr     r0, =animseq_flap_perfect
  vmov    s0, s15
  bl      cal_one_animseq
  cmp     r1, #-1
  movne   r6, r0
  bne     gbdtx_end
  b       gbdtx_me_default
gbdtx_me_flap_great:
  cmp     r9, #POSE_FLAP_GREAT // 考虑great
  bne     gbdtx_me_default
  ldr     r0, =animseq_flap_great
  vmov    s0, s15
  bl      cal_one_animseq
  cmp     r1, #-1
  movne   r6, r0
  bne     gbdtx_end
  b       gbdtx_me_default
gbdtx_me_default:
  ldr     r6, =idtx_mebird0
  bl      hereBirdIdxMe
  mov     r1, #4
  mul     r0, r1
  add     r6, r0
  ldr     r6, [r6]
  b       gbdtx_end

// npc鸟的部分（也就是其余鸟的部分）
gbdtx_npc:
gbdtx_npc_lean:
  cmp     r9, #POSE_BUMP // 考虑bump
  bne     gbdtx_npc_default
  vldm    sp, {s0-s1} // s0是x、s1是y
  // 向上音符，下面鸟做动画
  vldrs   s2, -1.0
  ldr     r0, =last_valid_note
  ldr     r0, [r0]
  cmp     r0, #1
  vcmpeq.f32  s0, #0.0
  vmrs    APSR_nzcv, FPSCR
  vcmpeq.f32  s1, s2
  vmrs    APSR_nzcv, FPSCR
  beq     gbdtx_npc_lean_true
  // 向下音符，上面鸟做动画
  vldrs   s2, 1.0
  ldr     r0, =last_valid_note
  ldr     r0, [r0]
  cmp     r0, #2
  vcmpeq.f32  s0, #0.0
  vmrs    APSR_nzcv, FPSCR
  vcmpeq.f32  s1, s2
  vmrs    APSR_nzcv, FPSCR
  beq     gbdtx_npc_lean_true
  bne     gbdtx_npc_default
gbdtx_npc_lean_true: // 真的是要斜眼的鸟
  ldr     r0, =animseq_lean
  vmov    s0, s15
  bl      cal_one_animseq
  cmp     r1, #-1
  movne   r6, r0
  bne     gbdtx_end
  b       gbdtx_npc_default
gbdtx_npc_default:
  ldr     r6, =idtx_otherbird0
  bl      hereBirdIdxOther
  mov     r1, #4
  mul     r0, r1
  add     r6, r0
  ldr     r6, [r6]
  b       gbdtx_end
gbdtx_end:
  mov     r0, r6
  pop     {r1-r9, lr}
  vpop    {s14-s15}
  vmov    s0, s4
  vmov    s1, s5
  vmov    s2, s6
  vmov    s3, s7
  vpop    {s4-s7}
  bx      lr

BIRD_TEX_ZOOM_RATE:
  .float  0.7 // 在其bounding box内实际绘制图片的占比

drawBirds:
  push          {r8-r9, lr}
  vpush         {s31}
  ldr           r1, =st_time
  vldr          s31, [r1] // s31是时间
  ldr           r1, =birdsCount
  ldr           r7, [r1] // r7是count
  mov           r6, #0 // r6是循环变量
  ldr           r9, =birds // r9是birds的指针  // r8是纹理id
  // 算一次birdY数值，存起来
  vmov          s0, s31
  bl            calBirdY
  ldr           r1, =curNpcY
  vstr          s0, [r1]
  ldr           r1, =curSeqY
  vstr          s1, [r1]
inib_loop1:
  cmp           r6, r7
  bge           inib_l1_end
  ldm           r9!, {r0-r3}
  mov           r5, r0 // r5表示类别；r1-r3分别表示x offset、y offset、mode 其中x y offset已经是浮点数格式了！
  vmov          s8, r1 // s8是x offset
  vmov          s9, r2 // s9是y offset
  // 计算纹理贴图
  bl            getBirdTexture
  mov           r8, r0
  //默认处理：s8变为绝对的x(st_time+offset)、s9变为绝对的y(绝对x算出绝对y+offset)
  vadd.f32      s8, s31
  vmov          s0, s8
  bl            calBirdY
  vadd.f32      s9, s0
  // 分类别处理
inib_tp_me: // me：y由calMeY决定
  cmp           r5, #BIRD_TYPE_ME
  bne           inib_tp_lead
  bl            calMeY
  vmov          s9, s0
  b             inib_tp_end
inib_tp_lead: // lead：调用calHeadBirdXAndUpdateCurLead算出领先距离追加到x(s8)上，并以新的x重算y
  cmp           r5, #BIRD_TYPE_LEAD
  bne           inib_tp_end
  bl            calHeadBirdXAndUpdateCurLead
  vadd.f32      s8, s0
  vmov          s0, s8
  bl            calBirdY
  vmov          s9, s0
  b             inib_tp_end
inib_tp_end:
  // 万事俱备，开始绘制
  vmov          s1, s9
  vmov          s0, s8
  vldrs         s2, 0.0 // z暂时都是0.0
  vldrs         s3, 1.0
  vldrs         s4, 1.0 // 画全图，宽高都是0.0
  mov           r3, r8 // 指定纹理
  vldr          s5, BIRD_TEX_ZOOM_RATE
  vldr          s6, BIRD_TEX_ZOOM_RATE
  bl            keepImgSquare
  bl            rect_zoom_anchor_center
  bl            coord_g2s_rect
  bl            fillSWhenDrawFullTexture
  bl            draw_square // 画
  add           r6, #1
  b             inib_loop1
inib_l1_end:
  vpop          {s31}
  pop           {r8-r9, lr}
  bx            lr



ANIM_LEN_NPC:
  .float  0.5
ANIM_LEN_PERFECT:
  .float  0.5
ANIM_LEN_GREAT:
  .float  0.5
ANIM_LEN_BUMP:
  .float  0.5

LEAN_EYE_BEFORE: // 对于向上/向下飞的动作，要在多长时间之前予以斜眼。
  .float 0.5

calBirdY:
  // 根据yBirdList算出在给定时刻的鸟应当处于的位置，内含0.5拍完成动作的qerp插值处理。
  // 计算规则是若在某拍的前0.5s则由上一拍位置过渡中，否则则完整呈现本拍位置
  // s0: 计算的基准时间点（拍）。如果是lead鸟，则应该传入一个比st_time大lead拍数的值；如果是落后鸟，则传入st_time减去相应的值。
  // return: s0: 当前时刻的带小数的y值， s1: 当前所处拍的整数的y值。 r0: 是否斜眼，0不斜眼1向上2向下
  // 更改s0-s4
  push          {r1, lr}
  vldrs         s1, 0.0
  vpush         {s0}

  vcmpa.f32     s0, #0.0
  vmovlt        s0, s1
  blt           cby_fin // 如果时间值小于0，则固定的返回y值为0

  bl            floor_f32
  vmov          s3, s1 // r0是当前拍号向下取整,s3是当前拍号的小数部分
  bl            getBirdYByInt
  vmov          s1, s0 // s1是当前整数拍号所对应的的y坐标，一定是个整数

  sub           r0, #1
  bl            getBirdYByInt
  vmov          s2, s0 // 取出上一拍坐标存进s2
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
  b             cby_fin
no_gradual: // 无过渡，以整数y值作为最终答案
  vmov          s0, s1
cby_fin:
  vpop          {s2}
  vpush         {s0-s1}
  vmov          s0, s2
  vldr          s2, LEAN_EYE_BEFORE
  vadd.f32      s0, s2
  bl            floor
  bl            getBirdYByInt
  vmov          s2, s0 // s2是斜眼后推时刻的标准整数位置
  vpop          {s0-s1}
  vcmpa.f32     s2, s1
  moveq         r0, #0
  movgt         r0, #1
  movlt         r0, #2
  pop           {r1, lr}
  bx            lr

calMeY:
  // 修改r0-r4、s0-s3、s12-s15
  push    {lr}
  ldr     r0, =st_pose
  ldr     r4, [r0] // r4是当前状态
  ldr     r0, =st_ago
  vldr    s12, [r0] // s12是st_ago
  bl      get_note
  cmp     r0, #0
  ldr     r1, =last_valid_note
  strne   r0, [r1]
  mov     r0, r2
  bl      getBirdYByInt
  vmov    s15, s0 // s15是当前窗口期的y
  sub     r0, #1
  bl      getBirdYByInt
  vmov    s14, s0  // s14是上一窗口期的y
cmy_pgb:
  // perfect\great\bump处理，因为目前都是从old插值到new，所以是等同的
  vldr      s3, ANIM_LEN_PERFECT
  cmp       r4, #POSE_MOV_PERFECT
  vldrne    s3, ANIM_LEN_GREAT
  cmpne     r4, #POSE_MOV_GREAT
  vldrne    s3, ANIM_LEN_BUMP
  cmpne     r4, #POSE_BUMP
  bne       cmy_norplus
  vdiv.f32  s2, s12, s3
  vmov      s0, s14
  vmov      s1, s15
  bl        qerp
  vmov      s1, s15
  b         cmy_end
cmy_norplus: // 其余所有状态：
  vmov      s1, s15
  cmp       r1, #0
  vmovne    s0, s14 // 如果在窗口期内，输出前一窗口期的位置
  vmoveq    s0, s15 // 否则，输出当前窗口期的位置
cmy_end:
  ldr       r1, =curMeY
  vstr      s0, [r1]
  pop       {lr}
  bx        lr


HEADBIRD_X_DELTAMAX: // 每一拍，头鸟lead允许变化的最大值
  .float  1.0

calHeadBirdXAndUpdateCurLead:
  // 计算实际绘制时头鸟领先于标准点的距离，并更新curLead。return s0。
  // 修改r0-r1、s0-s3
  push          {lr}
  ldr           r0, =st_time
  vldr          s0, [r0]
  bl            floor_f32
  ldr           r1, =map_seq
  ldr           r1, [r1]
  // 如果时间小于0，视为0
  cmp           r0, #0
  movlt         r0, #0
  add           r1, r0
  ldrb          r1, [r1]
  lsr           r1, #4
  vmov          s0, r1
  vcvt.f32.s32  s0, s0 // 此时s0是当前的lead
  ldr           r0, =curLead
  vldr          s1, [r0] // s1是老的curLead
  vcmpa.f32     s0, s1
  popeq         {lr}
  bxeq          lr // 相等就直接返回
  // 计算允许的变化量的最大值
  vldrs         s2, 60.0
  ldr           r1, =FPS
  vmov          s3, r1
  vcvt.f32.s32  s3, s3 // s3是FPS的浮点数形式
  vmul.f32      s2, s3
  ldr           r1, =map_bpm
  vldr          s3, [r1]
  vdiv.f32      s2, s2, s3
  vldr          s3, HEADBIRD_X_DELTAMAX
  vdiv.f32      s3, s3, s2 // s3是允许的变化量的最大值
  vadd.f32      s2, s1, s3
  vsub.f32      s1, s1, s3
  bl            clamp // 应当让返回的s0，是正常的lead clamp在允许变化区间之内的值。
  vstr          s0, [r0] // 新的值写回curLead
  pop           {lr}
  bx            lr



.section .data
curLead:
  .float  0.0
curSeqY:
  .float  0.0
curNpcY:
  .float  0.0
curMeY:
  .float  0.0

birdsCount: //鸟的列表，count是个数。
  .int    5
birds:
bird_me:
  .int    BIRD_TYPE_ME
  .float  0.0 // x方向的相对标准位置的偏移
  .float  0.0 // y方向的相对标准位置的偏移
  .int    0 // mode
bird_head:
  .int    BIRD_TYPE_LEAD
  .float  0.0 // lead鸟必须写成0
  .float  0.0 // y方向的相对标准位置的偏移
  .int    0 // mode
bird_1:
  .int    BIRD_TYPE_NPC
  .float  0.0 // x方向的相对标准位置的偏移
  .float  1.0 // y方向的相对标准位置的偏移
  .int    0 // mode
bird_2:
  .int    BIRD_TYPE_NPC
  .float  0.0 // x方向的相对标准位置的偏移
  .float  -1.0 // y方向的相对标准位置的偏移
  .int    0 // mode
bird_3:
  .int    BIRD_TYPE_NPC
  .float  -1.0 // x方向的相对标准位置的偏移
  .float  0.0 // y方向的相对标准位置的偏移
  .int    0 // mode

idtx_mebird:
  .int    0
idtx_npcbird:
  .int    0

idtx_otherbird0:
  .int    0
idtx_otherbird1:
  .int    0
idtx_otherbird2:
  .int    0
idtx_mebird0:
  .int    0
idtx_mebird1:
  .int    0

.section .data
last_valid_note:
  .int    0

.section .bss
.comm   yBirdList   8000 // 足够放2000个float的空间，第i个位置是表示在第i拍开始的时刻鸟应该在的位置。
