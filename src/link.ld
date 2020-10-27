SECTIONS
{
  . = 0x80000000;

  .text.startup : { *(.text.startup) }
  .text : { *(.text .text.*) }

  .rodata : { *(.rodata .rodata.*) }
  .data : { *(.data .data.*) }

  . = ALIGN(0x8);
  _bss_begin = .;
  .bss : { *(.bss .bss.*) }
  _bss_end = .;

  . = ALIGN(4096);
  _initial_brk = .;
}
