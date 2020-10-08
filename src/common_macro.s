# vim: set ft=asm:

.macro  vldrs reg, imm
  vldr  \reg, 0f
  b     1f
0: .float \imm
1:
.endm

.macro  d // debug断点调用的简化形式
  svc #0x0f
.endm

.macro  dpm // 打印寄存器简单版+debug断点调用的简化形式
  svc #0x00
  svc #0x0f
.endm

.macro  dp // 打印寄存器+debug断点调用的简化形式
  svc #0x01
  svc #0x0f
.endm

.macro  dps // 打印浮点寄存器+debug断点调用的简化形式
  svc #0x02
  svc #0x0f
.endm

.macro  pm // 打印简单版寄存器的简化形式
  svc #0x00
.endm

.macro  p // 打印寄存器的简化形式
  svc #0x01
.endm

.macro  ps // 打印浮点寄存器的简化形式
  svc #0x02
.endm
