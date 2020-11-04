# vim: set ft=asm:

// 引入一个源文件，在其范围内设置 _INCLUDE_HEADER 为 1
// 故源文件中可以检查 _INCLUDE_HEADER 的值，在等于 1 时只保留常数和宏定义
.macro  include_header what: req
  .set _INCLUDE_HEADER, 1
  .include "\what"
  .set _INCLUDE_HEADER, 0
.endm

.macro  vldrs reg: req, imm: req
  vldr  \reg, _vldrs\@_imm
  b     _vldrs\@_after
_vldrs\@_imm: .float \imm
_vldrs\@_after:
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

.macro  l // 输出 log 的简化形式
  push {r0-r3}
  svc  #0x0e
  pop  {r0-r3}
.endm
