#!/bin/sh
gcc -c -g -m32 -Os -march=i686 -ffreestanding -Wall -Werror test5.c -o test5.o
ld -melf_i386 -static -Tbootsect.ld -nostdlib --nmagic -o test5.elf test5.o
objcopy -O binary test5.elf test5.bin
