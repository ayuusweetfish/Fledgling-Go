.include "common_macro.s"

// 世界坐标系规定如下：
// 世界坐标系想象为一个无限大的平面，向右为x轴正方向，向上为y轴正方向，远离屏幕为z轴正方向。
// 在世界中，相机在x方向上以恒定速率(就是bpm)运动，在y轴上按照一定的运动算法作运动。
// 当前的相机实现不考虑z轴，即对于不同深度的物体绘图时按照相同的比例投影到屏幕上，不考虑近大远小。
//
// 本游戏中所有的方形图片的position表示，全部以左上角为准。
// 因为不考虑近大远小，当前的函数只提供了全局点坐标到屏幕点坐标的对应转换，暂未提供全局rect到屏幕rect的对应转换。
//
// camera绘制的范围固定为一个矩形，左上角的坐标始终是(当前拍号-2, camera_y)，长始终是12，高始终是9。
// 游戏开始时，鸟的纵坐标为0，camera_y为4（对应于鸟正好在屏幕中间）。
// camera_y是一个浮点数，表示的是游戏开始时

.section .text
// 有用的常量定义
CAM_X_OFF:
  .float  2.0
CAM_WID:
  .float  12.0
CAM_HEI:
  .float  9.0

// 衍生的常量定义
// 这里的值是由上面的有用常量经过简单的计算得出的。如果修改上面的有用常量，应当按照公式对应修改这些内容
_CWH:
  .float  6.0  // (CAM_WID / 2)
_CXA:
  .float  -4.0 // (CAM_X_OFF - (CAM_WID / 2))
_CHH:
  .float  4.5  // (CAM_HEI / 2)
_CYA:
  .float  4.5 // (CAM_HEI / 2)

coord_g2s_pt:
  // s0, s1 全局坐标系的x y
  // ret: s0,s1屏幕坐标系的xy
  // 该函数会修改r0，s0~s1，s7的值
  ldr       r0, =bttime
  vldr      s7, [r0]
  vsub.f32  s0, s7
  vldr      s7, _CXA
  vadd.f32  s0, s7
  vldr      s7, _CWH
  vdiv.f32  s0, s0, s7 // x算完了
  ldr       r0, =camera_y
  vldr      s7, [r0]
  vsub.f32  s1, s7
  vldr      s7, _CYA
  vadd.f32  s1, s7
  vldr      s7, _CHH
  vdiv.f32  s1, s1, s7 // x算完了
  bx        lr

coord_g2s_rect:
  // s0,s1,s2 全局坐标系（左上角点）的xyz坐标，s3, s4矩形的宽和高
  // ret: s0,s1左上角xy， s4,s5左下角xy， s8,s9右上角xy，是对应于svc画图的输入格式的
  // 与输入输出无关的寄存器不会改变
  // TODO 之后如果有需要的话就做近大远小
  bl        coord_g2s_pt
  vldr      s5, _CWH
  vdiv.f32  s3, s3, s5
  vadd.f32  s8, s0, s3
  vmov      s9, s1
  vldr      s5, _CHH
  vdiv.f32  s4, s4, s5
  vadd.f32  s5, s1, s4
  vmov      s4, s0
  bx        lr


.section .data
camera_y: // 相机的
  .float  4.0

