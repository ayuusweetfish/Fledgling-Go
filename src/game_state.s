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
  - ready_is_perfect
    用于辅助拍翅膀perfect判定的临时变量，不计入state结构体，不作为接口使用
    -1 - 初始状态  0 - great  1 - perfect
  - frame_time 用于记录（上一帧的）时间的临时变量，辅助计算st_ago，不作为接口使用
*/

.include "common_macro.s"
.include "constants.s"

.global st_time
.global st_pose
.global st_ago
.global get_note
.global state_update
.global st_upset


.data
st_time:  .float  0.0
st_pose:  .int    POSE_NORMAL
st_ago:   .float  0
st_upset: .float  0
st_last_hit:  .int 0
st_window:    .int 0
st_s_perfect: .byte 0
st_s_great:   .byte 0
st_s_bump:    .byte 0
st_s_upset:   .float 100
st_s_flap:    .byte 0
ready_is_perfect: .byte -1
frame_time: .float 0.0

.text
state_update:
  //TODO: when enter a new window set st_pose as POSE_NORMAL  --Finished
  //TODO: flap_ready          --Finished
  //TODO: initialize st_s_*   --Finished
  //TODO: update st_ago       --Finished
  //TODO: when press error key set upset    --Finished
  push {r4-r11, lr}
  vpush {s5-s7}

  ldr r5, =st_time
  ldr r5, [r5]
  cmp r5, #0
  blt normal_set          // if st_time < 0 set st_pose as normal
  b L5

  ldr r5, =0
  ldr r6, =st_s_perfect
  str r5, [r6]
  ldr r5, =0
  ldr r6, =st_s_great
  str r5, [r6]
  ldr r5, =0
  ldr r6, =st_s_bump
  str r5, [r6]
  ldr r5, =0
  ldr r6, =st_s_upset
  str r5, [r6]
  ldr r5, =0
  ldr r6, =st_s_flap
  str r5, [r6]        //initialize all the st_s_* as 0

  bl get_input
  mov r3, r0    // UP key is down
  mov r4, r1    // DOWN key is down

  bl get_note   // r0 - the direction of current note；r1 - the window-situation
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
  ldr r5, =st_last_hit
  cmp r5, r2
  beq already_hit             // check if already hit
  ldr r5, =st_window
  ldr r5, [r5]
  cmp r5, #0
  bleq normal_set             //若上一帧为非窗口期且这一帧为great窗口期，则为进入窗口期，set st_pose as normal
  cmp r3, #1
  beq great_manager_upkey
  cmp r4, #1
  beq great_manager_downkey
  b L1

great_manager_upkey:
  cmp r4, #1
  beq great_manager_updownkey    //if press up and down key at the same frame
  cmp r0, #1
  beq great_set
  cmp r0, #2
  beq upset_set
  cmp r0, #3         // in flap window
  beq great_manager_upkey_flap
  b L1

great_manager_upkey_flap:
   ldr r5, =st_pose
   ldr r5, [r5]
   cmp r5, #POSE_READY_DOWN
   beq flap_great_set
   cmp r5, #POSE_NORMAL
   b ready_up_great_set
   b L1

great_manager_downkey:
  cmp r3, #1
  beq great_manager_updownkey    //if press up and down key at the same frame
  cmp r0, #2
  beq great_set
  cmp r0, #1
  beq upset_set
  cmp r0, #3
  beq great_manager_downkey_flap   //flap window
  b L1

great_manager_downkey_flap:
   ldr r5, =st_pose
   ldr r5, [r5]
   cmp r5, #POSE_READY_UP
   beq flap_great_set
   cmp r5, #POSE_NORMAL
   b ready_down_great_set
   b L1

great_manager_updownkey:
  cmp r0, #1
  beq great_upset_set
  cmp r0, #2
  beq great_upset_set
  cmp r0, #3
  beq great_manager_updownkey_flap

