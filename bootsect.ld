OUTPUT_FORMAT("elf32-i386");
ENTRY(main);
SECTIONS
{
    . = 0x7C00;
    .text : AT(0x7C00)
    {
        *(.text);
    }
    .sig : AT(0x7DFE)
    {
        SHORT(0xaa55);
    }
    /* Remove sections that won't be relevant to us */
    /DISCARD/ : {
        *(.eh_frame);
        *(.comment);
    }
}
