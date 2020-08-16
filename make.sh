#!/bin/bash
as boot.S -o boot.o
ld -Ttext 0x7c00 --oformat=binary -o boot.bin boot.o