great_manager_updownkey_flap:
  ldr r5, =st_pose
  ldr r5, [r5]
  cmp r5, #POSE_READY_UP
  beq flap_great_upset_set
  cmp r5, #POSE_READY_DOWN
  beq flap_great_upset_set
  cmp r5, #POSE_NORMAL
  beq flap_great_set
  b L1

perfect_manager:
  ldr r5, =st_last_hit
  cmp r5, r2
  beq already_hit         // check if already hit
  cmp r3, #1
  beq perfect_manager_upkey
  cmp r4, #1
  beq perfect_manager_downkey
  b L1

perfect_manager_upkey:
  cmp r4, #1
  beq perfect_manager_updownkey    //if press up and down key at the same frame
  cmp r0, #1
  beq perfect_set
  cmp r0, #2
  beq upset_set         // in down window
  cmp r0, #3           // in flap window
  beq perfect_manager_upkey_flap
  b L1

perfect_manager_upkey_flap:
   ldr r5, =st_pose
   ldr r5, [r5]
   cmp r5, #POSE_READY_DOWN
   ldreq r5, =ready_is_perfect
   ldreq r5, [r5]
   cmpeq r5, #1
   beq flap_perfect_set
   bne flap_great_set
   cmp r5, #POSE_NORMAL
   beq ready_up_perfect_set
   b L1

perfect_manager_downkey:
  cmp r4, #1
  beq perfect_manager_updownkey    //if press up and down key at the same frame
  cmp r0, #2
  beq perfect_set
  cmp r0, #1
  beq upset_set
  cmp r0, #3
  beq perfect_manager_downkey_flap
  b L1

perfect_manager_updownkey:
  cmp r0, #1
  beq perfect_upset_set
  cmp r0, #2
  beq perfect_upset_set
  cmp r0, #3
  beq perfect_manager_updownkey_flap

perfect_manager_downkey_flap:
   ldr r5, =st_pose
   ldr r5, [r5]
   cmp r5, #POSE_READY_UP
   ldreq r5, =ready_is_perfect
   ldreq r5, [r5]
   cmpeq r5, #1
   beq flap_perfect_set
   bne flap_great_set
   cmp r5, #POSE_NORMAL
   beq ready_down_perfect_set
   b L1

perfect_manager_updownkey_flap:
  ldr r5, =st_pose
  ldr r5, [r5]
  cmp r5, #POSE_READY_UP
  beq flap_perfect_upset_set
  cmp r5, #POSE_READY_DOWN
  beq flap_perfect_upset_set
  cmp r5, #POSE_NORMAL
  beq flap_perfect_set
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
  b L2

great_upset_set:
  ldr r5, =POSE_MOV_GREAT
  ldr r6, =st_pose
  str r5, [r6]
  ldr r5, =0
  ldr r6, =st_ago
  str r5, [r6]
  ldr r5, =1
  ldr r6, =st_s_great
  str r5, [r6]
  ldr r6, =st_last_hit    //set st_last_hit
  str r2, [r6]

  ldr r5, =0
  ldr r6, =st_upset
  str r5, [r6]
  ldr r5, =1
  ldr r6, =st_s_upset
  str r5, [r6]            // set sound
  b L3

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
  b L2

perfect_upset_set:
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
  ldr r5, =0
  ldr r6, =st_upset
  str r5, [r6]
  ldr r5, =1
  ldr r6, =st_s_upset
  str r5, [r6]            // set sound
  b L3


out_window_manager:
  ldr r5, =st_window
  ldr r5, [r5]
  cmp r5, #1            //上一帧为great窗口期 即 刚刚出great窗口期
  bne L7
  ldreq r5, =st_last_hit
  cmpeq r2, r5              //上一个音符所在拍与上一个命中所在拍不一致 即 miss了上一个音符
  bne bump_set
L7:
  cmp r3, #1              // UP key is down
  beq upset_set
  cmp r4, #1              // DOWN key is down
  beq upset_set
  b L1


/* st_pose set */
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
  b L2

upset_set:
  ldr r5, =0
  ldr r6, =st_upset
  str r5, [r6]
  ldr r5, =1
  ldr r6, =st_s_upset
  str r5, [r6]            // set sound
  b L3

