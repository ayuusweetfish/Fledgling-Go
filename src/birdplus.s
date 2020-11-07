.include "common_macro.s"
.include "constants.s"

.global drawReminder
.global drawSign
.global init_birdPlus

.section .text
init_birdPlus:
  // 初始化reminder
  push  {lr}
  ldr   r0, =idtx_upReminder
  bl    init_imported_res
  ldr   r0, =idtx_downReminder
  bl    init_imported_res
  ldr   r0, =idtx_flapReminder
  bl    init_imported_res
  pop   {lr}
  bx    lr

drawReminder:
  // 画reminder。修改r0-r4、s0-s7。
  push      {r5-r6, lr}
  ldr       r0, =st_time
  vldr      s0, [r0]
  bl        floor_f32
  mov       r6, r0 // r6自己时间取整
  ldr       r0, =curLead
  vldr      s1, [r0]
  vadd.f32  s0, s1
  bl        floor_f32
  mov       r7, r0 // r7头鸟时间取整
  ldr       r5, =map_seq
  ldr       r5, [r5] // r5地图序列
  // 规则：所有在自己时间和头鸟时间之间的音符，都要画出。
  add       r6, #1
drrmd_loop:
  cmp       r6, r7
  bgt       drrmd_end
  sub       r0, r6, #1
  bl        getBirdYByInt // s0是y坐标
  cmp       r6, #0
  addge     r0, r5, r6
  ldrgeb    r0, [r0]
  andge     r0, #0xf // r0是音符
  movlt     r0, #0
drrmd_up:
  cmp       r0, #1
  bne       drrmd_down
  ldr       r3, =idtx_upReminder
  ldr       r3, [r3]
  b         drrmd_draw
drrmd_down:
  cmp       r0, #2
  bne       drrmd_flap
  ldr       r3, =idtx_downReminder
  ldr       r3, [r3]
  b         drrmd_draw
drrmd_flap:
  cmp       r0, #3
  bne       drrmd_loopfinal
  ldr       r3, =idtx_flapReminder
  ldr       r3, [r3]
  b         drrmd_draw
drrmd_draw:
  vmov          s1, s0
  vmov          s0, r6
  vcvt.f32.s32  s0, s0
  vldrs         s2, 0.0 // z暂时都是0.0
  vldrs         s3, 1.0
  vldrs         s4, 1.0 // 画的宽和高！
  bl            coord_g2s_rect
  bl            fillSWhenDrawFullTexture
  bl            draw_square // 画
drrmd_loopfinal:
  add           r6, #1
  b             drrmd_loop
drrmd_end:
  pop       {r5-r6, lr}
  bx        lr


SIGN_OFFSET_X:
  .float    1.0
SIGN_OFFSET_Y:
  .float    1.0
SIGN_WIDTH:
  .float    1.0
SIGN_HEIGHT:
  .float    1.0

drawSign:
// 画sign。修改r0-r4、s0-s7。
  push      {r5-r6, lr}
  ldr       r0, =st_ago
  vldr      s0, [r0] // s0ago
  ldr       r0, =st_pose
  ldr       r6, [r0] // r6 pose
  ldr       r0, =st_time
  vldr      s7, [r0] // s7 time
  ldr       r0, =curMeY
  vldr      s6, [r0] // s6自己的y
drsn_upset:
  ldr       r0, =st_upset
  vldr      s0, [r0]
  ldr       r0, =animseq_bad_sign
  bl        cal_one_animseq
  cmp       r1, #-1
  beq       drsn_perfect
  mov       r3, r0 // 指定纹理
  vldr      s1, SIGN_OFFSET_X // s1 相对于自己鸟的偏移x
  vldr      s2, SIGN_OFFSET_Y // s2 相对于自己鸟的偏移y
  vadd.f32  s0, s1, s7
  vadd.f32  s1, s2, s6
  vldrs     s2, 0.0
  vldr      s3, SIGN_WIDTH
  vldr      s4, SIGN_HEIGHT// 画的宽和高！
  bl        coord_g2s_rect
  bl        fillSWhenDrawFullTexture
  bl        draw_square // 画
  b         drsn_ret
drsn_perfect:
  cmp       r6, #POSE_MOV_PERFECT
  cmpne     r6, #POSE_FLAP_PERFECT
  bne       drsn_great
  ldr       r0, =animseq_perfect_sign
  bl        cal_one_animseq
  cmp       r1, #-1
  beq       drsn_great
  mov       r3, r0 // 指定纹理
  vldr      s1, SIGN_OFFSET_X // s1 相对于自己鸟的偏移x
  vldr      s2, SIGN_OFFSET_Y // s2 相对于自己鸟的偏移y
  vadd.f32  s0, s1, s7
  vadd.f32  s1, s2, s6
  vldrs     s2, 0.0
  vldr      s3, SIGN_WIDTH
  vldr      s4, SIGN_HEIGHT// 画的宽和高！
  bl        coord_g2s_rect
  bl        fillSWhenDrawFullTexture
  bl        draw_square // 画
  b         drsn_ret
drsn_great:
  cmp       r6, #POSE_MOV_GREAT
  cmpne     r6, #POSE_FLAP_GREAT
  bne       drsn_ret
  ldr       r0, =animseq_great_sign
  bl        cal_one_animseq
  cmp       r1, #-1
  beq       drsn_ret
  mov       r3, r0 // 指定纹理
  vldr      s1, SIGN_OFFSET_X // s1 相对于自己鸟的偏移x
  vldr      s2, SIGN_OFFSET_Y // s2 相对于自己鸟的偏移y
  vadd.f32  s0, s1, s7
  vadd.f32  s1, s2, s6
  vldrs     s2, 0.0
  vldr      s3, SIGN_WIDTH
  vldr      s4, SIGN_HEIGHT// 画的宽和高！
  bl        coord_g2s_rect
  bl        fillSWhenDrawFullTexture
  bl        draw_square // 画
  b         drsn_ret
drsn_ret:
  pop       {r5-r6, lr}
  bx        lr




.section .data
idtx_upReminder:
  importres   upreminder_png
idtx_downReminder:
  importres   downreminder_png
idtx_flapReminder:
  importres   downreminder_png


