.code16                  #generate 16-bit code
.text                    #executable code location
     .globl _start;

; al = character
; bh = page number
; bl = color
print_string:
    movb $0x00, %bh
    movb $0x07, %bl
    movb $0x0e, %ah
    int $0x10
; ah = 0ch (write graphics pixel)
; al = color
; cx = column (x)
; dx = row (y)
draw_pixel:
    int $0x10
; get key from keyboard
; al = ascii character
; ah = code of pressed key
get_key:
     xorw, %ax, %ax
     int $0x16
; clean the screen and 
; set video mode to 320x200
init_enviroment:
     movb $0x03, %al
     movb $0x00, %ah
     int $0x10

     movb $0x13, %al
     movb $0x00, %ah
     int $0x10

_start:                  #code entry point
     #print letter 'H' onto the screen
     movb $'H' , %al
     movb $0x0e, %ah
     int  $0x10

; fill missing bytes
     . = _start + 510      #mov to 510th byte from 0 pos
     .byte 0x55            #append boot signature
     .byte 0xaa            #append boot signature 
