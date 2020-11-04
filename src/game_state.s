/*
  游戏状态

  主要行为
  - 窗口期外
    * 任何按键：炸毛
  - 上/下音符窗口期内
    * 正确按键：向对应方向移动（pose = PERFECT/GREAT；设置 st_hit）
    * 错误按键、多余的正确按键：炸毛
    * Miss：被对应方向的鸟撞击（pose = BUMP）
  - 拍翅膀音符窗口期内
    * 某一个方向按键：摆出预备姿势（pose = READY）
    * 另一个方向按键：完成（pose = FLAP）
    * 多余的按键，包括重复按键：炸毛
    * Miss：炸毛

  一些解释
  - 炸毛与其他动作是叠加的，相当于正常流程基础上的一个短暂效果。
    这么做是为了在炸毛与其他动作几乎同时发生时更清晰地传达提示。
  - 玩家所控制的鸟永远不会向错误的方向移动。
    不妨认为「当前音符」在窗口期外表示「上一个音符」，那么玩家所操控的鸟
    目前的位置可以结合 st_ago「当前动作已经持续的时间」以及谱面数据中
    「当前音符对应的移动方向」计算得到

  数据
  - st_pose
    鸟的动作。实际上其他鸟的行为（如斜眼、撞击后的反应）也依赖此项
  - st_ago
    只针对上/下音符有效，当前音符（或上一个音符）被正确击中以来的时间（拍）
    -1 表示尚未击中
  - st_upset
    距上次炸毛触发以来的时间（拍）
  - st_s_*
    布尔变量 当前帧是否触发某个音效
*/

.include "constants.s"

.data
st_pose:  .int    POSE_NORMAL
st_ago:   .float  0
st_upset: .float  0
st_s_perfect: .byte 0
st_s_great: .byte 0
st_s_bump: .byte 0
st_s_upset: .byte 0
st_s_flap: .byte 0


.text

/*
  out r0 - boolean，玩家 A（上）是否按下按键
      r1 - boolean，玩家 B（下）是否按下按键
*/
get_input:
  bx    lr

/*
  out r0 - 当前音符头鸟领先的拍数
      r1 - 当前音符的方向（0 - 无；1 - 上；2 - 下；3 - 拍翅膀）
      r2 - 当前时刻与音符时刻之差（拍）
           以音符的位置为 0，之前为负，之后为正
*/
get_note:
  bx    lr
