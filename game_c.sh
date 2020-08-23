#!/bin/sh
gcc -c -g -m32 -Os -march=i686 -ffreestanding -Wall -Werror game.c -o game_c.o
ld -melf_i386 -static -Tbootsect.ld -nostdlib --nmagic -o game_c.elf game_c.o
objcopy -O binary game_c.elf game_c.bin
