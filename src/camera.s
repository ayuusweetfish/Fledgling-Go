.include "common_macro.s"
.include "constants.s"

.global coord_g2s_rect
.global cam_move_update
.global coord_g2s_rect_screenXYWorldHW
.global keepImgSquare
.global rect_zoom_anchor_center
.global _CKSR
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
  .float  1.0
CAM_WID:
  .float  5.0
CAM_HEI:
  .float  4.0

// 衍生的常量定义
// 这里的值是由上面的有用常量经过简单的计算得出的。如果修改上面的有用常量，应当按照公式对应修改这些内容
_CWH:
  .float  2.5  // (CAM_WID / 2)
_CXA:
  .float  -1.50 // (CAM_X_OFF - (CAM_WID / 2))
_CHH:
  .float  2.0  // (CAM_HEI / 2)
_CYA:
  .float  2.0 // (CAM_HEI / 2)
_CKSR: // 由于相机对世界坐标系存在缩放，如果一个物体想维持正方形的形状，就在调用coord_g2s_rect之前调用下keepImgSquare
  .float  0.75 // ((3 / 5) * (CAM_WID / CAM_HEI)

.section .data
.align 2
camera_y: // 相机的y 初始化为(CAM_HEI - 1) / 2
  .float  1.5

.section .text
keepImgSquare:
  // 只是会把横轴再s3乘以一个_CKSR倍而已。中心点为锚点。
  // 修改：s0-s1（坐标变了）、s3
  push      {lr}
  vpush     {s5-s6}
  vldr      s5, _CKSR
  vldrs     s6, 1.0
  bl        rect_zoom_anchor_center
  vpop      {s5-s6}
  pop       {lr}
  bx        lr

coord_g2s_pt:
  // s0, s1 全局坐标系的x y
  // ret: s0,s1屏幕坐标系的xy
  // 该函数会修改r0，s0~s1，s7的值
  ldr       r0, =st_time
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
  push      {lr}
  bl        coord_g2s_pt
  vldr      s5, _CWH
  vdiv.f32  s3, s3, s5
  vadd.f32  s8, s0, s3
  vmov      s9, s1
  vldr      s5, _CHH
  vdiv.f32  s4, s4, s5
  vsub.f32  s5, s1, s4
  vmov      s4, s0
  pop       {lr}
  bx        lr


coord_g2s_rect_screenXYWorldHW:
  // s0,s1 屏幕坐标系（左上角点）的xyz坐标，s3, s4矩形的世界坐标宽和高
  // ret: s0,s1左上角xy， s4,s5左下角xy， s8,s9右上角xy，是对应于svc画图的输入格式的
  // 与输入输出无关的寄存器不会改变
  push      {lr}
  vldr      s5, _CWH
  vdiv.f32  s3, s3, s5
  vadd.f32  s8, s0, s3
  vmov      s9, s1
  vldr      s5, _CHH
  vdiv.f32  s4, s4, s5
  vsub.f32  s5, s1, s4
  vmov      s4, s0
  pop       {lr}
  bx        lr

rect_zoom_anchor_center:
  // 对于一个要绘制的矩形，对其进行以中心点为锚点的缩放操作。
  // 输入：s0-s2左上角点的xyz s3-s4宽或高 s5 x方向缩放倍率 s6 y方向缩放倍率
  // 输出：重新计算过后的 s0-s4。其中s2必定保持不变。除此以外所有寄存器，包括s5 s6均不变。
  vpush     {s2}
  vldrs     s2, 2.0
  vdiv.f32  s3, s3, s2
  vdiv.f32  s4, s4, s2
  vadd.f32  s0, s3
  vsub.f32  s1, s4 // 此时变为了中心点坐标
  vmul.f32  s3, s5
  vmul.f32  s4, s6
  vsub.f32  s0, s3
  vadd.f32  s1, s4 // 缩放后的左上角点
  vmul.f32  s3, s2
  vmul.f32  s4, s2
  vpop      {s2}
  bx        lr

SAFE_PADDING:
  .float    1.5
CAMERA_DELTAMAX: // 每一拍，相机位置允许变化的最大值
  .float    1.0
cam_move_update:
  push          {lr}
  // 计算允许的变化量的最大值
  vldrs         s2, 60.0
  ldr           r1, =FPS
  vmov          s3, r1
  vcvt.f32.s32  s3, s3
  vmul.f32      s2, s3
  ldr           r1, =map_bpm
  vldr          s3, [r1]
  vdiv.f32      s2, s2, s3
  vldr          s3, CAMERA_DELTAMAX
  vdiv.f32      s5, s3, s2 // s5是允许的变化量的最大值
  // 算新的目标相机值
  ldr           r0, =st_time
  vldr          s0, [r0]
  bl            calBirdY // s0当前y
  ldr           r0, =camera_y
  vldr          s1, [r0] // s1当前相机值
  vsub.f32      s2, s1, s0 // s2当前相机与当前y的差
  vmov          s6, s1 // s6 是最终的目标相机值 默认为不变（s1）
  //检测是否出上边界
  vldr          s3, SAFE_PADDING
  vcmpa.f32     s2, s3
  vaddlt.f32    s6, s0, s3
  blt           camv_end
  //检测是否出下边界
  vldr          s4, CAM_HEI
  vsub.f32      s3, s4, s3
  vldrs         s4, 1.0
  vsub.f32      s3, s4
  vcmpa.f32     s2, s3
  vaddgt.f32    s6, s0, s3
camv_end:
  vadd.f32      s2, s1, s5
  vsub.f32      s1, s1, s5
  vmov          s0, s6
  bl            clamp // 应当让返回的s0，是正常的lead clamp在允许变化区间之内的值。
  vstr          s0, [r0] // 新的值写回camera_y
  pop           {lr}
  bx            lr



