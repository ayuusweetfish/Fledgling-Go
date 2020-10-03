.section .text.startup
  bl    foo
  mov   r3, #63
  svc   #2018   // Invalid
  svc   #0x00   // r0=79, r1=435, r2=2020, r3=63
  adr   r0, text
  svc   #0x01
  svc   #0x0f

text:
  .ascii "hello world"
  .byte 0
