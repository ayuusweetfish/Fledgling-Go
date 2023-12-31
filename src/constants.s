// st_pose 可能的动作
.set POSE_NORMAL, 0
.set POSE_MOV_PERFECT, 1
.set POSE_MOV_GREAT, 2            //仅用于上下按键
.set POSE_BUMP, 3
.set POSE_READY_UP, 4
.set POSE_READY_DOWN, 5
.set POSE_FLAP_PERFECT, 6
.set POSE_FLAP_GREAT, 7           //仅用于拍翅膀


// 其他用到的常量
.set FPS, 60 // 帧率

// perfect/great 窗口期半边宽度
// ±0.25 拍判定为 great, ±0.125 拍判定为 perfect
.weak GREAT_WINDOW
GREAT_WINDOW: .float 0.25
.weak PERFECT_WINDOW
PERFECT_WINDOW: .float 0.125

// 鸟的类型
.equ  BIRD_TYPE_LEAD, 1 //（x offset由curLead决定）
.equ  BIRD_TYPE_ME, 2 // （y由calMeY决定）
.equ  BIRD_TYPE_NPC, 0
