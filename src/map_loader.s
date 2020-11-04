.equ  OFF_TITLE,    0
.equ  OFF_AUDIO,    4
.equ  OFF_AUDIO_LEN,8
.equ  OFF_TEMPO,    12
.equ  OFF_AUDOFF,   16
.equ  OFF_SEQ,      20
.equ  OFF_SEQ_LEN,  24
.equ  OFF_DECOR,    28
.equ  OFF_DECOR_LEN,32

# in  r0 - Pointer to map
# out r0 - Pointer to title string
#     r1 - Pointer to audio data
#     r2 - Length of audio data
#     s0 - Tempo
#     s1 - Audio offset
.global map_meta
map_meta:
  push  {r4}
  mov   r4, r0
  ldr   r0, [r4, #OFF_TITLE]
  add   r0, r4
  ldr   r1, [r4, #OFF_AUDIO]
  add   r1, r4
  ldr   r2, [r4, #OFF_AUDIO_LEN]
  ldr   r3, [r4, #OFF_TEMPO]
  ldr   r3, [r4, r3]
  vmov  s0, r3
  ldr   r3, [r4, #OFF_AUDOFF]
  ldr   r3, [r4, r3]
  vmov  s1, r3
  pop   {r4}
  bx    lr
