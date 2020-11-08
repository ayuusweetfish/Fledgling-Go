.include "common_macro.s"
.include "constants.s"

.global init_label
.global drawLabel

.section .text
TEXT_SCORE_X:
  .float  -0.9
TEXT_SCORE_Y:
  .float  0.95
TEXT_COMBO_X:
  .float  0.55
TEXT_COMBO_Y:
  .float  0.95

init_label:
  push  {lr}

  ldr   r0, =score_combo_png
  ldr   r1, =score_combo_png_size
  bl    kx_image
  ldr   r1, =tex_id_score_combo
  str   r0, [r1]

  ldr   r0, =digits_png
  ldr   r1, =digits_png_size
  bl    kx_image
  ldr   r1, =tex_id_digits
  str   r0, [r1]

  pop   {pc}

/*
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
*/


drawLabel:
  push  {lr}
  
  // 绘制 score, combo
  ldr   r3, =tex_id_score_combo
  ldr   r3, [r3]
  vldrs s0, -0.97
  vldrs s1,  0.97
  vldrs s4, -0.97
  vldrs s5,  0.67
  vldrs s8, -0.61
  vldrs s9,  0.97
  bl    fillSWhenDrawFullTexture
  bl    draw_square

  // Score: (-0.61, 0.97)
  // Combo: (-0.61, 0.82)
  // 0.15 * 0.25

  pop   {pc}

/*
  push  {r4, lr}
  // 画分
  ldr   r0, =st_score
  ldr   r0, [r0]
  ldr   r1, =charbuf2
  mov   r2, #10
  bl    itoa
  ldr   r4, =idlbl_score
  ldr   r0, [r4]
  ldr   r1, =charbuf2
  vldrs s0, 80.0
  //bl    kx_label_print
  ldr   r0, [r4]
  ldr   r1, =#0xee2222ff
  vldr  s0, TEXT_SCORE_X
  vldr  s1, TEXT_SCORE_Y
  vldrs s2, 0.00125
  vldrs s3, 0.00208333
  //bl    kx_label_draw
  // 画combo
  ldr   r0, =st_combo
  ldr   r0, [r0]
  ldr   r1, =charbuf2
  mov   r2, #10
  bl    itoa
  ldr   r4, =idlbl_score
  ldr   r0, [r4]
  ldr   r1, =charbuf
  vldrs s0, 80.0
  //bl    kx_label_print
  ldr   r0, [r4]
  ldr   r1, =#0x22ee22ff
  vldr  s0, TEXT_COMBO_X
  vldr  s1, TEXT_COMBO_Y
  vldrs s2, 0.00125
  vldrs s3, 0.00208333
  //bl    kx_label_draw

  pop   {r4, lr}
  bx    lr
*/


.section .data
tex_id_score_combo: .int  0
tex_id_digits:      .int  0
/*
idlbl_score:
  .int  0
idlbl_combo:
  .int  0
charbuf:
  .ascii "Combo "
charbuf2:
  .space  100, 0
*/
