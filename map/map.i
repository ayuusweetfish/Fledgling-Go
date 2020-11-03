# vim: set ft=asm:

.macro  title, what:req
  _map_title: .asciz "\what"
.endm
.macro  audio, what:req
  _map_audio: #.incbin "\what"
.endm

.irp    name, tempo, offset
  .macro  \name, what:req
    .align  2
    _map_\name: .float \what
  .endm
.endr

.set    _seq_lead, 1
.macro  lead  l:req
  .set  _seq_lead, \l
.endm
.macro  seq   str
  .ifndef _map_seq_first
    _map_seq_first:
  .endif
  .irpc ch, \str
    .if     "\ch" == "."
      .byte ((_seq_lead << 4) | 0)
    .elseif "\ch" == "u"
      .byte ((_seq_lead << 4) | 1)
    .elseif "\ch" == "d"
      .byte ((_seq_lead << 4) | 2)
    .elseif "\ch" == "f"
      .byte ((_seq_lead << 4) | 3)
    .endif
  .endr
.endm

.macro  decor type:req, x:req, y:req, z=0, w=1, h=1
  .align  2
  .ifndef _map_decor_first
    _map_decor_first:
  .endif
  .int    \type
  .float  \x
  .float  \y
  .float  \z
  .float  \w
  .float  \h
.endm

.irp    name, seq, decor
  .macro  \name\()_end
    _map_\name\()_last:
  .endm
.endr

.data
.org    0

.int    _map_title
.int    _map_tempo
.int    _map_offset
.int    _map_audio
.int    _map_seq_first
.int    _map_seq_last
.int    _map_decor_first
.int    _map_decor_last