flap_perfect_set:
  ldr r5, =POSE_FLAP_PERFECT
  ldr r6, =st_pose
  str r5, [r6]
  ldr r5, =0
  ldr r6, =st_ago
  str r5, [r6]
  ldr r5, =1
  ldr r6, =st_s_flap
  str r5, [r6]          //set sound
  ldr r6, =st_s_perfect
  str r5, [r6]          //set sound
  ldr r5, =-1
  ldr r6, =ready_is_perfect
  str r5, [r6]          //initialize ready_is_perfect as -1
  ldr r6, =st_last_hit
  str r2, [r6]            //set st_last_hit as current note's position
  b L2

flap_perfect_upset_set:
  ldr r5, =POSE_FLAP_PERFECT
  ldr r6, =st_pose
  str r5, [r6]
  ldr r5, =0
  ldr r6, =st_ago
  str r5, [r6]
  ldr r5, =1
  ldr r6, =st_s_flap
  str r5, [r6]          //set sound
  ldr r6, =st_s_perfect
  str r5, [r6]          //set sound
  ldr r5, =-1
  ldr r6, =ready_is_perfect
  str r5, [r6]          //initialize ready_is_perfect as -1
  ldr r6, =st_last_hit
  str r2, [r6]            //set st_last_hit as current note's position
  ldr r5, =0
  ldr r6, =st_upset
  str r5, [r6]
  ldr r5, =1
  ldr r6, =st_s_upset
  str r5, [r6]            // set sound
  b L3

flap_great_set:
  ldr r5, =POSE_FLAP_GREAT
  ldr r6, =st_pose
  str r5, [r6]
  ldr r5, =0
  ldr r6, =st_ago
  str r5, [r6]
  ldr r5, =1
  ldr r6, =st_s_flap
  str r5, [r6]          //set sound
  ldr r6, =st_s_great
  str r5, [r6]          //set sound
  ldr r5, =-1
  ldr r6, =ready_is_perfect
  str r5, [r6]          //initialize ready_is_perfect as -1
  ldr r6, =st_last_hit
  str r2, [r6]            //set st_last_hit as current note's position
  b L2

flap_great_upset_set:
  ldr r5, =POSE_FLAP_GREAT
  ldr r6, =st_pose
  str r5, [r6]
  ldr r5, =0
  ldr r6, =st_ago
  str r5, [r6]
  ldr r5, =1
  ldr r6, =st_s_flap
  str r5, [r6]          //set sound
  ldr r6, =st_s_great
  str r5, [r6]          //set sound
  ldr r5, =-1
  ldr r6, =ready_is_perfect
  str r5, [r6]          //initialize ready_is_perfect as -1
  ldr r6, =st_last_hit
  str r2, [r6]            //set st_last_hit as current note's position
  ldr r5, =0
  ldr r6, =st_upset
  str r5, [r6]
  ldr r5, =1
  ldr r6, =st_s_upset
  str r5, [r6]            // set sound
  b L3

ready_up_perfect_set:
  ldr r5, =POSE_READY_UP
  ldr r6, =st_pose
  str r5, [r6]
  ldr r5, =1
  ldr r6, =ready_is_perfect
  str r5, [r6]
  b L2

ready_up_great_set:
  ldr r5, =POSE_READY_UP
  ldr r6, =st_pose
  str r5, [r6]
  ldr r5, =0
  ldr r6, =ready_is_perfect
  str r5, [r6]
  b L2

ready_down_perfect_set:
  ldr r5, =POSE_READY_DOWN
  ldr r6, =st_pose
  str r5, [r6]
  ldr r5, =1
  ldr r6, =ready_is_perfect
  str r5, [r6]
  b L2

ready_down_great_set:
  ldr r5, =POSE_READY_DOWN
  ldr r6, =st_pose
  str r5, [r6]
  ldr r5, =0
  ldr r6, =ready_is_perfect
  str r5, [r6]
  b L2


