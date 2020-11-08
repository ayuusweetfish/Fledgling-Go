.include "common_macro.s"
.include "constants.s"

.global init_label
.global drawLabel
.global tryPlayStarAccordingToStSound
.global drawStar

.section .text
TEXT_SCORE_X:
  .float  -0.9
TEXT_SCORE_Y:
  .float  0.9
TEXT_COMBO_X:
  .float  0.9
TEXT_COMBO_Y:
  .float  0.9

init_label:
  push  {lr}
  ldr   r0, =Mali_Regular_ttf
  bl    kx_label
  ldr   r1, =idlbl_score
  str   r0, [r1]
  ldr   r0, =Mali_Regular_ttf
  bl    kx_label
  ldr   r1, =idlbl_combo
  str   r0, [r1]
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


drawLabel:
  push  {r4, lr}
  // 画分
  ldr   r0, =st_score
  ldr   r0, [r0]
  ldr   r1, =charbuf
  mov   r2, #10
  bl    itoa
  ldr   r4, =idlbl_score
  ldr   r0, [r4]
  ldr   r1, =charbuf
  vldrs s0, 80.0
  bl    kx_label_print
  ldr   r0, [r4]
  ldr   r1, =#0xee2222ff
  vldr  s0, TEXT_SCORE_X
  vldr  s1, TEXT_SCORE_Y
  vldrs s2, 0.00125
  vldrs s3, 0.00208333
  bl    kx_label_draw
  // 画combo
  ldr   r0, =st_combo
  ldr   r0, [r0]
  ldr   r1, =charbuf
  mov   r2, #10
  bl    itoa
  ldr   r4, =idlbl_score
  ldr   r0, [r4]
  ldr   r1, =charbuf
  vldrs s0, 80.0
  bl    kx_label_print
  ldr   r0, [r4]
  ldr   r1, =#0x22ee22ff
  vldr  s0, TEXT_COMBO_X
  vldr  s1, TEXT_COMBO_Y
  vldrs s2, 0.00125
  vldrs s3, 0.00208333
  bl    kx_label_draw

  pop   {r4, lr}
  bx    lr


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
  vldr    s1, STAR_ERP_LEN
  vldr    s2, STAR_TOTAL_LEN
  vldr    s5, STAR_DEST_SCRX
  vldr    s6, STAR_DEST_SCRY
  vmov    s3, s0
  vldr    s7, STAR_SRC_X_OFFSET
  vadd.f32  s3, s7
  ldr     r1, =curMeY
  vldr    s4, [r1]
  vldr    s7, STAR_SRC_Y_OFFSET
  vadd.f32  s4, s7
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
  cmp   r1, #0
  ldrge r0, =idtx_star_perfect
  ldrge r0, [r0]
  blge  playStar
  ldr   r1, =st_s_great
  cmp   r1, #0
  ldrge r0, =idtx_star_great
  ldrge r0, [r0]
  blge  playStar
  pop     {lr}
  bx      lr


.section .data
idlbl_score:
  .int  0
idlbl_combo:
  .int  0
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


.comm   charbuf   100
