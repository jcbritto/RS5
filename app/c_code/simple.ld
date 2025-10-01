MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 64K
}

SECTIONS
{
    .text : {
        *(.text*)
    } > FLASH
    
    .rodata : {
        *(.rodata*)
    } > FLASH
    
    .data : {
        *(.data*)
    } > FLASH
    
    .bss : {
        *(.bss*)
    } > FLASH
}