.global foo
foo:
  mov   r0, #3
  bl    bar
  add   r0, #79
  ldr   r1, =#435
  ldr   r2, =year
  bx    lr

.section .data
year:
  .word 2020