normal_set:
  ldr r5, =POSE_NORMAL
  ldr r6, =st_pose
  str r5, [r6]
  ldr r5, =0
  ldr r6, =st_ago
  str r5, [r6]
  ldr r5, =-1
  ldr r6, =ready_is_perfect
  str r5, [r6]          //initialize ready_is_perfect as -1
  bx lr

L1:
  ldr r5, =st_time
  vldr s5, [r5]
  ldr r6, =frame_time
  vldr s6, [r6]
  vsub.F32 s7, s5, s6        // Δt = st_time - frame_time
  ldr r5, =st_ago
  vldr s6, [r5]
  vadd.F32 s6, s6, s7        // st_ago += Δt
  vstr s6, [r5]

L2:
  ldr r5, =st_time
  vldr s5, [r5]
  ldr r6, =frame_time
  vldr s6, [r6]
  vsub.F32 s7, s5, s6        // Δt = st_time - frame_time
  ldr r5, =st_upset
  vldr s6, [r5]
  vadd.F32 s6, s6, s7        // st_upset += Δt
  vstr s6, [r5]

L3:
  ldr r5, =st_window
  str r1, [r5]          // save st_window
  ldr r5, =st_time
  ldr r5, [r5]
  ldr r6, =frame_time
  str r5, [r6]         // save frame_time

L5:
  vpop {s5-s7}
  pop {r4-r11, pc}


//.endif

/*
  out r0 - boolean，玩家 A（上）是否按下按键
      r1 - boolean，玩家 B（下）是否按下按键
*/
.text
.global get_input
get_input:
  push  {r4, r5}
  ldr   r4, =last_a_pressed
  ldr   r5, =last_b_pressed

  ldr   r0, =#74
  ldr   r1, =#76
  svc   #0x11
  ldrb  r2, [r4]
  ldrb  r3, [r5]
  strb  r0, [r4]
  strb  r1, [r5]
  bic   r0, r2  // r0 = r0 and not r2
  bic   r1, r3  // r1 = r1 and not r3

  pop   {r4, r5}
  bx    lr

.data
last_a_pressed: .byte 0
last_b_pressed: .byte 0

/*
  out r0 - 当前音符的方向（0 - 无；1 - 上；2 - 下；3 - 拍翅膀）
      r1 - 当前时刻处于何种窗口期（0 - 窗口期外； 1 - great； 2 - perfect）
      r2 - int 当前的音符为第几拍
*/
.text
.global get_note
get_note:
  push  {lr}

  // s2 = st_time
  // s3 = GREAT_WINDOW
  // s4 = PERFECT_WINDOW
  ldr   r0, =st_time
  vldr  s2, [r0]
  ldr   r0, =GREAT_WINDOW
  vldr  s3, [r0]
  ldr   r0, =PERFECT_WINDOW
  vldr  s4, [r0]

  // 当前音符 s0 = r0 = floor(st_time + GREAT_WINDOW)
  vadd.f32  s0, s2, s3
  bl        floor_f32

  // 返回值 r2：当前的音符为第几拍
  mov   r2, r0

  // 边界：音符时刻 < 0
  cmp   r2, #0
  blt   9f

  // 返回值 r1：当前时刻处于何种窗口期
  mov       r1, #0
  // s1 = 差值（当前时刻提前为负，延后为正）
  vsub.f32  s1, s3  // 减去之前加上的 GREAT_WINDOW
  vabs.f32  s1, s1
  vcmp.f32  s1, s3  // Great?
  vmrs      APSR_nzcv, FPSCR
  movle     r1, #1
  vcmp.f32  s1, s4  // Perfect?
  vmrs      APSR_nzcv, FPSCR
  movle     r1, #2

  // 取出当前音符
  ldr   r0, =map_seq
  ldr   r0, [r0]
  ldrb  r0, [r0, r2]
  // 取低 4 位
  // 返回值 r0：当前音符的方向
  and   r0, #0xf

  pop   {pc}

9:
  mov   r0, #0
  mov   r1, #0
  pop   {pc}
