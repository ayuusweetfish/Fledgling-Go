# vim: set ft=asm:
.include "common_macro.s"

.global draw_square
.global fillSWhenDrawFullTexture
.global init_imported_res

.section .text
draw_square:
  // 画一个方形。参数与Draw系统调用相同，除了只需要传三个角上的点、不需要传第四个点。
  // !!!请注意！必须是第二、三个点位于一条对角线上！！！否则结果计算的将不正确！
  // 第四个点的画图位置和纹理位置自动计算得出，颜色（如有）则是继承第三个点的颜色。
  // 返回：寄存器一律不变。
  // 注：第4个点的算法是从一向二三中点连线并延长一倍长度。
  push      {r0-r3}
  svc       #0x120
  pop       {r0-r3}

  push      {r0-r3}
  vpush     {s0-s4}
  vneg.f32  s0, s0
  vadd.f32  s0, s4
  vadd.f32  s0, s8
  vneg.f32  s1, s1
  vadd.f32  s1, s5
  vadd.f32  s1, s9
  vneg.f32  s2, s2
  vadd.f32  s2, s6
  vadd.f32  s2, s10
  vneg.f32  s3, s3
  vadd.f32  s3, s7
  vadd.f32  s3, s11
  svc       #0x120
  vpop      {s0-s4}
  pop       {r0-r3}
  bx        lr


fillSWhenDrawFullTexture:
  // 把r0~r2用0xffffffff（全透明度）填充，s2 s3 s6 s7 s10 s11用图片的左上角、左下角、右上角填充。
  ldr   r0, =0xffffffff
  ldr   r1, =0xffffffff
  ldr   r2, =0xffffffff
  vldrs s2, 0.0
  vldrs s3, 0.0
  vldrs s6, 0.0
  vldrs s7, 1.0
  vldrs s10, 1.0
  vldrs s11, 0.0
  bx    lr


init_imported_res:
  // 把importres引入的资源进行构建纹理操作。
  // r0 地址 不改变任何寄存器
  push  {r0-r4, lr}
  mov   r4, r0
  ldm   r0, {r0-r1}
  bl    kx_image
  str   r0, [r4]
  pop   {r0-r4, lr}
  bx    lr

