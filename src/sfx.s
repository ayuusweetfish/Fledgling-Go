.data
perfect:  .int  0
great:    .int  0
bump:     .int  0
upset:    .int  0
flap:     .int  0

.set  vol_perfect,  0x30000000
.set  vol_great,    0x30000000
.set  vol_bump,     0x60000000
.set  vol_upset,    0x60000000
.set  vol_flap,     0x70000000

.text
.global sfx_init
sfx_init:
  push  {lr}

  .irp  what, perfect, great, bump, upset, flap
    ldr   r0, =sfx_\what\()_ogg
    ldr   r1, =sfx_\what\()_ogg_size
    bl    kx_sound
    ldr   r1, =\what
    str   r0, [r1]
  .endr

  pop   {pc}

.global sfx_update
// 检查 st_s_*，播放对应音效
// 同时对所有音效完成 update
sfx_update:
  push  {lr}

  .irp  what, perfect, great, bump, upset, flap
    ldr   r0, =\what
    ldr   r0, [r0]

    // 是否需要开始播放
    ldr   r1, =st_s_\what
    ldrb  r1, [r1]
    cmp   r1, #0
    beq   9f
    ldr   r1, =\what
    ldr   r0, [r1]  // 声音 ID
    ldr   r1, =2    // 轨道编号
    ldr   r2, =0    // 偏移
    ldr   r3, =0    // 是否循环
    svc   #0x210    // play

    ldr   r0, =2
    ldr   r1, =vol_\what
    ldr   r2, =0
    svc   #0x211  // trk_config

  9:
  .endr

  pop   {pc}
