#!/bin/bash
set -x
as game.S -o game.o
ld -Ttext 0x7c00 --oformat=binary -o game.bin game.o
