# vim: set ft=asm:
.include "common_macro.s"

.section .data
qerp:
  // 二次插值：函数y=2x^2(x\in[0,0.5))；y=-2(x-1)^2+1(x\in[0.5,1])
  // s0 下界 s1 上界 （允许s0>s1）
  // s2 插值点（介于0至1之间） 若s2小于0则如同=0返回s0 若s2大于1则如同=1返回s1
  // return s0
  // 改变s3
  vcmpa.f32  s2, #0.0
  bxle      lr
  vldrs     s3, 1.0
  vcmpa.f32  s2, s3
  vmovge    s0, s1
  bxge      lr
  vldrs     s3, 0.5
  vcmpa.f32  s2, s3
  bgt      gt0p5
lt0p5:
  vmul.f32  s2, s2
  vldrs     s3, 2.0
  vmul.f32  s2, s3
  b        qerpfn
gt0p5:
  vldrs     s3, 2.0
  vsub.f32  s4, s2, s3
  vmul.f32  s2, s4
  vldrs     s3, -2.0
  vmul.f32  s2, s3
  vldrs     s3, 1.0
  vsub.f32  s2, s3
qerpfn:
  // 此时s2是0至1之间的值
  vsub.f32  s1, s0
  vmul.f32  s1, s2
  vadd.f32  s0, s1
  bx        lr
