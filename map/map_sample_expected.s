.data
.org    0

.int    title
.int    audio
.float  120.1
.float  0.123
.int    sequence
.int    decorations

title:  .asciz  "qwqwqwqwq"
audio:  .incbin "../kayubox/demo/res/copycat.ogg"

.align  4
sequence:
  .int  2   // Number of segments
  .int  segment_0
  .int  segment_1
segment_0:
  .int  32  // Time
  .int  1   // Lead
  .int  4   // Number of notes
    .int  0;  .float  0
    .int  1;  .float  1
    .int  0;  .float  1.5
    .int  2;  .float  2
segment_1:
  .int  64
  .int  1
  .int  4
    .int  0;  .float  0
    .int  1;  .float  1
    .int  0;  .float  1.5
    .int  2;  .float  2

.align  4
decorations:
  .int    2 // Number of decorations
decoration_0:
  .int    1
  .float  2
  .float  3
  .float  4
  .float  5
  .float  6
decoration_1:
  .int    2
  .float  7
  .float  8
  .float  0
  .float  1
  .float  1
