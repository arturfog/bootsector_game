#!/bin/bash
gcc -c -g -Os -march=i686 -ffreestanding -Wall -Werror boot.c -o boot_c.o
ld -static -Ttest.ld -nostdlib --nmagic -o boot_c.elf boot_c.o
objcopy -O binary boot_c.elf boot_c.bin
