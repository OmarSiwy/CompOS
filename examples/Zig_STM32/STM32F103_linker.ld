ENTRY("_start");
MEMORY
{
  flash0 (rw!) : ORIGIN = 0x08000000, LENGTH = 0x00040000
  ram0 (rw!) : ORIGIN = 0x20000000, LENGTH = 0x00005000
}


 SECTIONS{
  .isr_vector :
  {
     KEEP(*(.isr_vector))
  } > flash0
 
  .text : ALIGN(8)
  {
    KEEP(*(startup))
    *(.text*)
  } > flash0
 
 .data :  {
    _data_start = .;
    *(.data*)
    *(.rodata)
    _data_end = .;
  } > ram0 AT> flash0
 
  .bss (NOLOAD) : ALIGN(8)
  {
    _bss_start = .;
    *(.bss*)
    _bss_end = .;
  } > ram0
  _data_load_start = LOADADDR(.data);

  .stack (NOLOAD) : ALIGN(8)
  {
     _stack_start = .;
     . = . + 0x1000; /* Example 4KB stack */
     _stack_end = .;
  } > ram0
 
  .heap (NOLOAD) : ALIGN(8)
  {
     _heap_start = .;
     . = . + 0x4000; /* Example 16KB heap */
     _heap_end = .;
  } > ram0
 } ASSERT(SIZEOF(.text) + SIZEOF(.data) < LENGTH(flash0), "Flash memory overflow");
 ASSERT(SIZEOF(.bss) < LENGTH(ram0), "RAM overflow");