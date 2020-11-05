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
  - st_time
    当前处于第几拍
  - st_pose
    鸟的动作；实际上其他鸟的行为（如斜眼、撞击后的反应）也依赖此项
  - st_ago
    st_pose改变以来的时间（拍）
  - st_upset
    距上次炸毛触发以来的时间（拍）
  - st_last_hit
    上次命中的音符是第几拍
  - st_window
    当前窗口期情况 与get_note的输出 r1一致
  - st_s_*
    布尔变量 当前帧是否触发某个音效
*/

.include "constants.s"

.global st_time
.global st_pose
.global st_ago
.global get_note


.data
st_time:  .float
st_pose:  .int    POSE_NORMAL
st_ago:   .float  0
st_upset: .float  0
st_last_hit:  .int 0
st_window:    .int 0
st_s_perfect: .byte 0
st_s_great:   .byte 0
st_s_bump:    .byte 0
st_s_upset:   .byte 100
st_s_flap:    .byte 0

.text
state_update:
  bl get_input
  mov r3, r0    // UP key is down
  mov r4, r1    // DOWN key is down
  bl get_note   // r0 - the direction of current note；r1 - the window-situation
  ldr r5, =st_last_hit
  cmp r5, r2
  beq already_hit
  cmp r1, #1
  beq great_manager     // in great-window; jump to analyse if hit
  cmp r1, #2
  beq perfect_manager   // in perfect-window; jump to analyse if hit
  cmp r1, #0
  beq out_window_manager      // out of window; jump to analyse if miss or if a error pressing
  b L1

already_hit:
  cmp r3, #1
  beq upset_set
  cmp r4, #1
  beq upset_set
  b L1

great_manager:
  cmp r3, #1
  beq great_manager_upkey
  cmp r4, #1
  beq great_manager_downkey
  b L1

great_manager_upkey:
  cmp r0, #1
  beq great_set
  cmp r0, #3         // in flap window
  ldreq r5, =st_pose
  ldreq r5, [r5]
  cmpeq r5, #POSE_READY_DOWN
  bleq flap_set
  beq great_set
  b L1

great_manager_downkey:
  cmp r0, #2
  beq great_set
  cmp r0, #3
  ldreq r5, =st_pose
  ldreq r5, [r5]
  cmpeq r5, #POSE_READY_UP
  bleq flap_set
  beq great_set
  b L1

great_set:
  ldr r5, =POSE_MOV_GREAT
  ldr r6, =st_pose
  str r5, [r6]
  ldr r5, =0
  ldr r6, =st_ago
  str r5, [r6]
  ldr r5, =1
  ldr r6, =st_s_great
  str r5, [r6]
  ldr r6, =st_last_hit    //st_last_hit++
  str r2, [r6]
  b L1

perfect_manager:
  cmp r3, #1
  beq perfect_manager_upkey
  cmp r4, #1
  beq perfect_manager_downkey
  b L1

perfect_manager_upkey:
  cmp r0, #1
  beq perfect_set
  cmp r0, #3           // in flap window
  ldreq r5, =st_pose
  ldreq r5, [r5]
  cmpeq r5, #POSE_READY_DOWN
  bleq flap_set
  beq perfect_set
  b L1

perfect_manager_downkey:
  cmp r0, #2
  beq perfect_set
  cmp r0, #3
  ldreq r5, =st_pose
  ldreq r5, [r5]
  cmpeq r5, #POSE_READY_UP
  bleq flap_set
  beq perfect_set
  b L1

perfect_set:
  ldr r5, =POSE_MOV_PERFECT
  ldr r6, =st_pose
  str r5, [r6]     // /*note: the destination is the first operand*/
  ldr r5, =0
  ldr r6, =st_ago
  str r5, [r6]            // set st_ago as 0
  ldr r5, =1
  ldr r6, =st_s_perfect
  str r5, [r6]            // set sound
  ldr r6, =st_last_hit
  str r2, [r6]            //set st_last_hit as current note's position
  b L1

out_window_manager:
  ldr r5, =st_last_hit
  cmp r2, r5              //上一个音符所在拍与上一个命中所在拍不一致 即 miss了上一个音符
  ldrne r5, =st_window
  cmpne r5, #1            //上一帧为great窗口期 即 刚刚出great窗口期
  beq bump_set
  cmp r3, #1              // UP key is down
  beq upset_set
  cmp r4, #1              // DOWN key is down
  beq upset_set
  b L1

bump_set:
  ldr r5, =POSE_BUMP
  ldr r6, =st_pose
  str r5, [r6]
  ldr r5, =0
  ldr r6, =st_ago
  str r5, [r6]
  ldr r5, =1
  ldr r6, =st_s_bump
  str r5, [r6]            // set sound
  b L1

upset_set:
  ldr r5, =0
  ldr r6, =st_upset
  str r5, [r6]
  b L1

flap_set:
  ldr r5, =POSE_FLAP_GREAT // TODO 这里你现在只有一个函数、没有POSE_FLAP_PERFECT的设置函数
  ldr r6, =st_pose
  str r5, [r6]
  ldr r5, =0
  ldr r6, =st_ago
  str r5, [r6]
  ldr r5, =1
  ldr r6, =st_s_flap
  str r5, [r6]          //set sound
  bx lr

L1:


//.endif

.text

/*
  out r0 - boolean，玩家 A（上）是否按下按键
      r1 - boolean，玩家 B（下）是否按下按键
*/
get_input:
  bx    lr

/*
  out r0 - 当前音符的方向（0 - 无；1 - 上；2 - 下；3 - 拍翅膀）
      r1 - 当前时刻处于何种窗口期（0 - 窗口期外； 1 - great； 2 - perfect）
      r2 - int 当前的音符为第几拍
*/
get_note:
  bx    lr
