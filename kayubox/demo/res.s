# vim: set ft=asm:
.macro  res name, path
  .global \name
0:
  \name: .incbin "\path"
1:
  .global \name\()_size
  .set \name\()_size, (1b - 0b)
.endm

.section .rodata
  // Exports symbols `_32573493_png` and `_32573493_png_size`
  res _32573493_png, 32573493.png