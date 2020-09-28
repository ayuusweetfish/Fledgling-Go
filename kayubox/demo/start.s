.section .text.startup
  bl    foo
  mov   r2, #63
  svc   #2018
