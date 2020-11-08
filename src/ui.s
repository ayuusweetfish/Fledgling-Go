.include "common_macro.s"
.include "constants.s"

.global init_label
.global drawLabel

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
  ldr   r1, =#0x222222ff
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
  ldr   r1, =#0x222222ff
  vldr  s0, TEXT_COMBO_X
  vldr  s1, TEXT_COMBO_Y
  vldrs s2, 0.00125
  vldrs s3, 0.00208333
  p
  ps
  bl    kx_label_draw

  pop   {r4, lr}
  bx    lr


.section .data
idlbl_score:
  .int  0
idlbl_combo:
  .int  0
.comm   charbuf   100
