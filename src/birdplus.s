.include "common_macro.s"
.include "constants.s"

.global drawReminder
.global drawSign
.global init_birdPlus
.global tryPlayStarAccordingToStSound
.global drawStar

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
  // 顺便初始化星星
  ldr   r0, =_32573487_png
  ldr   r1, =_32573487_png_size
  bl    kx_image
  ldr   r3, =idtx_star_perfect
  str   r0, [r3]
  ldr   r0, =_32573491_png
  ldr   r1, =_32573491_png_size
  bl    kx_image
  ldr   r3, =idtx_star_great
  str   r0, [r3]
  pop   {lr}
  bx    lr

drawReminder:
  // 画reminder。修改r0-r4、s0-s7。
  push      {r5-r6, lr}
  ldr       r0, =st_time
  vldr      s0, [r0]
  bl        floor_f32
  mov       r6, r0 // r6自己时间取整
  // 如果已经超过总时长，那么不用画
  ldr       r5, =map_seq_len
  ldr       r5, [r5]
  cmp       r6, r5
  bge       drrmd_end
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
  vldrs         s5, 0.3792
  vldrs         s6, 0.6
  bl            keepImgSquare
  bl            rect_zoom_anchor_center
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
  .float    0.0
SIGN_OFFSET_Y:
  .float    0.0
SIGN_WIDTH:
  .float    1.0
SIGN_HEIGHT:
  .float    1.0

drawSign:
// 画sign。修改r0-r4、s0-s8。
  push      {r5-r6, lr}
  ldr       r0, =st_ago
  vldr      s8, [r0] // s0ago
  ldr       r0, =st_pose
  ldr       r6, [r0] // r6 pose
  ldr       r0, =st_time
  vldr      s7, [r0] // s7 time
  ldr       r0, =curMeY
  vldr      s6, [r0] // s6自己的y
drsn_perfect:
  cmp       r6, #POSE_MOV_PERFECT
  cmpne     r6, #POSE_FLAP_PERFECT
  bne       drsn_great
  vmov      s0, s8
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
  vmov      s0, s8
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



STAR_DEST_SCRX:
  .float  -0.9
STAR_DEST_SCRY:
  .float  0.9
STAR_SRC_X_OFFSET:
  .float  -1.0
STAR_SRC_Y_OFFSET:
  .float  1.0
STAR_ERP_LEN:
  .float  2.0
STAR_TOTAL_LEN:
  .float  3.0

playStar:
  // FIXME 插值逻辑是不对的！
  // 发起一个星星的动画过程。r0是纹理id.修改s0-s3。
  push    {r4-r7, lr}
  vpush   {s0-s7}
  // 移动r7指向数据段，和自增r2
  ldr     r7, =starBuf
  ldr     r3, =starBufCurIdx
  ldr     r2, [r3]
  mov     r6, #32
  mul     r1, r2, r6
  add     r7, r1
  add     r2, #1
  cmp     r2, #starBufLen
  subge   r2, #starBufLen
  str     r2, [r3]
  // 写入数据
  stm     r7!, {r0}
  ldr     r1, =st_time
  vldr    s0, [r1]
  ldr     r1, =curMeY
  vldr    s1, [r1]
  vldrs   s2, 0.0
  vldrs   s3, 1.0
  vldrs   s4, 1.0
  bl      coord_g2s_rect
  vmov     s3, s0
  vmov     s4, s1
  ldr     r1, =st_time
  vldr    s0, [r1]
  vldr    s1, STAR_ERP_LEN
  vldr    s2, STAR_TOTAL_LEN
  vldr    s5, STAR_DEST_SCRX
  vldr    s6, STAR_DEST_SCRY
  vstm    r7!, {s0-s6}
  vpop    {s0-s7}
  pop     {r4-r7, lr}
  bx      lr


drawStar:
  // 遍历列表画所有的星星
  push    {lr}
  mov     r9, #starBufLen
  mov     r8, #0 // 循环变量
  ldr     r7, =starBuf
drst_loop:
  cmp     r8, r9
  bge     drst_end
  ldm     r7!, {r3} // 纹理id
  vldm    r7!, {s0-s6}
  ldr     r0, =st_time
  vldr    s7, [r0]
  vcmpa.f32 s0, #0.0
  beq     drst_continue
  vsub.f32  s0, s7, s0
  vcmpa.f32 s0, s2
  bgt     drst_continue

  vdiv.f32  s7, s0, s1 // s7插值点
  vmov    s0, s3
  vmov    s1, s5
  vmov    s2, s7
  bl      qerp
  vmov    s3, s0
  vmov    s0, s4
  vmov    s1, s6
  vmov    s2, s7
  bl      qerp
  vmov    s1, s0
  vmov    s0, s3
drst_draw:
  vldrs   s3, 1.0
  vldrs   s4, 1.0
  bl      coord_g2s_rect_screenXYWorldHW
  bl      fillSWhenDrawFullTexture
  bl      draw_square // 画
drst_continue:
  add     r8, #1
  b       drst_loop
drst_end:
  pop     {lr}
  bx      lr


tryPlayStarAccordingToStSound:
  push  {lr}
  ldr   r1, =st_s_perfect
  ldr   r1, [r1]
  cmp   r1, #0
  ldrgt r0, =idtx_star_perfect
  ldrgt r0, [r0]
  blgt  playStar
  ldr   r1, =st_s_great
  ldr   r1, [r1]
  cmp   r1, #0
  ldrgt r0, =idtx_star_great
  ldrgt r0, [r0]
  blgt  playStar
  pop     {lr}
  bx      lr




.section .data
idtx_upReminder:
  importres   upreminder_png
idtx_downReminder:
  importres   downreminder_png
idtx_flapReminder:
  importres   flapreminder_png

idtx_star_perfect:
  .int  0
idtx_star_great:
  .int  0

.equ  starBufLen, 10
starBufCurIdx: // 指向starBuf当前第一个空白位置的指针
  .int  0
// starBuf是一个列表，其中的每个元素由8个4字节构成，分别表示纹理id（整型）、起点st_time、动画插值区间长度、
// 动画总长度、起点的x和y屏幕绝对坐标、终点的x和y屏幕绝对坐标。
starBuf:
  .space  32 * starBufLen, 0


