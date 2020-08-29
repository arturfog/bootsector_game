.code16                  #generate 16-bit code
.text                    #executable code location
     .globl _start;
_start:                  #code entry point
     call init_enviroment
     
     push col
     push row
     call draw_pixel
     pop %cx
     pop %dx

     loop:
     call get_key

     cmp $0x4D, %ah
     je move_right
     cmp $0x4B, %ah
     je move_left
     cmp $0x48, %ah
     je move_up
     cmp $0x50, %ah
     je move_down
     
     jmp loop

     move_left:
     dec %cx
     jmp move
     move_right:
     inc %cx
     jmp move
     move_up:
     dec %dx
     jmp move
     move_down:
     inc %dx
     jmp move

     move:
     push %dx
     push %cx
     call init_enviroment
     call draw_pixel
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
     mov $0x01, %ah
     int $0x16
     cmp %ax, 0
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
     movb $0x12, %al
     movb $0x00, %ah
     int $0x10

     pop %bp
     ret

# fill missing bytes
     row: .word 320
     col: .word 240
     size: .word 1
     . = _start + 510      # mov to 510th byte from 0 pos
     .byte 0x55            # append boot signature
     .byte 0xaa            # append boot signature 
