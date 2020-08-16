#!/bin/bash
gcc -c -g -Os -m32 -ffreestanding -Wall -Werror boot.c -o boot_c.o
ld -m elf_i386 -static -Tbootsect.ld -nostdlib --nmagic -o boot_c.elf boot_c.o
objcopy -O binary boot_c.elf boot_c.bin
