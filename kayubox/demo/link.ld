SECTIONS
{
  . = 0x0;

  .text.startup : { *(.text.startup) }
  .text : { *(.text .text.*) }

  .rodata : { *(.rodata .rodata.*) }
  .data : { *(.data .data.*) }

  . = ALIGN(0x8);
  _bss_begin = .;
  .bss : { *(.bss) }
  _bss_end = .;
}
