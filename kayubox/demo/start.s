.section .text.startup
  bl    foo
  mov   r3, #63
  svc   #2018   // Invalid
  svc   #0      // r0=80, r1=435, r2=2020, r3=63
  adr   r0, text
  svc   #1
  svc   #0xf

text:
  .ascii "hello world"
  .byte 0
