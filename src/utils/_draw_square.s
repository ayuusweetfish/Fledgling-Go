# vim: set ft=asm:
.include "common_macro.s"

.global _draw_square
_draw_square:
  // 画一个方形。参数与Draw系统调用相同，除了只需要传三个角上的点、不需要传第四个点。
  // 第四个点的画图位置和纹理位置自动计算得出，颜色（如有）则是继承第三个点的颜色。
  // 返回：s8~s11变为第四个点的信息，其余的一律不变。
  // 注：第4个点的算法是从三向一二中点连线并延长一倍长度。
  push {r0-r3}
  svc   #0x120
  pop  {r0-r3}
  vneg.f32  s8, s8
  vadd.f32  s8, s0
  vadd.f32  s8, s4
  vneg.f32  s9, s9
  vadd.f32  s9, s1
  vadd.f32  s9, s5
  vneg.f32  s10, s10
  vadd.f32  s10, s2
  vadd.f32  s10, s6
  vneg.f32  s11, s11
  vadd.f32  s11, s3
  vadd.f32  s11, s7
  svc   #0x120
  bx lr
