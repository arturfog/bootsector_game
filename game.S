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
     movw $160, (%ecx)
     movw $120, 2(%ecx)

     call init_enviroment

     pushw 2(%ecx)
     pushw (%ecx)
     call draw_pixel
     pop %cx
     pop %dx

     loop:
     call get_key
     cmpw $0, %ax

     jne got_key
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
     
     jmp loop

     move_left:
     dec %cx
     movb $0x4D, direction
     jmp move
     move_right:
     inc %cx
     movb $0x4B, direction
     jmp move
     move_up:
     dec %dx
     movb $0x48, direction
     jmp move
     move_down:
     inc %dx
     movb $0x50, direction
     jmp move

     move:
     push %dx
     push %cx
     # call init_enviroment
     call draw_pixel

     # wait
     mov $3, %cx
     mov $0, %dx
     mov $0x86, %ah
     int $0x15

     pop %cx
     pop %dx

     jmp loop
     
# al = character
# ah = 0x0e
# bh = page number
# bl = color
print_character:
    push %bp
    mov %sp, %bp

    movb 4(%esp), %al
    movb $0x00, %bh
    movb $0x07, %bl
    movb $0x0e, %ah
    int $0x10

    pop %bp
    ret

# ah = 0ch (write graphics pixel)
# al = color
# cx = column (x)
# dx = row (y)
draw_pixel:
     push %bp
     mov %sp, %bp

     movw 6(%esp), %dx
     movw 4(%esp), %cx

     mov $0x0C, %ah
     mov $0x3, %al
     mov $0x0, %bh
     int $0x10

     pop %bp
     ret

# get key from keyboard
# al = ascii character
# ah = code of pressed key
get_key:
     push %bp
     mov %sp, %bp

     xorw %ax, %ax
     movb $1, %ah
     int $0x16
     
     cmpw $0, %ax
     je _gk_end

     xorw %ax, %ax
     int $0x16

     _gk_end:
     pop %bp
     ret

# clean the screen and 
# set video mode to 320x200
init_enviroment:
     push %bp
     mov %sp, %bp
     
     # set video mode
     movb $0x13, %al
     movb $0x00, %ah
     int $0x10

     pop %bp
     ret

     mem_seg: .word 0x7E00
     size: .byte 1
     direction: .byte 0
# fill missing bytes
     . = _start + 510      # mov to 510th byte from 0 pos
     .byte 0x55            # append boot signature
     .byte 0xaa            # append boot signature 
