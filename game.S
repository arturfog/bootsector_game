# Memory map
# 0x00000000	0x000003FF	1 KiB	Real Mode IVT (Interrupt Vector Table)
# 0x00000500	0x00007BFF	almost 30 KiB	Conventional memory
# 0x00007C00	0x00007DFF	512 bytes	Your OS BootSector
# 0x00007E00	0x0007FFFF	480.5 KiB	Conventional memory
#
.code16                  # generate 16-bit code
.text                    # executable code location
     .globl _start;
_start:                  # code entry point
     # init variables
     xor %ecx, %ecx
     movw mem_seg, %cx
     # start_x
     movw $160, (%ecx)
     # start_y
     movw $120, 2(%ecx)
     # set video mode
     call init_enviroment
     call draw_snake
     call draw_fruit
     # main loop
     loop:
     call wait
     # store current position
     call pushq
     call handle_keypress
     call hit_fruit
     call draw_snake
     # clean old pixels after each move
     clean_pixels:
     xor %eax, %eax
     movw qs, %ax
     cmpw size, %ax
     jle loop
     call popq
     call clear_pixel
     jmp clean_pixels

# ---------------- functions --------------- #
pushq:
     # --------------------------
     # check for free space in queue
     movw qs, %ax
     cmp $200, %ax
     je push_end
     # --------------------------
     # store current pos in queue
     xor %ecx, %ecx
     movw mem_seg, %cx
     #
     xor %ebx, %ebx
     movb (%ecx), %bl
     movb 2(%ecx), %bh
     
     movw mem_seg, %cx
     add qend, %cx
     movw %bx, (%ecx)
     # --------------------------
     movw qend, %ax
     add $2, %ax
     movw %ax, qend
     # --------------------------
     # increase queue size
     movw qs, %ax
     inc %ax
     movw %ax, qs
     # --------------------------
     push_end:
     ret
# ----------------------------------------------------
popq:
     # --------------------------
     # check if any items are in queue
     movw qs, %ax
     cmp $0, %ax
     je pop_end
     # --------------------------
     # move item back
     xor %ecx, %ecx
     movw mem_seg, %cx
     add qstart, %cx
     #
     xor %ebx, %ebx
     movw (%ecx), %bx
     movw $0xFFFF, (%ecx)

     movw mem_seg, %cx
     movb %bl, 4(%ecx)
     movb %bh, 6(%ecx)
     # --------------------------
     movw qstart, %ax
     add $2, %ax
     movw %ax, qstart
     # --------------------------
     # decrease queue size
     movw qs, %ax
     dec %ax
     movw %ax, qs
     # --------------------------
     pop_end:
     ret
# ----------------------------------------------------
wait:
     # wait
     mov $3, %cx
     mov $0, %dx
     mov $0x86, %ah
     int $0x15
     ret
# ----------------------------------------------------
handle_keypress:
     xor %ecx, %ecx
     movw mem_seg, %cx

     call get_key
     cmpw $0, %ax
     # parse key
     jne got_key
     # no key, restore old one
     movb direction, %ah

     got_key:
     cmpb $0x4D, %ah
     je move_right
     cmpb $0x4B, %ah
     je move_left
     cmpb $0x48, %ah
     je move_up
     cmpb $0x50, %ah
     je move_down

     move_left:
     sub $1,(%ecx)
     movb $0x4D, direction
     jmp move
     move_right:
     add $1,(%ecx)
     movb $0x4B, direction
     jmp move
     move_up:
     sub $1,2(%ecx)
     movb $0x48, direction
     jmp move
     move_down:
     add $1,2(%ecx)
     movb $0x50, direction
     move:
     ret
# ----------------------------------------------------
draw_snake:
     push %bp
     mov %sp, %bp

     xor %ecx, %ecx
     movw mem_seg, %cx

     pushw 2(%ecx)
     pushw (%ecx)
     pushw $0x4

     call draw_pixel
     add $6, %esp

     pop %bp
     ret
# ----------------------------------------------------
hit_fruit:
     xor %eax, %eax
     xor %ecx, %ecx
     xor %edx, %edx
     movw mem_seg, %bx
     # get pixel color
     movb $0xD, %ah
     movw (%ebx), %cx # column
     movw 2(%ebx), %dx # row
     xor %ebx, %ebx
     int $0x10

     game_over:
     # check if hit snake
     cmp $0x4, %al
     je game_over
     # check if hit fruit
     cmp $0x3, %al
     jne _hit_fruit_end
     # increase snake size
     movb size, %cl
     inc %cl
     mov %cl, size
     # draw new fruit
     call draw_fruit

     _hit_fruit_end:
     ret
# ----------------------------------------------------
draw_fruit:
     push %bp
     mov %sp, %bp

     xor %ax,%ax
     int $0x1a # CX:DX = number of clock ticks since midnight

     and $0x007F, %dx
     pushw %dx
     pushw $100
     pushw $0x3
     call draw_pixel
     add $6, %esp

     pop %bp
     ret
# ----------------------------------------------------
clear_pixel:
     push %bp
     mov %sp, %bp

     xor %ecx, %ecx
     movw mem_seg, %cx

     pushw 6(%ecx)
     pushw 4(%ecx)
     pushw $0x0
     call draw_pixel
     add $6, %esp

     pop %bp
     ret
# ----------------------------------------------------
print_character:
    push %bp
    mov %sp, %bp

    movb 4(%esp), %al
    movb $0x00, %bh
    movb $0x07, %bl
    movb $0x0e, %ah
# al = character
# ah = 0x0e
# bh = page number
# bl = color
    int $0x10
    
    pop %bp
    ret
# ----------------------------------------------------
draw_pixel:
     push %bp
     mov %sp, %bp

     movw 8(%esp), %dx
     movw 6(%esp), %cx
     movb 4(%esp), %al

     movb $0x0C, %ah
     movb $0x0, %bh
# ah = 0ch (write graphics pixel)
# al = color
# cx = column (x)
# dx = row (y)
     int $0x10

     pop %bp
     ret
# ----------------------------------------------------
get_key:
     xorw %ax, %ax
     movb $0x1, %ah
     int $0x16
     
     cmpw $0x0, %ax
     je _gk_end

     xorw %ax, %ax
# get key from keyboard
# al = ascii character
# ah = code of pressed key
     int $0x16
     _gk_end:
     ret
# ----------------------------------------------------
# clean the screen and 
# set video mode to 320x200
init_enviroment:     
     # set video mode
     movb $0x13, %al
     movb $0x00, %ah
     int $0x10
     ret
# ----------------------------------------------------
     mem_seg: .word 0x7E00
     size: .word 0x1
     qs: .word 0x0
     qstart: .word 0x8
     qend: .word 0x8
     direction: .byte 0x0
# fill missing bytes
     . = _start + 510      # mov to 510th byte from 0 pos
     .byte 0x55            # append boot signature
     .byte 0xaa            # append boot signature 
