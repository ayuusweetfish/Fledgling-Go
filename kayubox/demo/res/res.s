# vim: set ft=asm:
.macro  res name: req, path: req
  .align 4
  .global \name
  \name: .incbin "res/\path"
  .global \name\()_size
  .equ \name\()_size, (. - \name)
  .byte 0
.endm

.section .rodata
  // Exports symbols `_32573493_png` and `_32573493_png_size`
  res _32573493_png, 32573493.png
  res copycat_ogg, copycat.ogg
  res Mali_Regular_ttf, Mali-Regular.ttf
  res qwq_txt, qwq.txt
